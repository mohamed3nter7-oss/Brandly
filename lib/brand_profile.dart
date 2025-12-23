import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dynamic_product_detail_screen.dart';
import 'favourite_page.dart';
import 'home_page.dart';
import 'C_profile.dart';
import 'favourite_service.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? data['image_url'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

class BrandProfilePage extends StatefulWidget {
  final String brandId;
  final String brandName;

  const BrandProfilePage({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<BrandProfilePage> createState() => _BrandProfilePageState();
}

class _BrandProfilePageState extends State<BrandProfilePage> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  Map<String, dynamic>? brandData;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadBrandData();
  }

  Future<void> _loadBrandData() async {
    try {
      setState(() => _isLoading = true);

      /// 🔹 Brand data
      final brandDoc = await FirebaseFirestore.instance
          .collection('brand')
          .doc(widget.brandId)
          .get();

      if (!brandDoc.exists) return;

      brandData = brandDoc.data() as Map<String, dynamic>;
      final ownerId = brandData!['sellerId'];

      /// 🔹 Products (from brands collection)
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('brands')
          .where('sellerId', isEqualTo: ownerId)
          .get();

      products = productsSnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const NewHomePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesPage(
            favouriteservice: FavoritesService(),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MyProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            )
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildContent(),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ================= APP BAR =================
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.deepPurple[300],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: Image.network(
          brandData?['image'] ??
              brandData?['coverImage'] ??
              'https://plus.unsplash.com/premium_photo-1664202526559-e21e9c0fb46a',
          fit: BoxFit.cover,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ================= CONTENT =================
  SliverToBoxAdapter _buildContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              brandData?['name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              brandData?['description'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Our Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            products.isEmpty
                ? const Text('No products yet')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.63,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (_, i) => _buildProductCard(products[i]),
                  ),
          ],
        ),
      ),
    );
  }

  // ================= PRODUCT CARD =================
  Widget _buildProductCard(Product product) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DynamicProductDetailScreen(
              productName: product.name,
              productPrice: '\$${product.price}',
              productImage: product.imageUrl,
              productDescription: product.description,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('\$${product.price}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xFF7C5CFF),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline), label: 'Favorites'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
