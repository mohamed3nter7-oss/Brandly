import 'change_password_page.dart';
import 'package:brandly4/language.dart';
import 'package:brandly4/logout_page.dart';
import 'notifications_page.dart';
import 'privacy_policy_page.dart';
import 'package:brandly4/C_profile.dart';
import 'package:brandly4/aboutpage.dart';
/*import 'notifications_page.dart';
import 'package;brandly4/change_password_page.dart';
import 'package:brandly4/privacy_policy_page.dart';*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // جلب البيانات من Supabase
        final response = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.uid)
            .single();

        if (mounted) {
          setState(() {
            userName = response['name'] ?? 'User';
            userEmail = response['email'] ?? user.email ?? 'No Email';
            isLoading = false;
          });
        }
      } else {
        // إذا لم يكن هناك مستخدم مسجل
        if (mounted) {
          setState(() {
            userName = 'Guest';
            userEmail = 'Not logged in';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          userName = 'User';
          userEmail = FirebaseAuth.instance.currentUser?.email ?? 'No Email';
          isLoading = false;
        });
      }
    }
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
          "Settings",
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 20),

                // PROFILE SECTION
                _buildSectionTitle("Account"),
                _buildSettingsItem(
                  icon: Icons.person_outline,
                  title: "Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyProfilePage(
                          name: userName,
                          email: userEmail,
                        ),
                      ),
                    );
                  },
                ),

                // PREFERENCES SECTION
                _buildSectionTitle("Preferences"),
                _buildSettingsItem(
                  icon: Icons.notifications_active_outlined,
                  title: "Notifications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                ),

                // CHANGE PASSWORD
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),

                // LANGUAGE
                _buildSettingsItem(
                  icon: Icons.language_outlined,
                  title: "Language",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguagePage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // SUPPORT SECTION
                _buildSectionTitle("Support"),
                _buildSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),

                // ABOUT
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  title: "About App",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // LOG OUT BUTTON
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogoutPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B5FED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 18,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
