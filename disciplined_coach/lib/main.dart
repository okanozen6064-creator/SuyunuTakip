import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:disciplined_coach/screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter motorunu başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat (Hatayı yakalamak için try-catch bloğu şart!)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase başarıyla başlatıldı! - Disiplinli Koç");
  } catch (e) {
    print("Firebase başlatma HATASI: $e");
    // Burada kullanıcıya bir hata ekranı göstermek gerekebilir.
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}
