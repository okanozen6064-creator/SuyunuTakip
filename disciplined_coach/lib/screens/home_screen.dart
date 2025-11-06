import 'package:disciplined_coach/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Ekran'),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await authService.signOut();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Disiplinli Koç\'a Hoş Geldin!'),
      ),
    );
  }
}
