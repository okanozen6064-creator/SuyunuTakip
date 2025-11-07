import 'package:flutter/services.dart';

class PermissionService {
  static const platform = MethodChannel('com.example.disciplined_coach/alarm_service');

  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await platform.invokeMethod('requestIgnoreBatteryOptimizations');
    } on PlatformException {
      // print("Failed to request battery optimization permission.");
    }
  }

  // TODO: Add method to check for SCHEDULE_EXACT_ALARM permission
}
