import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:image_picker/image_picker.dart';
import 'setting_page.dart';

class SellerMyProfilePage extends StatefulWidget {
  final String? name;
  final String? email;

  const SellerMyProfilePage({super.key, this.name, this.email});

  @override
  State<SellerMyProfilePage> createState() => _SellerMyProfilePageState();
}

class _SellerMyProfilePageState extends State<SellerMyProfilePage> {
  // Get current user from Firebase Auth
  final User? user = FirebaseAuth.instance.currentUser;
  final supabase = Supabase.instance.client;

  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _storeName = 'Loading...';
  String? _userImageUrl;
  bool _isLoading = true;

  // OPTIMIZATION: Load directly from Firestore on startup
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        String name =
            doc.data()?['name'] ?? widget.name ?? user!.email!.split('@')[0];
        String email = doc.data()?['email'] ?? widget.email ?? user!.email!;
        String store = doc.data()?['brandName'] ?? 'Brandly Store';
        String? imageUrl = doc.data()?['imageUrl'];

        // Save to SharedPreferences for offline access
        await prefs.setString('seller_name', name);
        await prefs.setString('seller_email', email);
        await prefs.setString('store_name', store);
        if (imageUrl != null) {
          await prefs.setString('user_image', imageUrl);
        }

        if (mounted) {
          setState(() {
            _userName = name;
            _userEmail = email;
            _storeName = store;
            _userImageUrl = imageUrl;
            _isLoading = false;
          });
        }

