import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'on_boarding.dart';

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  Future<void> _init() async {
    await Supabase.initialize(
     url: 'https://yilzcdtkjezpngwnxjaa.supabase.co',
     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpbHpjZHRramV6cG5nd254amFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NDk1MTMsImV4cCI6MjA4MTIyNTUxM30.7XwIyJbaul8aGh7bx39VUSWPn8bLJwn-YqNpuTm9mhw',
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Initialization error: ${snapshot.error}'),
            ),
          );
        }

        return const SplashScreen();
      },
    );
  }
}
