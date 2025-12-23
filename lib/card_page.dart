/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('cart').get();

    setState(() {
      cartItems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateQuantity(int index, int delta) async {
    final item = cartItems[index];
    int newQuantity = (item['quantity'] ?? 1) + delta;
    if (newQuantity < 1) newQuantity = 1;

    await FirebaseFirestore.instance
        .collection('cart')
        .doc(item['id'])
        .update({'quantity': newQuantity});

    setState(() {
      cartItems[index]['quantity'] = newQuantity;
    });
  }

  Future<void> removeItem(int index) async {
    final item = cartItems[index];

    await FirebaseFirestore.instance
        .collection('cart')
        .doc(item['id'])
        .delete();

    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get subtotal => cartItems.fold(
        0,
        (sum, item) =>
            sum + (item['price'] as num) * (item['quantity'] as int),
      );

  double get shipping => 10.0;
  double get tax => 12.5;
  double get total => subtotal + shipping + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          item['image'],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      removeItem(index),
                                ),
                              ],
                            ),
                            Text(
                              'Size: ${item['size']} | Color: ${item['color']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${(item['price'] as num).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF7C5FFC),
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon:
                                          const Icon(Icons.remove),
                                      onPressed: () =>
                                          updateQuantity(
                                              index, -1),
                                    ),
                                    Text(
                                        '${item['quantity']}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          updateQuantity(
                                              index, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _priceRow('Subtotal', subtotal),
            _priceRow('Shipping', shipping),
            _priceRow('Tax', tax),
            const Divider(),
            _priceRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CheckoutScreen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _promoController = TextEditingController();
  double _discount = 0.0;
  String _appliedPromo = '';

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // حساب subtotal
  double _subtotal(List<QueryDocumentSnapshot> docs) {
    return docs.fold(
      0.0,
      (sum, doc) => sum + (doc['price'] as num) * (doc['quantity'] as int),
    );
  }

  void _updateQuantity(String docId, int delta) {
    final docRef = FirebaseFirestore.instance.collection('cart').doc(docId);
    docRef.get().then((doc) {
      if (doc.exists) {
        int currentQty = doc['quantity'];
        int newQty = (currentQty + delta).clamp(1, 1000);
        docRef.update({'quantity': newQty});
      }
    });
  }

  void _removeItem(String docId) {
    FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  void _applyPromoCode(List<QueryDocumentSnapshot> docs) {
    String code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    double subtotal = _subtotal(docs);

    setState(() {
      if (code == 'SAVE10') {
        _discount = subtotal * 0.1;
        _appliedPromo = code;
      } else if (code == 'SAVE20') {
        _discount = subtotal * 0.2;
        _appliedPromo = code;
      } else if (code == 'FREESHIP') {
        _discount = 10.0;
        _appliedPromo = code;
      } else {
        _discount = 0.0;
        _appliedPromo = '';
      }
    });
  }

  void _goToCheckout(BuildContext context, List<QueryDocumentSnapshot> docs) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Customer';
    final subtotal = _subtotal(docs);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          profileName: userName,
          subtotal: subtotal,
          discount: _discount,
          appliedPromo: _appliedPromo,
          cartItems: docs
              .map((doc) => {
                    'name': doc['name'] as String,
                    'price': doc['price'] as num,
                    'quantity': doc['quantity'] as int,
                    'image': doc['image'] as String,
                    'size': doc['size'] as String,
                    'color': doc['color'] as String,
                  })
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

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
          'Your Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyCart();
          }

          final docs = snapshot.data!.docs;
          final subtotal = _subtotal(docs);
          const shipping = 10.0;
          const tax = 12.5;
          final total = subtotal + shipping + tax - _discount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Cart Items
                ...docs.map((doc) => _buildCartItem(doc)),

                const SizedBox(height: 24),

                // Promo Code
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _promoController,
                          decoration: const InputDecoration(
                            hintText: 'Enter promo code',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _applyPromoCode(docs),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 16),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),

                if (_appliedPromo.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00BFA5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF00BFA5), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Promo "$_appliedPromo" applied',
                          style: const TextStyle(
                              color: Color(0xFF00BFA5),
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _discount = 0;
                              _appliedPromo = '';
                              _promoController.clear();
                            });
                          },
                          child: const Icon(Icons.close,
                              color: Color(0xFF00BFA5), size: 20),
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Price Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow('Subtotal', subtotal),
                      const Divider(height: 16),
                      _buildPriceRow('Shipping', shipping),
                      const Divider(height: 16),
                      _buildPriceRow('Tax', tax),
                      if (_discount > 0) ...[
                        const Divider(height: 16),
                        _buildPriceRow('Discount', -_discount,
                            color: Colors.green),
                      ],
                      const Divider(height: 16, thickness: 2),
                      _buildPriceRow('Total', total, isTotal: true),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (docs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your cart is empty'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      _goToCheckout(context, docs);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(QueryDocumentSnapshot doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                doc['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${doc['size']}, Color: ${doc['color']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(doc['price'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C5FFC),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _updateQuantity(doc.id, -1),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${doc['quantity']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _updateQuantity(doc.id, 1),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _removeItem(doc.id),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: color ?? (isTotal ? Colors.black : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}