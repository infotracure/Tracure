package com.tracure.main.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.tracure.main.db.AppDatabase
import com.tracure.main.db.SensorSample
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ScreenStateReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "ScreenStateReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val now = System.currentTimeMillis()
        val sessionDate = getSessionDate(now)

        val signalType: String
        val value: Float

        when (intent.action) {
            Intent.ACTION_SCREEN_ON -> {
                signalType = "SCREEN_STATE"
                value = 1.0f
                Log.d(TAG, "Screen ON (passive)")
            }
            Intent.ACTION_SCREEN_OFF -> {
                signalType = "SCREEN_STATE"
                value = 0.0f
                Log.d(TAG, "Screen OFF")
            }
            Intent.ACTION_USER_PRESENT -> {
                // User actually unlocked the device — this is real activity
                signalType = "USER_PRESENT"
                value = 1.0f
                Log.d(TAG, "User UNLOCKED (active)")
            }
            else -> return
        }

        CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
            try {
                val db = AppDatabase.getDatabase(context)
                db.sensorSampleDao().insert(
                    SensorSample(
                        timestamp = now,
                        signalType = signalType,
                        value = value,
                        sessionDate = sessionDate
                    )
                )
            } catch (e: Exception) {
                Log.e(TAG, "Failed to store screen event", e)
            }
        }
    }

    private fun getSessionDate(timestampMs: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val date = Date(timestampMs)
        val calendar = java.util.Calendar.getInstance().apply { time = date }
        // If before 4 AM, attribute to previous day's sleep session
        if (calendar.get(java.util.Calendar.HOUR_OF_DAY) < 4) {
            calendar.add(java.util.Calendar.DATE, -1)
        }
        return sdf.format(calendar.time)
    }
}
