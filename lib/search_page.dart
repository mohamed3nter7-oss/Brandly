import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_profile.dart';

class BrandSearchPage extends StatefulWidget {
  const BrandSearchPage({super.key});

  @override
  State<BrandSearchPage> createState() => _BrandSearchPageState();
}

class Brand {
  final String id;
  final String name;
  final String category;
  final String image;
  final Color color;

  Brand({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.color,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Brand(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      category: data['category'] ?? 'Brand',
      image: data['imageUrl'] ?? '',
      color: _getColorFromString(data['color'] ?? '0xFF7C5CFF'),
    );
  }

  static Color _getColorFromString(String colorString) {
    try {
      if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      } else if (colorString.startsWith('#')) {
        return Color(int.parse('0xFF${colorString.substring(1)}'));
      }
    } catch (e) {
      print('خطأ في تحويل اللون: $e');
    }
    return const Color(0xFF7C5CFF);
  }
}

class _BrandSearchPageState extends State<BrandSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrandsFromFirebase();
  }

  Future<void> _loadBrandsFromFirebase() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final firestore = FirebaseFirestore.instance;

      final response = await firestore
          .collection('brands')
          .orderBy('createdAt', descending: true)
          .get();

      if (response.docs.isNotEmpty) {
        setState(() {
          _allBrands =
              response.docs.map((doc) => Brand.fromFirestore(doc)).toList();
          _filteredBrands = _allBrands;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('خطأ في جلب البرندات: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البرندات: $e')),
        );
      }
    }
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _allBrands;
      } else {
        _filteredBrands = _allBrands.where((brand) {
          return brand.name.toLowerCase().contains(query.toLowerCase()) ||
              brand.category.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
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
          'Brandly',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBrands,
              decoration: InputDecoration(
                hintText: 'Search brands...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterBrands('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C5CFF),
                    ),
                  )
                : _filteredBrands.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _allBrands.isEmpty
                                  ? 'No brands available'
                                  : 'No brands found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBrands.length,
                        itemBuilder: (context, index) {
                          final brand = _filteredBrands[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BrandProfilePage(
                                    brandId: brand.id,
                                    brandName: brand.name,
                                    // brandImage: brand.image,
                                    //brandColor: brand.color,
                                    // brandSubtitle: brand.category,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: brand.image.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          brand.image,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: brand.color,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  brand.name[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: brand.color,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            brand.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                title: Text(
                                  brand.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  brand.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
