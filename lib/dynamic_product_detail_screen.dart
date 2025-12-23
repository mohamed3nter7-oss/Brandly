import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_page.dart';

class DynamicProductDetailScreen extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String productImage;
  final String productDescription;

  const DynamicProductDetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
  });

  @override
  State<DynamicProductDetailScreen> createState() =>
      _DynamicProductDetailScreenState();
}

class _DynamicProductDetailScreenState
    extends State<DynamicProductDetailScreen> {
  String selectedColor = 'white';
  String selectedSize = 'S';
  bool isFavorite = false;
  bool isLoadingFavorite = true;

  final Map<String, Color> colors = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': Color(0xFFD3D3D3),
    'blue': Color(0xFF1B3B7E),
  };

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // ✅ تحقق إذا المنتج في الـ Favorites
  Future<void> _checkIfFavorite() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .where('productName', isEqualTo: widget.productName)
          .limit(1)
          .get();

      setState(() {
        isFavorite = snapshot.docs.isNotEmpty;
        isLoadingFavorite = false;
      });
    } catch (e) {
      setState(() => isLoadingFavorite = false);
    }
  }

  // ✅ إضافة/حذف من Favorites
  Future<void> _toggleFavorite() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      if (isFavorite) {
        // احذف من Favorites
        final snapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .where('productName', isEqualTo: widget.productName)
            .limit(1)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        setState(() => isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        // أضف للـ Favorites
        await FirebaseFirestore.instance.collection('favorites').add({
          'userId': userId,
          'productName': widget.productName,
          'productPrice': widget.productPrice,
          'productImage': widget.productImage,
          'productDescription': widget.productDescription,
          'createdAt': FieldValue.serverTimestamp(),
        });

        setState(() => isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites ❤️'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildProductImage(),
            _buildProductInfo(),
          ],
        ),
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          Row(
            children: [
              _circleButton(
                icon: Icons.shopping_bag_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _circleButton(
                icon: isLoadingFavorite
                    ? Icons.favorite_border
                    : (isFavorite ? Icons.favorite : Icons.favorite_border),
                iconColor: isFavorite ? Colors.red : Colors.black,
                onTap: isLoadingFavorite ? () {} : _toggleFavorite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onTap,
      ),
    );
  }

  // ================= IMAGE =================
  Widget _buildProductImage() {
    bool isNetwork = widget.productImage.startsWith('http');

    return Container(
      height: 300,
      width: double.infinity,
      color: const Color(0xFFF0F0F0),
      child: isNetwork
          ? Image.network(widget.productImage, fit: BoxFit.contain)
          : Image.asset(widget.productImage, fit: BoxFit.contain),
    );
  }

  // ================= INFO =================
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.productName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                widget.productPrice,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C5FFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.productDescription,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          _buildSizeSection(),
        ],
      ),
    );
  }

  // ================= COLOR =================
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: colors.entries.map((e) {
            bool selected = selectedColor == e.key;
            return GestureDetector(
              onTap: () => setState(() => selectedColor = e.key),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? const Color(0xFF7C5FFC) : Colors.grey,
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= SIZE =================
  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            bool selected = selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => selectedSize = size),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF7C5FFC) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================= ADD TO CART =================
  Widget _buildAddToCartButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C5FFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            try {
              // ✅ جيب الـ userId
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login first')),
                );
                return;
              }

              double price =
                  double.parse(widget.productPrice.replaceAll('\$', ''));

              // ✅ أضف المنتج مع userId
              await FirebaseFirestore.instance.collection('cart').add({
                'userId': userId, // 🔥 ده المهم!
                'name': widget.productName,
                'image': widget.productImage,
                'size': selectedSize,
                'color': selectedColor,
                'price': price,
                'quantity': 1,
                'createdAt': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart! 🛒'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );

              // انتقل للـ Cart بعد ثانية واحدة
              await Future.delayed(const Duration(seconds: 1));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}