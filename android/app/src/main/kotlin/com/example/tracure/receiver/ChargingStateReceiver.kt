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

class ChargingStateReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "ChargingStateReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val value = when (intent.action) {
            Intent.ACTION_POWER_CONNECTED -> 1.0f
            Intent.ACTION_POWER_DISCONNECTED -> 0.0f
            else -> return
        }

        Log.d(TAG, "Charging ${if (value == 1.0f) "CONNECTED" else "DISCONNECTED"}")

        val now = System.currentTimeMillis()
        val sessionDate = getSessionDate(now)

        CoroutineScope(Dispatchers.IO + SupervisorJob()).launch {
            try {
                val db = AppDatabase.getDatabase(context)
                db.sensorSampleDao().insert(
                    SensorSample(
                        timestamp = now,
                        signalType = "CHARGING_STATE",
                        value = value,
                        sessionDate = sessionDate
                    )
                )
            } catch (e: Exception) {
                Log.e(TAG, "Failed to store charging event", e)
            }
        }
    }

    private fun getSessionDate(timestampMs: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val date = Date(timestampMs)
        val calendar = java.util.Calendar.getInstance().apply { time = date }
        if (calendar.get(java.util.Calendar.HOUR_OF_DAY) < 4) {
            calendar.add(java.util.Calendar.DATE, -1)
        }
        return sdf.format(calendar.time)
    }
}
