/*import 'package:flutter/material.dart';
import 'card_page.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedColor = 'white';
  String selectedSize = 'S';
  bool isFavorite = false;

  // 🎨 صور المنتج حسب اللون
  final Map<String, String> productImages = {
    'white': 'assets/images/B1.jpg',
    'black': 'assets/images/B1_black.jpg', // ضيفي الصورة السودا
    'grey': 'assets/images/B1_grey.jpg',   // ضيفي الصورة الرمادي
    'blue': 'assets/images/B1_blue.jpg',   // ضيفي الصورة الأزرق
  };

  final Map<String, Color> colors = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': const Color(0xFFD3D3D3),
    'blue': const Color(0xFF1B3B7E),
  };

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  final List<Map<String, String>> relatedProducts = [
    {
      'title': 'Classic Tee',
      'price': '\$35.00',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop',
      'description': 'A timeless classic white t-shirt made from premium cotton. Perfect for everyday wear and easy to style.',
    },
    {
      'title': 'Cozy Hoodie',
      'price': '\$65.00',
      'image': 'assets/images/B2.jpg',
      'description': 'Stay warm and comfortable with this soft hoodie. Features a relaxed fit and durable construction.',
    },
    {
      'title': 'Retro Kicks',
      'price': '\$150.00',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop',
      'description': 'Classic retro sneakers with modern comfort. Perfect for casual outings and everyday adventures.',
    },
  ];

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
            _buildProductInfo()
          ],
        ),
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🖼 الصورة بتتغير حسب اللون المختار
  Widget _buildProductImage() {
    return Container(
      color: const Color(0xFFF0F0F0),
      height: 300,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Image.asset(
          productImages[selectedColor] ?? 'assets/images/B1.jpg',
          key: ValueKey(selectedColor), // مهم للـ animation
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // لو الصورة مش موجودة، بنعرض الصورة الأساسية
            return Image.asset(
              'assets/images/B1.jpg',
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndPrice(),
          const SizedBox(height: 12),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          _buildSizeSection(),
          const SizedBox(height: 24),
          _buildProductDetailsSection(),
          const SizedBox(height: 24),
          _buildYouMayAlsoLike(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(
          child: Text(
            'Minimal Sneaker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '\$120.00',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C5FFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Text(
      'Crafted for the modern minimalist, these sneakers blend timeless design with unparalleled comfort.',
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: colors.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildColorOption(e.key, e.value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String name, Color value) {
    bool selected = selectedColor == name;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = name),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value,
          border: Border.all(
            color: selected ? const Color(0xFF7C5FFC) : Colors.grey,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            return _buildSizeOption(size);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    bool selected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5FFC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Product Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Icon(Icons.expand_more),
      ],
    );
  }

  Widget _buildYouMayAlsoLike() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You may also like',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: relatedProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DynamicProductDetailScreen(
                          productName: product['title']!,
                          productPrice: product['price']!,
                          productImage: product['image']!,
                          productDescription: product['description']!,
                        ),
                      ),
                    );
                  },
                  child: _buildProductCard(
                    title: product['title']!,
                    price: product['price']!,
                    imageUrl: product['image']!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String imageUrl,
  }) {
    bool isNetworkImage = imageUrl.startsWith('http');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: isNetworkImage 
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Image.asset(imageUrl, fit: BoxFit.cover),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(price, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة المنتج إلى السلة ✓'),
                backgroundColor: Color(0xFF7C5FFC),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// صفحة ديناميكية لعرض تفاصيل أي منتج
// ==========================================
class DynamicProductDetailScreen extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String productImage;
  final String productDescription;

  const DynamicProductDetailScreen({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
  }) : super(key: key);

  @override
  State<DynamicProductDetailScreen> createState() =>
      _DynamicProductDetailScreenState();
}

class _DynamicProductDetailScreenState
    extends State<DynamicProductDetailScreen> {
  String selectedColor = 'white';
  String selectedSize = 'S';
  bool isFavorite = false;

  final Map<String, Color> colors = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': const Color(0xFFD3D3D3),
    'blue': const Color(0xFF1B3B7E),
  };

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    bool isNetworkImage = widget.productImage.startsWith('http');
    
    return Container(
      color: const Color(0xFFF0F0F0),
      height: 300,
      width: double.infinity,
      child: isNetworkImage
          ? Image.network(
              widget.productImage,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                );
              },
            )
          : Image.asset(
              widget.productImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                );
              },
            ),
    );
  }

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
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          _buildSizeSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: colors.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildColorOption(e.key, e.value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String name, Color value) {
    bool selected = selectedColor == name;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = name),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value,
          border: Border.all(
            color: selected ? const Color(0xFF7C5FFC) : Colors.grey,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            return _buildSizeOption(size);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    bool selected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5FFC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمت إضافة ${widget.productName} إلى السلة ✓'),
                backgroundColor: const Color(0xFF7C5FFC),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}*/


