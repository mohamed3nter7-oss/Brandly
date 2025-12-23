import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Notification Settings
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool smsNotifications = false;

  // Order Notifications
  bool orderUpdates = true;
  bool orderConfirmation = true;
  bool shippingUpdates = true;
  bool deliveryNotifications = true;

  // Marketing Notifications
  bool promotions = false;
  bool newProducts = false;
  bool newsletters = false;
  bool specialOffers = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('pushNotifications') ?? true;
      emailNotifications = prefs.getBool('emailNotifications') ?? false;
      smsNotifications = prefs.getBool('smsNotifications') ?? false;

      orderUpdates = prefs.getBool('orderUpdates') ?? true;
      orderConfirmation = prefs.getBool('orderConfirmation') ?? true;
      shippingUpdates = prefs.getBool('shippingUpdates') ?? true;
      deliveryNotifications = prefs.getBool('deliveryNotifications') ?? true;

      promotions = prefs.getBool('promotions') ?? false;
      newProducts = prefs.getBool('newProducts') ?? false;
      newsletters = prefs.getBool('newsletters') ?? false;
      specialOffers = prefs.getBool('specialOffers') ?? false;
    });
  }

  // Save settings to SharedPreferences
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // General Notifications Section
          _buildSectionHeader('General Notifications'),
          const SizedBox(height: 10),

          _buildNotificationCard(
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            subtitle: 'Receive notifications on this device',
            value: pushNotifications,
            onChanged: (val) {
              setState(() => pushNotifications = val);
              _saveSetting('pushNotifications', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            value: emailNotifications,
            onChanged: (val) {
              setState(() => emailNotifications = val);
              _saveSetting('emailNotifications', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.sms,
            title: 'SMS Notifications',
            subtitle: 'Receive notifications via text message',
            value: smsNotifications,
            onChanged: (val) {
              setState(() => smsNotifications = val);
              _saveSetting('smsNotifications', val);
            },
          ),

          const SizedBox(height: 30),

          // Order Notifications Section
          _buildSectionHeader('Order Notifications'),
          const SizedBox(height: 10),

          _buildNotificationCard(
            icon: Icons.shopping_cart,
            title: 'Order Updates',
            subtitle: 'Get notified about your order status',
            value: orderUpdates,
            onChanged: (val) {
              setState(() => orderUpdates = val);
              _saveSetting('orderUpdates', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.check_circle,
            title: 'Order Confirmation',
            subtitle: 'Notify when order is confirmed',
            value: orderConfirmation,
            onChanged: (val) {
              setState(() => orderConfirmation = val);
              _saveSetting('orderConfirmation', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.local_shipping,
            title: 'Shipping Updates',
            subtitle: 'Track your shipment in real-time',
            value: shippingUpdates,
            onChanged: (val) {
              setState(() => shippingUpdates = val);
              _saveSetting('shippingUpdates', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.home,
            title: 'Delivery Notifications',
            subtitle: 'Notify when order is delivered',
            value: deliveryNotifications,
            onChanged: (val) {
              setState(() => deliveryNotifications = val);
              _saveSetting('deliveryNotifications', val);
            },
          ),

          const SizedBox(height: 30),

          // Marketing Notifications Section
          _buildSectionHeader('Marketing & Promotions'),
          const SizedBox(height: 10),

          _buildNotificationCard(
            icon: Icons.local_offer,
            title: 'Promotions',
            subtitle: 'Receive promotional offers and deals',
            value: promotions,
            onChanged: (val) {
              setState(() => promotions = val);
              _saveSetting('promotions', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.new_releases,
            title: 'New Products',
            subtitle: 'Get notified about new arrivals',
            value: newProducts,
            onChanged: (val) {
              setState(() => newProducts = val);
              _saveSetting('newProducts', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.article,
            title: 'Newsletters',
            subtitle: 'Receive weekly newsletters',
            value: newsletters,
            onChanged: (val) {
              setState(() => newsletters = val);
              _saveSetting('newsletters', val);
            },
          ),

          _buildNotificationCard(
            icon: Icons.star,
            title: 'Special Offers',
            subtitle: 'Exclusive deals just for you',
            value: specialOffers,
            onChanged: (val) {
              setState(() => specialOffers = val);
              _saveSetting('specialOffers', val);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.purple,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: Colors.purple,
      ),
    );
  }
}
