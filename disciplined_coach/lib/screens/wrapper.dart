import 'package:disciplined_coach/screens/home_screen.dart';
import 'package:disciplined_coach/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // return either Home or Authenticate widget
    if (user == null) {
      return const LoginScreen();
    } else {
      // TODO: Add logic to check if permissions are already granted.
      // If not, return PermissionScreen();
      return const HomeScreen();
    }
  }
}
