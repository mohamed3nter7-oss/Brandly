import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final String profileName;
  final double subtotal;
  final double discount;
  final String appliedPromo;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutScreen({
    super.key,
    required this.profileName,
    required this.subtotal,
    required this.discount,
    required this.appliedPromo,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryColor = Color(0xFF7C5FFC);

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController addressController;

  double shippingFee = 0.0;
  double cardFeePercentage = 0.0;
  String selectedPayment = 'cash';
  bool isLoading = false;

  Map<String, double> shippingRates = {
    'cairo': 70,
    'giza': 65,
    'alexandria': 80,
    'assiut': 50,
  };

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profileName);
    phoneController = TextEditingController();
    cityController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _calculateShipping() {
    String cityKey = cityController.text.toLowerCase().trim();
    setState(() {
      shippingFee = shippingRates[cityKey] ?? 100.0;
    });
  }

  Future<void> _placeOrder() async {
    if (nameController.text.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    if (cityController.text.isEmpty) {
      _showError('Please select your city');
      return;
    }
    if (addressController.text.isEmpty) {
      _showError('Please enter your address');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final double cardFee = widget.subtotal * cardFeePercentage;
      final double total =
          widget.subtotal + shippingFee + cardFee - widget.discount;

      // إنشاء طلب في Firestore
      final ordersRef =
          FirebaseFirestore.instance.collection('orders').doc();

      await ordersRef.set({
        'orderId': ordersRef.id,
        'userId': userId,
        'customerName': nameController.text,
        'phone': phoneController.text,
        'city': cityController.text,
        'address': addressController.text,
        'paymentMethod': selectedPayment,
        'subtotal': widget.subtotal,
        'shipping': shippingFee,
        'discount': widget.discount,
        'cardFee': cardFee,
        'total': total,
        'appliedPromo': widget.appliedPromo,
        'items': widget.cartItems,
        'orderStatus': 'pending',
        'createdAt': DateTime.now(),
      });

      // حذف السلة بعد الطلب
      final cartDocs = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in cartDocs.docs) {
        await doc.reference.delete();
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Order Placed Successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error placing order: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardFee = widget.subtotal * cardFeePercentage;
    double total = widget.subtotal + shippingFee + cardFee - widget.discount;

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
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItems(),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                _buildDeliverySection(),
                const SizedBox(height: 24),
                _buildPaymentSection(),
                const SizedBox(height: 24),
                _buildOrderSummary(total, cardFee),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.cartItems.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Size: ${item['size']}, Color: ${item['color']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item['quantity']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: nameController,
          label: 'Full Name',
          icon: Icons.person,
          hint: 'Enter your name',
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          hint: 'Enter your phone',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: cityController,
          label: 'City',
          icon: Icons.location_on,
          hint: 'Cairo, Alexandria...',
          onChanged: (_) => _calculateShipping(),
        ),
        const SizedBox(height: 8),
        Text(
          'Available cities: Cairo (70), Giza (65), Alexandria (80), Assiut (50)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: addressController,
          label: 'Delivery Address',
          icon: Icons.home,
          hint: 'Enter your full address',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption('cash', 'Cash on Delivery', Icons.attach_money),
        const SizedBox(height: 12),
        _buildPaymentOption('card', 'Credit / Debit Card', Icons.credit_card),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    bool isSelected = selectedPayment == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
          cardFeePercentage = value == 'card' ? 0.03 : 0.0;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.black,
              ),
            ),
            const Spacer(),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double total, double cardFee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', widget.subtotal),
              const Divider(height: 16),
              _buildSummaryRow('Shipping', shippingFee),
              if (widget.discount > 0) ...[
                const Divider(height: 16),
                _buildSummaryRow('Discount', -widget.discount,
                    color: Colors.green),
              ],
              if (cardFee > 0) ...[
                const Divider(height: 16),
                _buildSummaryRow('Card Fee (3%)', cardFee),
              ],
              const Divider(height: 16, thickness: 2),
              _buildSummaryRow('Total', total, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, double value,
      {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isTotal ? Colors.black : Colors.grey),
          ),
        ),
      ],
    );
  }
}