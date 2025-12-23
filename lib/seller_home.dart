import 'seller_profile_page.dart';
import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'my_products_page.dart';
import 'revenue_page.dart';
import '../orders_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  String brandName = "Loading...";
  String brandCategory = "";
  int totalOrders = 0;
  int totalProducts = 0;
  double totalRevenue = 0.0;
  double netProfit = 0.0;
  int returnsCount = 0;
  int _selectedIndex = 0;
  bool isLoading = true;
  String? brandId;

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  // 🔥 جلب بيانات البائع والبراند من Firebase
  Future<void> _loadSellerData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          isLoading = false;
          brandName = "Guest";
        });
        return;
      }

      // 1️⃣ جلب بيانات البراند الخاص بالبائع
      final brandsQuery = await FirebaseFirestore.instance
          .collection('brand')
          .where('sellerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (brandsQuery.docs.isNotEmpty) {
        final brandDoc = brandsQuery.docs.first;
        brandId = brandDoc.id;
        final brandData = brandDoc.data();

        setState(() {
          brandName = brandData['name'] ?? 'Brandly Store';
          brandCategory = brandData['category'] ?? '';
        });

        // 2️⃣ جلب عدد المنتجات من sub-collection
        final productsSnapshot = await FirebaseFirestore.instance
            .collection('brands')
            .doc(brandId)
            .collection('products')
            .get();

        setState(() {
          totalProducts = productsSnapshot.docs.length;
        });

        // 3️⃣ جلب الطلبات الخاصة بالبراند
        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('brandId', isEqualTo: brandId)
            .get();

        double revenue = 0;
        double profit = 0;
        int returns = 0;
        int completedOrders = 0;

        // حساب الإحصائيات من الطلبات
        for (var order in ordersSnapshot.docs) {
          final data = order.data();
          final status = data['status']?.toString().toLowerCase() ?? '';

          if (status == 'completed' || status == 'delivered') {
            completedOrders++;

            // حساب الإيرادات
            final total = (data['total'] ?? 0).toDouble();
            revenue += total;

            // حساب الربح (لو موجود)
            final cost = (data['cost'] ?? 0).toDouble();
            profit += (total - cost);
          } else if (status == 'returned' || status == 'cancelled') {
            returns++;
          }
        }

        setState(() {
          totalOrders = completedOrders;
          totalRevenue = revenue;
          netProfit =
              profit > 0 ? profit : revenue * 0.3; // 30% profit margin افتراضي
          returnsCount = returns;
        });
      } else {
        // لو مفيش براند، استخدم اسم المستخدم
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        setState(() {
          brandName = userDoc.data()?['name'] ?? 'Seller';
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading seller data: $e');
      setState(() {
        isLoading = false;
        brandName = "Error loading data";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return const MyProductsPage();
      case 2:
        return const OrderHistoryPage();
      case 3:
        return const SellerMyProfilePage();
      default:
        return _buildDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Brandly Seller',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B5FED),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _loadSellerData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B5FED),
              ),
            )
          : _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6B5FED),
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    return RefreshIndicator(
      onRefresh: _loadSellerData,
      color: const Color(0xFF6B5FED),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    brandName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (brandCategory.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        brandCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Products',
                        totalProducts.toString(),
                        Icons.inventory_2_outlined,
                      ),
                      _buildStatCard(
                        'Orders',
                        totalOrders.toString(),
                        Icons.shopping_bag_outlined,
                      ),
                      _buildStatCard(
                        'Revenue',
                        '\$${totalRevenue.toStringAsFixed(0)}',
                        Icons.monetization_on_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Revenue Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RevenueDashboard(),
                    ),
                  ).then((_) {
                    _loadSellerData();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Revenue',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'View Details →',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Additional Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Net Profit',
                      '\$${netProfit.toStringAsFixed(2)}',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Returns',
                      returnsCount.toString(),
                      Icons.keyboard_return,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCard(
                        context,
                        'Add Product',
                        Icons.add_box_outlined,
                        Colors.deepPurple,
                      ),
                      _buildActionCard(
                        context,
                        'My Products',
                        Icons.inventory_outlined,
                        Colors.blue,
                      ),
                      _buildActionCard(
                        context,
                        'View Orders',
                        Icons.shopping_bag_outlined,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == 'Add Product') {
            if (brandId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please create a brand first'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ).then((_) => _loadSellerData());
          } else if (title == 'My Products') {
            setState(() => _selectedIndex = 1);
          } else if (title == 'View Orders') {
            setState(() => _selectedIndex = 2);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
