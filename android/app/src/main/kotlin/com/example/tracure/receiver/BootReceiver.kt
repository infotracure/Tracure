package com.tracure.main.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.tracure.main.scheduler.SleepWorkScheduler

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Device booted — rescheduling sleep tracking")

            val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
            val isEnabled = prefs.getBoolean("trackingEnabled", false)

            if (isEnabled) {
                SleepWorkScheduler.scheduleOvernightCollection(context)
                SleepWorkScheduler.scheduleMorningAnalysis(context)
                SleepWorkScheduler.registerReceivers(context)
                Log.d(TAG, "Sleep tracking rescheduled after boot")
            }
        }
    }
}
