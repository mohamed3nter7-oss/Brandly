import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RevenueDashboard extends StatefulWidget {
  final double totalRevenue;
  final int totalSales;
  final double avgOrderValue;
  final int returnsCount;
  final double netProfit;

  const RevenueDashboard({
    super.key,
    this.totalRevenue = 0,
    this.totalSales = 0,
    this.avgOrderValue = 0,
    this.returnsCount = 0,
    this.netProfit = 0,
  });

  @override
  State<RevenueDashboard> createState() => _RevenueDashboardState();
}

class _RevenueDashboardState extends State<RevenueDashboard> {
  late double totalRevenue;
  late int totalSales;
  late double avgOrderValue;
  late int returnsCount;
  late double netProfit;
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // استخدام البيانات المُمررة من الـ parent widget
    totalRevenue = widget.totalRevenue;
    totalSales = widget.totalSales;
    avgOrderValue = widget.avgOrderValue;
    returnsCount = widget.returnsCount;
    netProfit = widget.netProfit;
  }

  // 🔥 جلب بيانات الـ Revenue من Firebase
  Future<void> _loadRevenueDataFromFirebase() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // جلب الطلبات للـ seller الحالي
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: userId)
          .get();

      double revenue = 0;
      int sales = 0;
      int returns = 0;
      double profit = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        final total = (data['total'] ?? 0).toDouble();
        final orderProfit = (data['profit'] ?? total * 0.3).toDouble();

        if (status == 'Delivered' ||
            status == 'Processing' ||
            status == 'Shipped' ||
            status == 'completed') {
          revenue += total;
          profit += orderProfit;
          sales++;
        } else if (status == 'Cancelled' ||
            status == 'Returned' ||
            status == 'returned' ||
            status == 'cancelled') {
          returns++;
        }
      }

      setState(() {
        totalRevenue = revenue;
        totalSales = sales;
        avgOrderValue = sales > 0 ? revenue / sales : 0;
        returnsCount = returns;
        netProfit = profit;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading revenue: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading revenue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // محاكاة إضافة أوردر جديد (للتجربة)
  void _simulateNewOrder() {
    setState(() {
      double newOrderValue = 150 + (totalSales * 10);
      totalRevenue += newOrderValue;
      totalSales++;
      avgOrderValue = totalRevenue / totalSales;
      netProfit = totalRevenue * 0.25;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'New order added! +\$${(150 + (totalSales * 10)).toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Revenue Details'),
        backgroundColor: const Color(0xFF6B5FED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRevenueDataFromFirebase,
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF9333EA)
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Revenue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _row(
                              'TOTAL REVENUE',
                              '\$${totalRevenue.toStringAsFixed(2)}',
                              Icons.trending_up,
                              Colors.green,
                            ),
                            _row(
                              'TOTAL SALES',
                              totalSales.toString(),
                              Icons.shopping_bag,
                              Colors.blue,
                            ),
                            _row(
                              'AVG ORDER VALUE',
                              '\$${avgOrderValue.toStringAsFixed(2)}',
                              Icons.receipt,
                              Colors.orange,
                            ),
                            _row(
                              'RETURNS',
                              returnsCount.toString(),
                              Icons.keyboard_return,
                              Colors.red,
                            ),
                            _row(
                              'NET PROFIT',
                              '\$${netProfit.toStringAsFixed(2)}',
                              Icons.account_balance_wallet,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),

                      // Info message
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 24, left: 24, right: 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Data from Firebase Firestore',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _row(String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}