import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesla_smart_charge_app/app_shell.dart';
import 'package:tesla_smart_charge_app/data_loader.dart';
import 'package:tesla_smart_charge_app/screens/auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is logged in. Show the DataLoader, which will handle
          // fetching the user's data and then show the AppShell.
          return const DataLoader(child: AppShell());
        } else {
          // User is not logged in
          return const AuthScreen();
        }
      },
    );
  }
}
