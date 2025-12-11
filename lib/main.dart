import 'package:flutter/material.dart';
/*import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'firebase_options.dart';*/

import 'login_page.dart';
import 'signup.dart';
import 'forget_password.dart';
import 'on_boarding.dart';
import 'profile.dart';
import 'search_page.dart';
import 'favourite_page.dart';
import 'home_page.dart';
import 'setting_page.dart';
import 'auth_screen.dart';


//import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:shared_preferences/shared_preferences.dart';

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://srqplefdunarhgmppofa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNycXBsZWZkdW5hcmhnbXBwb2ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5Nzc3NDcsImV4cCI6MjA4MDU1Mzc0N30.EbRsC-zeCb8fUx9XkotEszx5B0UxchV9kmYLvpTQiIc',
  );

  runApp(const MyApp());
}*/

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

      
     home: const SplashScreen(),


      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/login': (context) =>  LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const NewHomePage(),
        '/profile': (context) => const MyProfilePage(),
        '/search': (context) => const BrandSearchPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

/*class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return const NewHomePage();
        }

        return const AuthScreen();
      },
    );
  }
}f

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// Screens
import 'auth_screen.dart';
import 'on_boarding.dart';
import 'home_page.dart'; // NewHomePage
import 'on_boarding.dart';

bool shouldShowOnboarding = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Read onboarding state
  try {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;
    shouldShowOnboarding = !completed; // true = show Onboarding
  } catch (e) {
    print("Error with SharedPreferences: $e");
    shouldShowOnboarding = true;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brandly",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const InitialScreen(),  // ← أهم سطر
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Loading / Splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Error state
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Authentication error.\nCheck Firebase settings.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // 1) User logged in → Go to Home
        if (snapshot.hasData) {
          return const NewHomePage();
        }

        // 2) User NOT logged in → Show Onboarding if needed
        if (shouldShowOnboarding) {
          return const OnboardingScreen();
        }

        // 3) User NOT logged in + already saw Onboarding
        return const AuthScreen();
      },
    );
 }*/