import 'package:disciplined_coach/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:disciplined_coach/screens/wrapper.dart';
import 'package:disciplined_coach/screens/alarm_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // print("Firebase başarıyla başlatıldı! - Disiplinli Koç");
  } catch (e) {
    // print("Firebase başlatma HATASI: $e");
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const Wrapper(),
          '/alarm': (context) => const AlarmScreen(),
          // TODO: Extract drugId from arguments for AlarmScreen
        },
      ),
    );
  }
}
