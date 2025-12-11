import 'package:brandly4/favourite_page.dart';
import 'package:flutter/material.dart';
import 'brand_profile.dart';
import 'profile.dart';
import 'search_page.dart';
import 'brand_model.dart';
import 'favourite_service.dart';
import 'card_page.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  int _selectedIndex = 0;
  final FavoritesService _favoritesService = FavoritesService();

  final List<Map<String, dynamic>> featuredBrands = [
    {
      'name': 'Eclat Je',
      'subtitle': 'Handcraft',
      'image': 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800',
      'color': Color(0xFFE8D5C4),
    },
    {
      'name': 'Luna Style',
      'subtitle': 'Modern Fashion',
      'image': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
      'color': Color(0xFFD4A574),
    },
    {
      'name': 'Nova Collection',
      'subtitle': 'Premium Wear',
      'image': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
      'color': Color(0xFF2B7A78),
    },
    {
      'name': 'Elite Trends',
      'subtitle': 'Luxury Brand',
      'image': 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800',
      'color': Color(0xFFA8B5A0),
    },
  ];

  final List<Map<String, dynamic>> allBrands = [
    {
      'name': 'Sisters Luxe',
      'subtitle': 'Fashion',
      'image': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800',
      'color': Color(0xFFB8A591),
    },
    {
      'name': 'Opaline Jewelry',
      'subtitle': 'Jewelry',
      'image': 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800',
      'color': Color(0xFFD4A574),
    },
    {
      'name': 'ModeStride',
      'subtitle': 'Shoes',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
      'color': Color(0xFFE8E8E8),
    },
    {
      'name': 'Velvet Case',
      'subtitle': 'Bags',
      'image': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800',
      'color': Color(0xFF2B7A78),
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesPage()),
      ).then((_) {
        setState(() {});
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyProfilePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 20),
          ),
        ),
        title: const Text(
          'Brandly',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrandSearchPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Featured Brands',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: featuredBrands.length,
                itemBuilder: (context, index) {
                  final brand = featuredBrands[index];
                  return _buildFeaturedBrandCard(brand);
                },
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'All Brands',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: allBrands.length,
                itemBuilder: (context, index) {
                  final brand = allBrands[index];
                  return _buildBrandCard(brand);
                },
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF7C5CFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeaturedBrandCard(Map<String, dynamic> brand) {
    final isFav = _favoritesService.isFavorite(brand['name']);

    return GestureDetector(
      onTap: () {
        if (brand['name'] == 'Luna Style') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BrandProfilePage()),
          );
        }
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      brand['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: brand['color'],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          brand['name'].substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: _isDark(brand['color']) ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand['name'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            brand['subtitle'],
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isFav) {
                      _favoritesService.removeFavorite(brand['name']);
                    } else {
                      final brandModel = BrandModel(
                        name: brand['name'],
                        subtitle: brand['subtitle'],
                        image: brand['image'],
                        color: brand['color'],
                      );
                      _favoritesService.addFavorite(brandModel);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: const Color.fromARGB(255, 121, 9, 196),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCard(Map<String, dynamic> brand) {
    final isFav = _favoritesService.isFavorite(brand['name']);

    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  brand['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: brand['color'],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            brand['name'].substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: _isDark(brand['color']) ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        brand['name'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        brand['subtitle'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isFav) {
                  _favoritesService.removeFavorite(brand['name']);
                } else {
                  final brandModel = BrandModel(
                    name: brand['name'],
                    subtitle: brand['subtitle'],
                    image: brand['image'],
                    color: brand['color'],
                  );
                  _favoritesService.addFavorite(brandModel);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: const Color.fromARGB(255, 167, 3, 189),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
}