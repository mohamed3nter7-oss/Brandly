import 'package:brandly4/logout_page.dart';
import 'package:brandly4/profile.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          "Settings",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // PROFILE
          _buildSectionTitle("Account"),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: "Profile",
            onTap: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MyProfilePage(
      name:AutofillHints.username,
      email: AutofillHints.email,
    ),
  ),
);
            }
          ),

          // NOTIFICATIONS
          _buildSectionTitle("Preferences"),
          _buildSettingsItem(
            icon: Icons.notifications_active_outlined,
            title: "Notifications",
            onTap: () {},
          ),

          // CHANGE PASSWORD
          _buildSettingsItem(
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {},
          ),

          // LANGUAGE
          _buildSettingsItem(
            icon: Icons.language_outlined,
            title: "Language",
            onTap: () {},
          ),

          const SizedBox(height: 10),

          // PRIVACY
          _buildSectionTitle("Support"),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),

          // ABOUT
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: "About App",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // LOG OUT
          Center(
            child: TextButton(
              onPressed: ()  {
              Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LogoutPage(),)
);},
              child: const Text(
                "Log Out",
                style: TextStyle(
                  color: Color.fromARGB(255, 168, 54, 244),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  backgroundColor: Color.fromARGB(248, 136, 110, 153)
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.purple, size: 26),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: Colors.grey, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
