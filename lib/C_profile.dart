/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editprofile_page.dart';
import 'favourite_page.dart';
import 'setting_page.dart';
import 'customer_order_page.dart';
import 'favourite_service.dart'; // استدعاء الخدمة
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyProfilePage extends StatefulWidget {
  final String? name;
  final String? email;

  const MyProfilePage({
    super.key,
    this.name,
    this.email,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userImageUrl = '';
  bool _isLoading = true;

  int _totalOrders = 0;
  int _totalFavorites = 0;
  int _totalReviews = 0;

  final FavoritesService _favoritesService = FavoritesService(); // instance

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String extractedName = 'User';
        if (user.email != null && user.email!.isNotEmpty) {
          extractedName = user.email!.split('@')[0];
          if (extractedName.isNotEmpty) {
            extractedName =
                extractedName[0].toUpperCase() + extractedName.substring(1);
          }
        }

        try {
          final response = await Supabase.instance.client
              .from('users')
              .select()
              .eq('id', user.uid)
              .single();

          if (mounted) {
            final prefs = await SharedPreferences.getInstance();

            await prefs.setString(
                'user_name', response['name'] ?? extractedName);
            await prefs.setString(
                'user_email', response['email'] ?? user.email ?? '');
            await prefs.setString(
                'user_image', response['profile-image'] ?? '');

            setState(() {
              _userName = response['name'] ?? extractedName;
              _userEmail = response['email'] ?? user.email ?? '';
              _userImageUrl = response['profile-image'] ?? '';
            });
          }
        } catch (e) {
          print('Supabase error: $e');

          if (mounted) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', extractedName);
            await prefs.setString('user_email', user.email ?? '');

            setState(() {
              _userName = extractedName;
              _userEmail = user.email ?? '';
            });
          }
        }

        try {
          final ordersSnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: user.uid)
              .get();

          _totalOrders = ordersSnapshot.docs.length;
        } catch (e) {
          print('Error loading orders: $e');
          _totalOrders = 0;
        }

        try {
          final prefs = await SharedPreferences.getInstance();
          final favoritesJson = prefs.getStringList('favorites') ?? [];
          _totalFavorites = favoritesJson.length;
        (); // تحميل البيانات في الخدمة
        } catch (e) {
          print('Error loading favorites: $e');
          _totalFavorites = 0;
        }

        try {
          final reviewsSnapshot = await FirebaseFirestore.instance
              .collection('reviews')
              .where('userId', isEqualTo: user.uid)
              .get();

          _totalReviews = reviewsSnapshot.docs.length;
        } catch (e) {
          print('Error loading reviews: $e');
          _totalReviews = 0;
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();

        if (mounted) {
          setState(() {
            _userName =
                prefs.getString('user_name') ?? widget.name ?? 'Guest User';
            _userEmail = prefs.getString('user_email') ??
                widget.email ??
                'guest@example.com';
            _userImageUrl = prefs.getString('user_image') ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');

      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      String extractedName = 'User';
      if (user?.email != null && user!.email!.isNotEmpty) {
        extractedName = user.email!.split('@')[0];
        if (extractedName.isNotEmpty) {
          extractedName =
              extractedName[0].toUpperCase() + extractedName.substring(1);
        }
      }

      if (mounted) {
        setState(() {
          _userName =
              prefs.getString('user_name') ?? widget.name ?? extractedName;
          _userEmail = prefs.getString('user_email') ??
              widget.email ??
              user?.email ??
              'No email';
          _userImageUrl = prefs.getString('user_image') ?? '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bytes = await File(image.path).readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profile_images/$fileName';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(filePath, bytes);

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await Supabase.instance.client
          .from('users')
          .update({'profile_image_url': imageUrl}).eq('id', user.uid);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image', imageUrl);

      setState(() {
        _userImageUrl = imageUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          },
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
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshUserData,
              color: const Color(0xFF6C63FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Image
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _userImageUrl.isEmpty
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF6C63FF),
                                      const Color(0xFF7C5CFF).withOpacity(0.7),
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
                          child: _userImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _userImageUrl,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          _userName.isNotEmpty &&
                                                  _userName != 'Loading...'
                                              ? _userName[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _userName.isNotEmpty &&
                                            _userName != 'Loading...'
                                        ? _userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
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
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats container
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.1),
                            const Color(0xFF7C5CFF).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Orders', _totalOrders.toString(),
                              Icons.shopping_bag),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem('Favorites',
                              _totalFavorites.toString(), Icons.favorite),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                              'Reviews', _totalReviews.toString(), Icons.star),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

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
                            builder: (context) => EditProfilePage(
                              currentName: _userName,
                              currentEmail: _userEmail,
                            ),
                          ),
                        );
                        if (result == true) _refreshUserData();
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.favorite,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'My Favorites',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritesPage( favouriteservice: FavoritesService(),
                            ),
                          ),
                        ).then((_) => _refreshUserData());
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'My Orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomerOrdersPage()),
                        ).then((_) => _refreshUserData());
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: const Color.fromARGB(255, 166, 12, 232),
                      title: 'Logout',
                      titleColor: const Color.fromARGB(255, 166, 12, 232),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6C63FF),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
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
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            if (titleColor == null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editprofile_page.dart';
import 'favourite_page.dart';
import 'setting_page.dart';
import 'customer_order_page.dart';
import 'favourite_service.dart';
import 'package:image_picker/image_picker.dart';

class MyProfilePage extends StatefulWidget {
  final String? name;
  final String? email;

  const MyProfilePage({
    super.key,
    this.name,
    this.email,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _userImageUrl = '';
  bool _isLoading = true;

  int _totalOrders = 0;
  int _totalFavorites = 0;
  int _totalReviews = 0;

  final FavoritesService _favoritesService = FavoritesService();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String extractedName = 'User';
        if (user.email != null && user.email!.isNotEmpty) {
          extractedName = user.email!.split('@')[0];
          if (extractedName.isNotEmpty) {
            extractedName =
                extractedName[0].toUpperCase() + extractedName.substring(1);
          }
        }

        try {
          final response = await Supabase.instance.client
              .from('users')
              .select()
              .eq('id', user.uid)
              .single();

          if (mounted) {
            final prefs = await SharedPreferences.getInstance();

            await prefs.setString(
                'user_name', response['name'] ?? extractedName);
            await prefs.setString(
                'user_email', response['email'] ?? user.email ?? '');
            await prefs.setString(
                'user_image', response['profile-image'] ?? '');

            setState(() {
              _userName = response['name'] ?? extractedName;
              _userEmail = response['email'] ?? user.email ?? '';
              _userImageUrl = response['profile-image'] ?? '';
            });
          }
        } catch (e) {
          print('Supabase error: $e');

          if (mounted) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', extractedName);
            await prefs.setString('user_email', user.email ?? '');

            setState(() {
              _userName = extractedName;
              _userEmail = user.email ?? '';
            });
          }
        }

        try {
          final ordersSnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: user.uid)
              .get();

          _totalOrders = ordersSnapshot.docs.length;
        } catch (e) {
          print('Error loading orders: $e');
          _totalOrders = 0;
        }

        try {
          final prefs = await SharedPreferences.getInstance();
          final favoritesJson = prefs.getStringList('favorites') ?? [];
          _totalFavorites = favoritesJson.length;
        } catch (e) {
          print('Error loading favorites: $e');
          _totalFavorites = 0;
        }

        try {
          final reviewsSnapshot = await FirebaseFirestore.instance
              .collection('reviews')
              .where('userId', isEqualTo: user.uid)
              .get();

          _totalReviews = reviewsSnapshot.docs.length;
        } catch (e) {
          print('Error loading reviews: $e');
          _totalReviews = 0;
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();

        if (mounted) {
          setState(() {
            _userName =
                prefs.getString('user_name') ?? widget.name ?? 'Guest User';
            _userEmail = prefs.getString('user_email') ??
                widget.email ??
                'guest@example.com';
            _userImageUrl = prefs.getString('user_image') ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');

      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      String extractedName = 'User';
      if (user?.email != null && user!.email!.isNotEmpty) {
        extractedName = user.email!.split('@')[0];
        if (extractedName.isNotEmpty) {
          extractedName =
              extractedName[0].toUpperCase() + extractedName.substring(1);
        }
      }

      if (mounted) {
        setState(() {
          _userName =
              prefs.getString('user_name') ?? widget.name ?? extractedName;
          _userEmail = prefs.getString('user_email') ??
              widget.email ??
              user?.email ??
              'No email';
          _userImageUrl = prefs.getString('user_image') ?? '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  // دالة لحذف الصور القديمة (Cleanup)
  Future<void> _deleteOldProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.uid == null) return;

      final List<String> possibleFiles = [
        '${user!.uid}.jpg',
        '${user.uid}.jpeg',
        '${user.uid}.png',
        '${user.uid}.webp',
      ];

      await supabase.storage.from('profile-image').remove(possibleFiles);
      debugPrint('✅ Old images cleaned up');
    } catch (e) {
      debugPrint('Note: Cleanup warning: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    // 1. اختيار الصورة
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. حذف الصورة القديمة أولاً
      await _deleteOldProfileImage();

      // 3. قراءة الصورة كـ bytes (يشتغل على Web و Mobile)
      final bytes = await image.readAsBytes();

      // 4. الحصول على الامتداد
      final fileExt = image.name.split('.').last;
      final fileName = '${user.uid}.$fileExt';

      // 5. رفع الصورة على Supabase
      await supabase.storage.from('profile-image').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true, // الكتابة فوق لو الملف موجود
              contentType: 'image/$fileExt',
            ),
          );

      // 6. الحصول على رابط الصورة
      final imageUrlPath =
          supabase.storage.from('profile-image').getPublicUrl(fileName);

      // إضافة cache buster عشان الصورة تتحدث
      final finalUrl =
          '$imageUrlPath?v=${DateTime.now().millisecondsSinceEpoch}';

      print('✅ Image URL: $finalUrl');

      // 7. تحديث قاعدة البيانات في Supabase
      // await supabase
      //     .from('users')
      //     .update({'profile-image': finalUrl}).eq('id', user.uid);

      // 8. حفظ في SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('users', finalUrl);

      // 9. تحديث الواجهة
      setState(() {
        _userImageUrl = finalUrl;
        _isLoading = false;
      });

      if (mounted) {
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
      print('❌ Error uploading image: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          },
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
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshUserData,
              color: const Color(0xFF6C63FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Profile Image
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _userImageUrl.isEmpty
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF6C63FF),
                                      const Color(0xFF7C5CFF).withOpacity(0.7),
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
                          child: _userImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _userImageUrl,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          _userName.isNotEmpty &&
                                                  _userName != 'Loading...'
                                              ? _userName[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _userName.isNotEmpty &&
                                            _userName != 'Loading...'
                                        ? _userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
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
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats container
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.1),
                            const Color(0xFF7C5CFF).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Orders', _totalOrders.toString(),
                              Icons.shopping_bag),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem('Favorites',
                              _totalFavorites.toString(), Icons.favorite),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _buildStatItem(
                              'Reviews', _totalReviews.toString(), Icons.star),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

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
                            builder: (context) => EditProfilePage(
                              currentName: _userName,
                              currentEmail: _userEmail,
                            ),
                          ),
                        );
                        if (result == true) _refreshUserData();
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.favorite,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'My Favorites',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritesPage(
                              favouriteservice: FavoritesService(),
                            ),
                          ),
                        ).then((_) => _refreshUserData());
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xFF6C63FF),
                      title: 'My Orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomerOrdersPage()),
                        ).then((_) => _refreshUserData());
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: const Color.fromARGB(255, 166, 12, 232),
                      title: 'Logout',
                      titleColor: const Color.fromARGB(255, 166, 12, 232),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6C63FF),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
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
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            if (titleColor == null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}