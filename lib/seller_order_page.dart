import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Order Model
class Order {
  final String orderId;
  final String orderNumber;
  final DateTime dateTime;
  final String customerName;
  final int itemCount;
  final double totalPrice;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.dateTime,
    required this.customerName,
    required this.itemCount,
    required this.totalPrice,
  });

  factory Order.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime orderDate;
    try {
      if (data['dateTime'] is Timestamp) {
        orderDate = (data['dateTime'] as Timestamp).toDate();
      } else if (data['dateTime'] is String) {
        orderDate = DateTime.parse(data['dateTime']);
      } else {
        orderDate = DateTime.now();
      }
    } catch (e) {
      orderDate = DateTime.now();
    }

    int items = 0;
    if (data['itemCount'] != null) {
      items = data['itemCount'] is int
          ? data['itemCount']
          : int.tryParse(data['itemCount'].toString()) ?? 0;
    }

    double price = 0.0;
    if (data['totalPrice'] != null) {
      price = data['totalPrice'] is double
          ? data['totalPrice']
          : double.tryParse(data['totalPrice'].toString()) ?? 0.0;
    }

    return Order(
      orderId: docId,
      orderNumber: data['orderNumber']?.toString() ??
          data['orderId']?.toString() ??
          'N/A',
      dateTime: orderDate,
      customerName: data['customerName']?.toString() ??
          data['customer']?.toString() ??
          data['userName']?.toString() ??
          'Unknown Customer',
      itemCount: items,
      totalPrice: price,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'dateTime': Timestamp.fromDate(dateTime),
      'customerName': customerName,
      'itemCount': itemCount,
      'totalPrice': totalPrice,
    };
  }
}

class OrderHistoryPage extends StatefulWidget {
  final String brandName;
  final String brandId;

  const OrderHistoryPage({
    Key? key,
    this.brandName = 'Brandly Seller',
    this.brandId = '',
  }) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      QuerySnapshot ordersSnapshot;
      if (widget.brandId.isNotEmpty) {
        ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('brandId', isEqualTo: widget.brandId)
            .get();
      } else {
        ordersSnapshot =
            await FirebaseFirestore.instance.collection('orders').get();
      }

      _allOrders = ordersSnapshot.docs
          .map((doc) {
            try {
              return Order.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              print('Error parsing order ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Order>()
          .toList();

      _allOrders.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _filteredOrders = _allOrders;
    } catch (e) {
      print('Error loading orders: $e');
      _allOrders = [];
      _filteredOrders = [];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _filterOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders
            .where((order) =>
                order.orderNumber.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (orderDate == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterOrders,
        decoration: InputDecoration(
          hintText: 'Search order ID...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFF9B8AFB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatDate(order.dateTime),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          order.customerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // HEADER
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C6FDC), Color(0xFF9B8AFB)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.brandName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 45),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Overview',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Order History',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SEARCH BAR
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(),
              ),
            ),
          ),

          // ORDERS LIST
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF9B8AFB)),
                  ),
                )
              : _filteredOrders.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 20),
                            Text('No orders found',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildOrderCard(_filteredOrders[index]),
                          childCount: _filteredOrders.length,
                        ),
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
