import 'package:brandly4/card_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favourite_page.dart';
import 'search_page.dart';
import 'brand_model.dart';
import 'favourite_service.dart';
import 'C_profile.dart';
import 'brand_profile.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  int _selectedIndex = 0;
  final FavoritesService _favoritesService = FavoritesService();

  late final List<Widget> _pages;
  late final HomePageWidget _homeWidget;

  @override
  void initState() {
    super.initState();
    _homeWidget = HomePageWidget(favoritesService: _favoritesService);

    _pages = [
      _homeWidget,
      FavoritesPage(favouriteservice: _favoritesService),
      const MyProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                    builder: (context) => const BrandSearchPage()),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF7C5CFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// ====================== HomePageWidget ======================
class HomePageWidget extends StatefulWidget {
  final FavoritesService favoritesService;
  const HomePageWidget({required this.favoritesService, super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  List<Map<String, dynamic>> featuredBrands = [];
  List<Map<String, dynamic>> allBrands = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() => isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;

      // 🔥 جلب البيانات من collection الجديد
      final response = await firestore
          .collection('brand') // الاسم الجديد للـ collection
          .orderBy('createdAt', descending: true)
          .get();

      final loadedBrands = response.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'subtitle': data['category'] ?? 'Brand',
          'image': data['image'] ?? '',
          'color': _getColorFromString(data['color'] ?? '0xFF7C5CFF'),
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        allBrands = loadedBrands;
        featuredBrands = loadedBrands.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البرندات: $e')),
      );
    }
  }

  Color _getColorFromString(String colorString) {
    try {
      if (colorString.startsWith('0x')) return Color(int.parse(colorString));
      if (colorString.startsWith('#')) {
        return Color(int.parse('0xFF${colorString.substring(1)}'));
      }
    } catch (_) {}
    return const Color(0xFF7C5CFF);
  }

  String _getFirstLetter(String? name) =>
      (name?.isNotEmpty ?? false) ? name![0].toUpperCase() : '?';

  bool _isDark(Color color) => color.computeLuminance() < 0.5;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C5CFF)))
        : RefreshIndicator(
            onRefresh: _loadBrands,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  if (featuredBrands.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Featured Brands',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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
                          return _buildFeaturedBrandCard(featuredBrands[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'All Brands',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  allBrands.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 60,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No brands available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: allBrands.length,
                            itemBuilder: (context, index) {
                              return _buildBrandCard(allBrands[index]);
                            },
                          ),
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }

  Widget _buildFeaturedBrandCard(Map<String, dynamic> brand) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFav = widget.favoritesService.isFavorite(brand['name']);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BrandProfilePage(
                  brandId: brand['id'],
                  brandName: brand['name'],
                ),
              ),
            );
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
                          brand['image'] ?? '',
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
                              _getFirstLetter(brand['name']),
                              style: TextStyle(
                                color: _isDark(brand['color'])
                                    ? Colors.white
                                    : Colors.black,
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
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
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
                          widget.favoritesService.removeFavorite(brand['name']);
                        } else {
                          final brandModel = BrandModel(
                            id: brand['id'],
                            name: brand['name'],
                            subtitle: brand['subtitle'],
                            image: brand['image'],
                            color: brand['color'],
                          );
                          widget.favoritesService.addFavorite(brandModel);
                        }
                        isFav = !isFav;
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
                              blurRadius: 8)
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
      },
    );
  }

  Widget _buildBrandCard(Map<String, dynamic> brand) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFav = widget.favoritesService.isFavorite(brand['name']);

        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrandProfilePage(
                      brandId: brand['id'],
                      brandName: brand['name'],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      brand['image'] ?? '',
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
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6)
                          ],
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
                                _getFirstLetter(brand['name']),
                                style: TextStyle(
                                  color: _isDark(brand['color'])
                                      ? Colors.white
                                      : Colors.black,
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
                      widget.favoritesService.removeFavorite(brand['name']);
                    } else {
                      final brandModel = BrandModel(
                        id: brand['id'],
                        name: brand['name'],
                        subtitle: brand['subtitle'],
                        image: brand['image'],
                        color: brand['color'],
                      );
                      widget.favoritesService.addFavorite(brandModel);
                    }
                    isFav = !isFav;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2), blurRadius: 8)
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
      },
    );
  }
}
