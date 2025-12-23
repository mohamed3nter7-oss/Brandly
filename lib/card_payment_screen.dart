import 'package:flutter/material.dart';

class CardPaymentScreen extends StatefulWidget {
  final double subtotal;
  final String name;
  final String city;

  const CardPaymentScreen({
    super.key,
    required this.subtotal,
    required this.name,
    required this.city,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  late TextEditingController amountController;
  late TextEditingController nameController;
  late TextEditingController cityController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.subtotal.toString());
    nameController = TextEditingController(text: widget.name);
    cityController = TextEditingController(text: widget.city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // أي قيمة يدخلها المستخدم تظهر مباشرة في Checkout
                  Navigator.pop(context, {
                    'amount': double.tryParse(amountController.text) ?? 0,
                    'name': nameController.text,
                    'city': cityController.text,
                  });
                },
                child: const Text('Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}