/*import 'package:flutter/material.dart';
import 'card_page.dart';
import 'brand_model.dart';
import 'favourite_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedColor = 'white';
  String selectedSize = 'S';
  late bool isFavorite;
  final FavoritesService _favoritesService = FavoritesService();

  final Map<String, String> productImages = {
    'white': 'assets/images/B1.jpg',
    'black': 'assets/images/B1_black.jpg',
    'grey': 'assets/images/B1_grey.jpg',
    'blue': 'assets/images/B1_blue.jpg',
  };

  final Map<String, Color> colors = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': const Color(0xFFD3D3D3),
    'blue': const Color(0xFF1B3B7E),
  };

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  final List<Map<String, String>> relatedProducts = [
    {
      'title': 'Classic Tee',
      'price': '\$35.00',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop',
      'description': 'A timeless classic white t-shirt made from premium cotton. Perfect for everyday wear and easy to style.',
    },
    {
      'title': 'Cozy Hoodie',
      'price': '\$65.00',
      'image': 'assets/images/B2.jpg',
      'description': 'Stay warm and comfortable with this soft hoodie. Features a relaxed fit and durable construction.',
    },
    {
      'title': 'Retro Kicks',
      'price': '\$150.00',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300&h=300&fit=crop',
      'description': 'Classic retro sneakers with modern comfort. Perfect for casual outings and everyday adventures.',
    },
  ];

  @override
  void initState() {
    super.initState();
    isFavorite = _favoritesService.isFavorite('Minimal Sneaker');
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
            _buildProductInfo()
          ],
        ),
      ),
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        _favoritesService.removeFavorite('Minimal Sneaker');
                        isFavorite = false;
                      } else {
                        final brandModel = BrandModel(
                          name: 'Minimal Sneaker',
                          subtitle: 'Premium Product',
                          image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
                          color: Colors.purple,
                        );
                        _favoritesService.addFavorite(brandModel);
                        isFavorite = true;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      color: const Color(0xFFF0F0F0),
      height: 300,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Image.asset(
          productImages[selectedColor] ?? 'assets/images/B1.jpg',
          key: ValueKey(selectedColor),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/B1.jpg',
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndPrice(),
          const SizedBox(height: 12),
          _buildDescription(),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          _buildSizeSection(),
          const SizedBox(height: 24),
          _buildProductDetailsSection(),
          const SizedBox(height: 24),
          _buildYouMayAlsoLike(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(
          child: Text(
            'Minimal Sneaker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '\$120.00',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C5FFC),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Text(
      'Crafted for the modern minimalist, these sneakers blend timeless design with unparalleled comfort.',
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: colors.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildColorOption(e.key, e.value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String name, Color value) {
    bool selected = selectedColor == name;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = name),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value,
          border: Border.all(
            color: selected ? const Color(0xFF7C5FFC) : Colors.grey,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            return _buildSizeOption(size);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    bool selected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5FFC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Product Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Icon(Icons.expand_more),
      ],
    );
  }

  Widget _buildYouMayAlsoLike() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You may also like',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: relatedProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DynamicProductDetailScreen(
                          productName: product['title']!,
                          productPrice: product['price']!,
                          productImage: product['image']!,
                          productDescription: product['description']!,
                        ),
                      ),
                    );
                  },
                  child: _buildProductCard(
                    title: product['title']!,
                    price: product['price']!,
                    imageUrl: product['image']!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String imageUrl,
  }) {
    bool isNetworkImage = imageUrl.startsWith('http');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: isNetworkImage 
              ? Image.network(imageUrl, fit: BoxFit.cover)
              : Image.asset(imageUrl, fit: BoxFit.cover),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(price, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة المنتج إلى السلة ✓'),
                backgroundColor: Color(0xFF7C5FFC),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

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
  late bool isFavorite;
  final FavoritesService _favoritesService = FavoritesService();

  final Map<String, Color> colors = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': const Color(0xFFD3D3D3),
    'blue': const Color(0xFF1B3B7E),
  };

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    isFavorite = _favoritesService.isFavorite(widget.productName);
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        _favoritesService.removeFavorite(widget.productName);
                        isFavorite = false;
                      } else {
                        final brandModel = BrandModel(
                          name: widget.productName,
                          subtitle: widget.productPrice,
                          image: widget.productImage,
                          color: Colors.purple,
                        );
                        _favoritesService.addFavorite(brandModel);
                        isFavorite = true;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    bool isNetworkImage = widget.productImage.startsWith('http');
    
    return Container(
      color: const Color(0xFFF0F0F0),
      height: 300,
      width: double.infinity,
      child: isNetworkImage
          ? Image.network(
              widget.productImage,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                );
              },
            )
          : Image.asset(
              widget.productImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                );
              },
            ),
    );
  }

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
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          _buildSizeSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: colors.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildColorOption(e.key, e.value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String name, Color value) {
    bool selected = selectedColor == name;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = name),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value,
          border: Border.all(
            color: selected ? const Color(0xFF7C5FFC) : Colors.grey,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            return _buildSizeOption(size);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    bool selected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5FFC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمت إضافة ${widget.productName} إلى السلة ✓'),
                backgroundColor: const Color(0xFF7C5FFC),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'card_page.dart';

// ==========================================
// صفحة ديناميكية لعرض تفاصيل أي منتج
// ==========================================
class DynamicProductDetailScreen extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String productImage;
  final String productDescription;

  const DynamicProductDetailScreen({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
  }) : super(key: key);

  @override
  State<DynamicProductDetailScreen> createState() =>
      _DynamicProductDetailScreenState();
}

class _DynamicProductDetailScreenState
    extends State<DynamicProductDetailScreen> {
  String selectedColor = 'white';
  String selectedSize = 'S';
  bool isFavorite = false;

  final Map<String, Color> colors = {
    'white': Colors.white,
    'black': Colors.black,
    'grey': const Color(0xFFD3D3D3),
    'blue': const Color(0xFF1B3B7E),
  };

  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

  // المنتجات المقترحة
  final List<Map<String, String>> relatedProducts = [
    {
      'title': 'Classic Tee',
      'price': '\$35.00',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop',
      'description': 'A timeless classic white t-shirt made from premium cotton. Perfect for everyday wear and easy to style.',
    },
    {
      'title': 'Cozy Hoodie',
      'price': '\$65.00',
      'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=300&h=300&fit=crop',
      'description': 'Stay warm and comfortable with this soft hoodie. Features a relaxed fit and durable construction.',
    },
    {
      'title': 'Retro Kicks',
      'price': '\$150.00',
      'image': 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=300&h=300&fit=crop',
      'description': 'Classic retro sneakers with modern comfort. Perfect for casual outings and everyday adventures.',
    },
  ];

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    bool isNetworkImage = widget.productImage.startsWith('http');
    
    return Container(
      color: const Color(0xFFF0F0F0),
      height: 300,
      width: double.infinity,
      child: isNetworkImage
          ? Image.network(
              widget.productImage,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                );
              },
            )
          : Image.asset(
              widget.productImage,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                );
              },
            ),
    );
  }

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
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          _buildSizeSection(),
          const SizedBox(height: 24),
          _buildProductDetailsSection(),
          const SizedBox(height: 24),
          _buildYouMayAlsoLike(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: colors.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildColorOption(e.key, e.value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(String name, Color value) {
    bool selected = selectedColor == name;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = name),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value,
          border: Border.all(
            color: selected ? const Color(0xFF7C5FFC) : Colors.grey,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            return _buildSizeOption(size);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size) {
    bool selected = selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = size),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5FFC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Product Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Icon(
              Icons.expand_more,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouMayAlsoLike() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You may also like',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: relatedProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    // فتح صفحة تفاصيل المنتج المقترح
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DynamicProductDetailScreen(
                          productName: product['title']!,
                          productPrice: product['price']!,
                          productImage: product['image']!,
                          productDescription: product['description']!,
                        ),
                      ),
                    );
                  },
                  child: _buildProductCard(
                    title: product['title']!,
                    price: product['price']!,
                    imageUrl: product['image']!,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String imageUrl,
  }) {
    bool isNetworkImage = imageUrl.startsWith('http');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: isNetworkImage 
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 140,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          price,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمت إضافة ${widget.productName} إلى السلة ✓'),
                backgroundColor: const Color(0xFF7C5FFC),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}