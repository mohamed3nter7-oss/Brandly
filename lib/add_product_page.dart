import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  final bool isEditMode;

  const AddProductPage({
    super.key,
    this.productToEdit,
    this.isEditMode = false,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController();

  String _selectedCategory = 'Clothing';
  final List<String> _categories = [
    'Clothing',
    'Footwear',
    'Accessories',
    'Electronics',
    'Other'
  ];

  File? _selectedImage;
  String? _imageUrl;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode && widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!['name'] ?? '';
      _descriptionController.text = widget.productToEdit!['description'] ?? '';
      _priceController.text = widget.productToEdit!['price']?.toString() ?? '';
      _costController.text = widget.productToEdit!['cost']?.toString() ?? '0';
      _quantityController.text =
          widget.productToEdit!['stock']?.toString() ?? '';
      _selectedCategory = widget.productToEdit!['category'] ?? 'Clothing';
      _imageUrl = widget.productToEdit!['imageUrl'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // 📸 اختيار صورة من الجهاز
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
      print('❌ Image picker error: $e');
    }
  }

  // ☁️ رفع الصورة إلى Supabase Storage
  Future<String?> _uploadImageToSupabase() async {
    if (_selectedImage == null) return _imageUrl;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showError('User not authenticated');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'brands/$userId/$timestamp.jpg';

      print('📤 Uploading image to: $fileName');

      final fileBytes = await _selectedImage!.readAsBytes();

      // رفع الصورة
      await supabase.storage.from('product-images').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // الحصول على رابط الصورة
      final downloadUrl =
          supabase.storage.from('product-images').getPublicUrl(fileName);

      print('✅ Image uploaded successfully: $downloadUrl');

      return downloadUrl;
    } on StorageException catch (e) {
      // معالجة أخطاء Storage بشكل أفضل
      print('❌ Storage error: ${e.message} (${e.statusCode})');
      
      if (e.statusCode == '404') {
        _showError(
          'Storage bucket not found!\n'
          'Please create "product-images" bucket in Supabase Dashboard.',
        );
      } else if (e.statusCode == '403') {
        _showError('Permission denied. Check your Storage policies.');
      } else {
        _showError('Storage error: ${e.message}');
      }
      return null;
    } catch (e) {
      _showError('Error uploading image: $e');
      print('❌ Upload error: $e');
      return null;
    }
  }

  // ✅ حفظ المنتج في Firebase Firestore
  Future<void> _saveProductToFirebase(String imageUrl) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final price = double.tryParse(_priceController.text) ?? 0.0;
      final cost = double.tryParse(_costController.text) ?? 0.0;
      final profit = price - cost;

      final productData = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'price': price,
        'cost': cost,
        'stock': int.tryParse(_quantityController.text) ?? 0,
        'imageUrl': imageUrl,
        'sellerId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.isEditMode && widget.productToEdit != null) {
        // تحديث المنتج
        await _firestore
            .collection('brands')
            .doc(widget.productToEdit!['id'])
            .update(productData);

        print('✅ Product updated successfully');

        if (mounted) {
          _showSuccessWithProfit(
            'Product Updated!',
            profit,
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(
                context, {'action': 'update', 'product': productData});
          });
        }
      } else {
        // إضافة منتج جديد
        final docRef = await _firestore.collection('brands').add({
          ...productData,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final newProduct = {
          'id': docRef.id,
          ...productData,
        };

        print('✅ Product added successfully: ${docRef.id}');

        if (mounted) {
          _showSuccessWithProfit(
            'Product Added!',
            profit,
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context, {'action': 'add', 'product': newProduct});
          });
        }
      }
    } catch (e) {
      _showError('Error saving product: $e');
      print('❌ Firebase error: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من وجود صورة
    if (_selectedImage == null && (_imageUrl == null || _imageUrl!.isEmpty)) {
      _showError('Please add a product image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting product submission...');

      // رفع الصورة إلى Supabase Storage
      final imageUrl = await _uploadImageToSupabase();

      if (imageUrl == null || imageUrl.isEmpty) {
        _showError('Failed to upload image. Please try again.');
        return;
      }

      // حفظ المنتج في Firebase Firestore
      await _saveProductToFirebase(imageUrl);
    } catch (e) {
      _showError('Error: $e');
      print('❌ Submit error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessWithProfit(String title, double profit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Profit: \$${profit.toStringAsFixed(2)} per unit',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B5FED), Color(0xFF8B7FFF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isEditMode ? 'Edit Product' : 'Add Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PRODUCT NAME
                    const Text('Product Name', style: _labelStyle),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Vintage Denim Jacket',
                      validator: (v) =>
                          v!.isEmpty ? 'Product name is required' : null,
                    ),

                    const SizedBox(height: 24),

                    // CATEGORY
                    const Text('Category', style: _labelStyle),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF6B5FED),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // DESCRIPTION
                    const Text('Description', style: _labelStyle),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Product details...',
                      maxLines: 5,
                    ),

                    const SizedBox(height: 24),

                    // PRICE & COST
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price', style: _labelStyle),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _priceController,
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                prefix: '\$ ',
                                validator: (v) =>
                                    v!.isEmpty ? 'Price is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cost', style: _labelStyle),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _costController,
                                hint: '0.00',
                                keyboardType: TextInputType.number,
                                prefix: '\$ ',
                                validator: (v) =>
                                    v!.isEmpty ? 'Cost is required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // QUANTITY
                    const Text('Stock Quantity', style: _labelStyle),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _quantityController,
                      hint: '1',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? 'Quantity is required' : null,
                    ),

                    const SizedBox(height: 24),

                    // PHOTOS
                    const Text('Product Photo', style: _labelStyle),
                    const SizedBox(height: 8),
                    if (_selectedImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6B5FED),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6B5FED),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 50),
                                    SizedBox(height: 8),
                                    Text('Image not available'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6B5FED).withOpacity(0.1),
                            foregroundColor: const Color(0xFF6B5FED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFF6B5FED),
                                width: 2,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40),
                              SizedBox(height: 8),
                              Text('Add Photo'),
                            ],
                          ),
                        ),
                      ),
                    if (_selectedImage != null || (_imageUrl != null && _imageUrl!.isNotEmpty)) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          label: const Text('Change Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6B5FED).withOpacity(0.2),
                            foregroundColor: const Color(0xFF6B5FED),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // SUBMIT
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5FED),
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isEditMode
                                    ? 'Update Product'
                                    : 'Add Product',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TEXT FIELD BUILDER
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6B5FED),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// LABEL STYLE
const _labelStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF2D3748),
);