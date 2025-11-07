package com.example.disciplined_coach

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.disciplined_coach/alarm_service"

    override fun onCreate(savedInstanceState: Bundle?) {
        intent.getStringExtra("route")?.let {
            flutterEngine?.navigationChannel?.setInitialRoute(it)
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "requestIgnoreBatteryOptimizations") {
                val intent = Intent()
                intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
                result.success("Redirected to battery settings.")
            } else if (call.method == "setExactDrugAlarm") {
                val timestamp = call.argument<Long>("timestamp")
                if (timestamp != null) {
                    setExactAlarm(timestamp)
                    result.success("Alarm set for timestamp: $timestamp")
                } else {
                    result.error("INVALID_ARGUMENT", "Timestamp argument is missing or invalid.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setExactAlarm(timestamp: Long) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        // TODO: Pass drugId or other relevant data in the intent
        val pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timestamp, pendingIntent)
    }
}
