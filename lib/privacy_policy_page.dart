import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          "Privacy Policy",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B5FED), Color(0xFF8B7FFF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Last updated: December 14, 2025',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Introduction
            _buildSection(
              icon: Icons.info_outline,
              title: 'Introduction',
              content: 'Welcome to Brandly. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data and tell you about your privacy rights.',
            ),

            // Information We Collect
            _buildSection(
              icon: Icons.data_usage,
              title: 'Information We Collect',
              content: 'We collect information you provide directly to us when you:\n\n'
                  '• Create an account\n'
                  '• Make a purchase or place an order\n'
                  '• Subscribe to our newsletter\n'
                  '• Contact customer support\n'
                  '• Participate in surveys or promotions\n\n'
                  'This information may include your name, email address, postal address, phone number, and payment information.',
            ),

            // How We Use Your Information
            _buildSection(
              icon: Icons.settings_suggest,
              title: 'How We Use Your Information',
              content: 'We use the information we collect to:\n\n'
                  '• Process and fulfill your orders\n'
                  '• Communicate with you about your account or orders\n'
                  '• Send you marketing communications (with your consent)\n'
                  '• Improve our services and develop new features\n'
                  '• Prevent fraud and enhance security\n'
                  '• Comply with legal obligations',
            ),

            // Data Sharing
            _buildSection(
              icon: Icons.share,
              title: 'Data Sharing',
              content: 'We do not sell your personal information. We may share your information with:\n\n'
                  '• Service providers who help us operate our business\n'
                  '• Payment processors to complete transactions\n'
                  '• Shipping companies to deliver your orders\n'
                  '• Legal authorities when required by law',
            ),

            // Data Security
            _buildSection(
              icon: Icons.security,
              title: 'Data Security',
              content: 'We implement appropriate technical and organizational security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. This includes:\n\n'
                  '• Encryption of sensitive data\n'
                  '• Regular security assessments\n'
                  '• Secure payment processing\n'
                  '• Limited access to personal information',
            ),

            // Your Rights
            _buildSection(
              icon: Icons.verified_user,
              title: 'Your Rights',
              content: 'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Request deletion of your data\n'
                  '• Object to processing of your data\n'
                  '• Request data portability\n'
                  '• Withdraw consent at any time\n\n'
                  'You can exercise these rights through your account settings or by contacting us.',
            ),

            // Cookies
            _buildSection(
              icon: Icons.cookie,
              title: 'Cookies and Tracking',
              content: 'We use cookies and similar tracking technologies to:\n\n'
                  '• Keep you signed in\n'
                  '• Remember your preferences\n'
                  '• Understand how you use our services\n'
                  '• Provide personalized content\n\n'
                  'You can control cookies through your browser settings.',
            ),

            // Children's Privacy
            _buildSection(
              icon: Icons.child_care,
              title: "Children's Privacy",
              content: 'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
            ),

            // Changes to Privacy Policy
            _buildSection(
              icon: Icons.update,
              title: 'Changes to This Policy',
              content: 'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last updated" date. We encourage you to review this policy periodically.',
            ),

            // Contact Us
            _buildSection(
              icon: Icons.contact_support,
              title: 'Contact Us',
              content: 'If you have any questions about this privacy policy or our data practices, please contact us:\n\n'
                  '📧 Email: privacy@brandly.com\n'
                  '📱 Phone: +1 (555) 123-4567\n'
                  '📍 Address: 123 Business St, City, State 12345',
            ),

            const SizedBox(height: 30),

            // Agreement Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.purple, size: 32),
                  SizedBox(height: 10),
                  Text(
                    'By using Brandly, you agree to this Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}