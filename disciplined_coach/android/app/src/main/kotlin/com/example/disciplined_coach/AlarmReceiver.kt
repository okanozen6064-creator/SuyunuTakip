package com.example.disciplined_coach

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationChannelId = "discipline_coach_alarm_channel"

        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        val channel = NotificationChannel(
            notificationChannelId,
            "Alarm Notifications",
            NotificationManager.IMPORTANCE_HIGH
        )
        notificationManager.createNotificationChannel(channel)

        // Create an intent to launch the app
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            // Pass data to Flutter
            putExtra("route", "/alarm")
            // TODO: Pass drugId to show the correct alarm screen in Flutter
            // putExtra("drugId", intent.getStringExtra("drugId"))
        }

        val pendingIntent: PendingIntent = PendingIntent.getActivity(context, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE)

        val fullScreenPendingIntent: PendingIntent = PendingIntent.getActivity(context, 1, launchIntent, PendingIntent.FLAG_IMMUTABLE)

        val builder = NotificationCompat.Builder(context, notificationChannelId)
            .setSmallIcon(R.mipmap.ic_launcher) // default flutter icon
            .setContentTitle("İlaç Zamanı!")
            .setContentText("Disiplinli Koç: İlacını alma zamanı geldi.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(fullScreenPendingIntent, true) // This is what makes it a full-screen notification
            .setAutoCancel(true)

        notificationManager.notify(1, builder.build())
    }
}
