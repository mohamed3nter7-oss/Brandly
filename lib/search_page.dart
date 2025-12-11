import 'package:flutter/material.dart';

class BrandSearchPage extends StatefulWidget {
  const BrandSearchPage({super.key});

  @override
  State<BrandSearchPage> createState() => _BrandSearchPageState();
}

// ----------------------
// 🔥 الكلاس اللي ناقص
// ----------------------
class Brand {
  final String name;
  final String category;
  final String image;

  Brand({
    required this.name,
    required this.category,
    required this.image,
  });
}

class _BrandSearchPageState extends State<BrandSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _filteredBrands = _allBrands;
  }

  void _loadBrands() {
    _allBrands = [
      Brand(
        name: 'Eclat Je',
        category: 'Handcraft',
        image: 'assets/eclat_je.jpg',
      ),
      Brand(
        name: 'Luna Style',
        category: 'Modern Fashion',
        image: 'assets/luna_style.jpg',
      ),
      Brand(
        name: 'Nova Collection',
        category: 'Premium Wear',
        image: 'assets/nova_collection.jpg',
      ),
      Brand(
        name: 'Elite Trends',
        category: 'Luxury Brand',
        image: 'assets/elite_trends.jpg',
      ),
      Brand(
        name: 'Sisters Luxe',
        category: 'Fashion',
        image: 'assets/sisters_luxe.jpg',
      ),
      Brand(
        name: 'Opaline Jewelry',
        category: 'Jewelry',
        image: 'assets/opaline_jewelry.jpg',
      ),
      Brand(
        name: 'ModeStride',
        category: 'Shoes',
        image: 'assets/modestride.jpg',
      ),
      Brand(
        name: 'Velvet Case',
        category: 'Bags',
        image: 'assets/velvet_case.jpg',
      ),
    ];
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            child: _filteredBrands.isEmpty
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
                          'No brands found',
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.primaries[
                                index % Colors.primaries.length],
                            child: Text(
                              brand.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening ${brand.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
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
