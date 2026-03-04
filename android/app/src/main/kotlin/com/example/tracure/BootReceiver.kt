package com.tracure.main

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean("sleepTrackingEnabled", false)
        if (!enabled) {
            Log.d("BootReceiver", "Sleep tracking not enabled, skipping re-schedule")
            return
        }

        val start = prefs.getString("lSStartTime", "22:00") ?: "22:00"
        val end = prefs.getString("lSEndTime", "07:00") ?: "07:00"

        SleepAlarmScheduler.scheduleSleepTracking(context, start, end)
        Log.d("BootReceiver", "Re-scheduled sleep alarms after boot: start=$start, end=$end")
    }
}
