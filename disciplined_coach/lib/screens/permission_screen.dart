import 'package:disciplined_coach/services/permission_service.dart';
import 'package:flutter/material.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Önemli İzin Gerekli'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.battery_alert, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Güvenilir Alarmlar İçin Gerekli',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Uygulamanın, telefonunuz uyku modundayken bile alarmları zamanında çalabilmesi için pil optimizasyonunu devre dışı bırakmanız zorunludur. Bu izin verilmeden uygulama düzgün çalışamaz.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                permissionService.requestIgnoreBatteryOptimizations();
                // TODO: Check if permission was granted and navigate away
              },
              child: const Text('Ayarlara Git ve İzin Ver'),
            ),
          ],
        ),
      ),
    );
  }
}
