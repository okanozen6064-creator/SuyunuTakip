import 'package:disciplined_coach/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:disciplined_coach/screens/wrapper.dart';
import 'package:disciplined_coach/screens/alarm_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:home_widget/home_widget.dart';

// Called when Doing Background Work
@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatecounter') {
    //
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);

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
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C853), // Cerrahi Yeşil
            secondary: Color(0xFF00C853),
            error: Color(0xFFD50000), // Kanamalı Kırmızı
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.robotoMono(fontSize: 48, fontWeight: FontWeight.bold),
            // Diğer text stillerini de buraya ekleyebiliriz.
          ),
          cardTheme: CardThemeData(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name != null && settings.name!.startsWith('/alarm/')) {
            final drugId = settings.name!.split('/').last;
            return MaterialPageRoute(
              builder: (context) {
                return AlarmScreen(drugId: drugId);
              },
            );
          }
          // Handle other routes, or default
          return MaterialPageRoute(builder: (context) => const Wrapper());
        },
        // Legacy routes for non-dynamic routing
        routes: {
          '/': (context) => const Wrapper(),
        },
      ),
    );
  }
}
