import 'package:flutter/services.dart';

class AlarmService {
  static const platform = MethodChannel('com.example.disciplined_coach/alarm_service');

  Future<void> setExactDrugAlarm(String drugId, DateTime time) async {
    try {
      await platform.invokeMethod('setExactDrugAlarm', {
        'drugId': drugId,
        'timestamp': time.millisecondsSinceEpoch,
      });
      // print('Alarm set for $drugId at $time');
    } on PlatformException {
      // print("Failed to set alarm.");
    }
  }

  // TODO: Add methods for canceling alarms if needed
}
