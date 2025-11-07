import 'package:disciplined_coach/screens/home_screen.dart';
import 'package:disciplined_coach/screens/login_screen.dart';
import 'package:disciplined_coach/screens/permission_screen.dart';
import 'package:disciplined_coach/services/permission_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final permissionService = PermissionService();

    // return either Home or Authenticate widget
    if (user == null) {
      return const LoginScreen();
    } else {
      return FutureBuilder<bool>(
        future: permissionService.checkIgnoreBatteryOptimizations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          } else {
            return const PermissionScreen();
          }
        },
      );
    }
  }
}
