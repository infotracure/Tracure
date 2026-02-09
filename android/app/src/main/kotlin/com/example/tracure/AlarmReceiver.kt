package com.tracure.main

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.tracure.main.scheduler.SleepWorkScheduler

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AlarmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "START_SLEEP_TRACKING" -> {
                Log.d(TAG, "Alarm fired: START_SLEEP_TRACKING")

                // Schedule WorkManager jobs instead of starting foreground service
                SleepWorkScheduler.scheduleOvernightCollection(context)
                SleepWorkScheduler.registerReceivers(context)

                // Reschedule alarms for the next day
                val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
                val start = prefs.getString("lSStartTime", "22:00") ?: "22:00"
                val end = prefs.getString("lSEndTime", "07:00") ?: "07:00"
                SleepAlarmScheduler.scheduleSleepTracking(context, start, end)

                showNotification(context, "Sleep Tracking", "Sleep monitoring active")
            }

            "STOP_SLEEP_TRACKING" -> {
                Log.d(TAG, "Alarm fired: STOP_SLEEP_TRACKING")

                // Trigger morning inference
                SleepWorkScheduler.runInferenceNow(context)

                showNotification(context, "Sleep Tracking", "Analyzing your sleep data")
            }
        }
    }

    private fun showNotification(context: Context, title: String, message: String) {
        val channelId = "SleepTestAlarm"
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "Sleep Tracking Notifications",
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        manager.notify((0..1000).random(), notification)
    }
}
