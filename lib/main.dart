import 'package:brandly4/seller_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Firebase options
import 'firebase_options.dart';
// Pages
import 'on_boarding.dart';
import 'login_page.dart';
import 'signup.dart';
import 'forget_password.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'favourite_page.dart';
import 'setting_page.dart';
import 'favourite_service.dart';
import 'notifications_page.dart';
import 'language.dart';
import 'privacy_policy_page.dart';
import 'change_password_page.dart';
import 'aboutpage.dart';
import 'card_page.dart';
import 'add_product_page.dart';
import 'my_products_page.dart';
import 'seller_home.dart';
import 'CheckoutScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// ROOT APP

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Brandly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),

        // 👇 Initialize SDKs inside splash flow
        home: const AppInitializer(),
        routes: {
          '/login': (context) => LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/home': (context) => const NewHomePage(),
          '/search': (context) => const BrandSearchPage(),
          //   '/favorites': (context) =>  const FavoritesPage (),
          '/settings': (context) => const SettingsPage(),
          '/seller-home': (context) => const SellerHomePage(),
          '/cart': (context) => const CartPage(),
          '/aboutpage': (context) => const AboutPage(),
          '/language': (context) => LanguagePage(),
          '/policy': (context) => const PrivacyPolicyPage(),
          '/notification': (context) => const NotificationsPage(),
          '/change-password': (context) => const ChangePasswordPage(),
          '/add-product': (context) => const AddProductPage(),
          '/my-products': (context) => const MyProductsPage(),
          '/seller_profile': (context) => const SellerMyProfilePage(),
          '/checkout': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;

            return CheckoutScreen(
              profileName: args['profileName'],
              subtotal: args['subtotal'],
              discount: args['discount'],
              appliedPromo: args['appliedPromo'],
              cartItems: args['cartItems'],
            );
          }
        });
  }
}

/// INITIALIZATION WIDGET (Firebase + Supabase)

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Supabase
    await Supabase.initialize(
      url: 'https://yilzcdtkjezpngwnxjaa.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpbHpjZHRramV6cG5nd254amFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NDk1MTMsImV4cCI6MjA4MTIyNTUxM30.7XwIyJbaul8aGh7bx39VUSWPn8bLJwn-YqNpuTm9mhw',
    );

    // Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Initialization error:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Success → go to Splash / OnBoarding
        return const SplashScreen();
      },
    );
  }
}
