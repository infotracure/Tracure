package com.tracure.main

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "START_SLEEP_TRACKING" -> {
                showNotification(context, "Sleep Tracking", "Sleep service started from alarm")
                val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)

                val start = prefs.getString("lSStartTime", "22:00") ?: "22:00"
                val end = prefs.getString("lSEndTime", "07:00") ?: "07:00"
                val hardStop = prefs.getString("lSHardStopTime", "10:00") ?: "10:00"
                val interval = prefs.getInt("sleepInterval", 1800)
                val sleepDate = prefs.getString("sleepDate", getTodayDate()) ?: getTodayDate()

                val serviceIntent = Intent(context, SleepTrackingService::class.java).apply {
                    putExtra("lSStartTime", start)
                    putExtra("lSEndTime", end)
                    putExtra("lSHardStopTime", hardStop)
                    putExtra("sleepInterval", interval)
                    putExtra("sleepDate", sleepDate)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d("AlarmReceiver", "SleepTrackingService STARTED")
                // Re-schedule for the next day so alarms repeat daily
                SleepAlarmScheduler.scheduleSleepTracking(context, start, end)

            }
            "STOP_SLEEP_TRACKING" -> {
                showNotification(context, "Sleep Tracking", "Sleep service stopped from alarm")
                isEndService = true
                val stopIntent = Intent(context, SleepTrackingService::class.java)
                context.stopService(stopIntent)
                Log.d("AlarmReceiver", "SleepTrackingService STOPPED")
            }

            "WATCHDOG_SLEEP_TRACKING" -> {
                if (SleepTrackingService.isRunning) {
                    Log.d("AlarmReceiver", "Watchdog: service already running, skipping")
                    return
                }

                Log.d("AlarmReceiver", "Watchdog: service NOT running, restarting...")
                showNotification(context, "Sleep Tracking", "Service restarted by watchdog")

                val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
                val start = prefs.getString("lSStartTime", "22:00") ?: "22:00"
                val end = prefs.getString("lSEndTime", "07:00") ?: "07:00"
                val hardStop = prefs.getString("lSHardStopTime", "10:00") ?: "10:00"
                val interval = prefs.getInt("sleepInterval", 1800)

                val serviceIntent = Intent(context, SleepTrackingService::class.java).apply {
                    putExtra("lSStartTime", start)
                    putExtra("lSEndTime", end)
                    putExtra("lSHardStopTime", hardStop)
                    putExtra("sleepInterval", interval)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d("AlarmReceiver", "Watchdog: SleepTrackingService RESTARTED")
            }
        }
    }

    private fun getTodayDate(): String {
        val sdf = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
        return sdf.format(java.util.Date())
    }

    private fun showNotification(context: Context, title: String, message: String) {
        val channelId = "SleepTestAlarm"
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "Sleep Test Alarm Channel",
                NotificationManager.IMPORTANCE_HIGH
            )
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        manager.notify((0..1000).random(), notification)
    }
}
