import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _brandNameController = TextEditingController();
  String selectedRole = "customer";
  String selectedCategory = "Fashion";
  bool _isLoading = false;

  final List<String> categories = [
    'Fashion',
    'Electronics',
    'Beauty',
    'Sports',
    'Home & Garden',
    'Food & Beverage',
    'Books',
    'Toys',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // تحقق من brand name للـ sellers
    if (selectedRole == 'seller' && _brandNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your brand name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ إنشاء حساب المستخدم
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final uid = credential.user!.uid;

      // 2️⃣ حفظ بيانات المستخدم في users collection
      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'brandName': _brandNameController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      // 3️⃣ إذا كان seller، إنشاء brand document
      if (selectedRole == 'seller') {
        final brandRef =
            await FirebaseFirestore.instance.collection('brand').add({
          'name': _brandNameController.text.trim(),
          'category': selectedCategory,
          'sellerId': uid,
          'sellerName': _nameController.text.trim(),
          'sellerEmail': _emailController.text.trim(),
          'description': '',
          'logo': '',
          'image': '', // Add image field for brand cover
          'isActive': true,
          'rating': 0.0,
          'totalOrders': 0,
          'totalRevenue': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // تحديث user document بالـ brandId
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'brandId': brandRef.id});
      }

      if (!mounted) return;

      // 4️⃣ رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // 5️⃣ الانتقال حسب نوع الحساب
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (selectedRole == 'customer') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/seller-home');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak (min 6 characters)';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email format';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5), // Lavender light
              Color(0xFFE1BEE7), // Lavender medium
              Color(0xFFCE93D8), // Lavender deep
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B5FED).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 50,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 105, 65, 154),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Join us today!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Role Selection
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedRole = "customer"),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedRole == "customer"
                                      ? const Color(0xFF9C27B0)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Customer",
                                    style: TextStyle(
                                      color: selectedRole == "customer"
                                          ? Colors.white
                                          : const Color(0xFF9C27B0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedRole = "seller"),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedRole == "seller"
                                      ? const Color(0xFF9C27B0)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Seller",
                                    style: TextStyle(
                                      color: selectedRole == "seller"
                                          ? Colors.white
                                          : const Color(0xFF9C27B0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      label: "Full Name",
                      icon: Icons.person,
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val!.isEmpty) return 'Please enter email';
                        if (!val.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (val) {
                        if (val!.isEmpty) return 'Please enter password';
                        if (val.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Brand Name Field (only for sellers)
                    if (selectedRole == 'seller') ...[
                      _buildTextField(
                        controller: _brandNameController,
                        label: "Brand Name",
                        icon: Icons.store,
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter brand name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          // initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Brand Category',
                            prefixIcon: const Icon(Icons.category,
                                color: Color(0xFF9C27B0)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedCategory = value!);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 30),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF9C27B0).withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Color(0xFF6A1B9A)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xFF9C27B0),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF9C27B0)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