        // Sync brand image with seller profile image
        if (imageUrl != null && imageUrl.isNotEmpty) {
          _syncBrandImage(imageUrl);
        }
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        if (mounted) {
          setState(() {
            _userName =
                prefs.getString('seller_name') ?? widget.name ?? 'Seller';
            _userEmail =
                prefs.getString('seller_email') ?? widget.email ?? 'No email';
            _storeName = prefs.getString('store_name') ?? 'Brandly Store';
            _userImageUrl = prefs.getString('user_image');
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _userName =
              prefs.getString('seller_name') ?? widget.name ?? 'Guest Seller';
          _userEmail = prefs.getString('seller_email') ??
              widget.email ??
              'seller@example.com';
          _storeName = prefs.getString('store_name') ?? 'Brandly Store';
          _userImageUrl = prefs.getString('user_image');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserData() async => await _loadUserData();

  /// Sync seller profile image to brand cover image
  Future<void> _syncBrandImage(String imageUrl) async {
    try {
      if (user?.uid == null) return;

      final brandQuery = await FirebaseFirestore.instance
          .collection('brand')
          .where('sellerId', isEqualTo: user!.uid)
          .limit(1)
          .get();

      if (brandQuery.docs.isNotEmpty) {
        final brandDoc = brandQuery.docs.first;
        final currentImage = brandDoc.data()['image'];
        
        // Only update if the brand image is empty or different
        if (currentImage == null || currentImage.isEmpty || currentImage != imageUrl) {
          await brandDoc.reference.update({
            'image': imageUrl,
            'last_updated': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Brand image synced with seller profile');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not sync brand image: $e');
    }
  }

  /// Helper function to delete old images before uploading a new one.
  /// This prevents unused files from piling up in your storage.
  Future<void> _deleteOldProfileImage() async {
    try {
      if (user?.uid == null) return;

      // List all common extensions to ensure cleanup
      final List<String> possibleFiles = [
        '${user!.uid}.jpg',
        '${user!.uid}.jpeg',
        '${user!.uid}.png',
        '${user!.uid}.webp',
      ];

      // Supabase 'remove' ignores files that don't exist, so this is safe
      await supabase.storage.from('profiles').remove(possibleFiles);
      debugPrint('✅ Old profile images cleaned up');
    } catch (e) {
      // Catch silently - if cleanup fails, upload should still proceed
      debugPrint('Note: Cleanup warning: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    // 1. Pick the image
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, // Optimization: Resize for faster uploads
      maxHeight: 512,
      imageQuality: 75, // Optimization: Compress to save bandwidth
    );

    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. CLEANUP: Delete old image first
      await _deleteOldProfileImage();

      // 3. READ FILE (Platform Safe - works on Web, MacOS, Mobile)
      final bytes = await image.readAsBytes();

      // Get extension from filename (safe on web)
      final fileExt = image.name.split('.').last;
      final fileName = '${user!.uid}.$fileExt';

      // 4. UPLOAD TO SUPABASE (bucket: profiles)
      await supabase.storage.from('profiles').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true, // Overwrite if exact name exists
              contentType: 'image/$fileExt',
            ),
          );

      // 5. GET PUBLIC URL
      final imageUrlPath =
          supabase.storage.from('profiles').getPublicUrl(fileName);

      // Add "Cache Buster" so Flutter reloads the image
      final finalUrl =
          '$imageUrlPath?v=${DateTime.now().millisecondsSinceEpoch}';

      debugPrint('✅ Image URL: $finalUrl');

      // 6. SAVE TO FIRESTORE (Permanent Record)
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'imageUrl': finalUrl,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // MERGE: Don't overwrite other fields

      // 6.1. UPDATE BRAND IMAGE (Sync seller profile image to brand cover)
      try {
        final brandQuery = await FirebaseFirestore.instance
            .collection('brand')
            .where('sellerId', isEqualTo: user!.uid)
            .limit(1)
            .get();

        if (brandQuery.docs.isNotEmpty) {
          final brandDoc = brandQuery.docs.first;
          await brandDoc.reference.update({
            'image': finalUrl,
            'last_updated': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Brand image updated');
        }
      } catch (e) {
        debugPrint('⚠️ Could not update brand image: $e');
      }

      // 7. SAVE TO SHAREDPREFERENCES (Offline Access)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image', finalUrl);

      // 8. Update UI
      if (mounted) {
        setState(() {
          _userImageUrl = finalUrl;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile image updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Upload Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshUserData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : RefreshIndicator(
              onRefresh: _refreshUserData,
              color: const Color(0xFF6C63FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildProfileAvatar(),
                    const SizedBox(height: 16),
                    Text(_storeName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_userEmail, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 40),
                    _buildMenuItem(
                      icon: Icons.settings,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.edit,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'Edit Profile',
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerEditProfilePage(
                              currentName: _userName,
                              currentEmail: _userEmail,
                              currentStoreName: _storeName,
                            ),
                          ),
                        );
                        if (result == true) _refreshUserData();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: const Color.fromARGB(255, 166, 12, 232),
                      title: 'Logout',
                      titleColor: const Color.fromARGB(255, 166, 12, 232),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          await FirebaseAuth.instance.signOut();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickAndUploadImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _userImageUrl == null
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF),
                        const Color(0xFF7C5CFF).withOpacity(0.7)
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _userImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      _userImageUrl!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _storeName.isNotEmpty
                                ? _storeName[0].toUpperCase()
                                : 'B',
                            style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _storeName.isNotEmpty ? _storeName[0].toUpperCase() : 'B',
                      style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ),

          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black45,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // Camera Icon Badge (only shown when not loading)
          if (!_isLoading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black)),
            ),
            if (titleColor == null)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SELLER EDIT PROFILE PAGE (No changes needed)
// ============================================

class SellerEditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentStoreName;

  const SellerEditProfilePage({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentStoreName,
  });

  @override
  State<SellerEditProfilePage> createState() => _SellerEditProfilePageState();
}

class _SellerEditProfilePageState extends State<SellerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _storeNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _storeNameController = TextEditingController(text: widget.currentStoreName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'brandName': _storeNameController.text,
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('seller_name', _nameController.text);
        await prefs.setString('seller_email', _emailController.text);
        await prefs.setString('store_name', _storeNameController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF7C5CFF).withOpacity(0.7)
                  ]),
                ),
                child: Center(
                  child: Text(
                    _storeNameController.text.isNotEmpty
                        ? _storeNameController.text[0].toUpperCase()
                        : 'B',
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter your name'
                      : null),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: _storeNameController,
                  label: 'Store Name',
                  icon: Icons.store,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please enter store name'
                      : null),
              const SizedBox(height: 20),
              _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please enter your email';
                    if (!v.contains('@')) return 'Please enter a valid email';
                    return null;
                  }),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }
}
