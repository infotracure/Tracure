package com.tracure.main.scheduler

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.tracure.main.receiver.ChargingStateReceiver
import com.tracure.main.receiver.ScreenStateReceiver
import com.tracure.main.worker.MotionSampleWorker
import com.tracure.main.worker.SleepInferenceWorker
import java.util.Calendar
import java.util.concurrent.TimeUnit

object SleepWorkScheduler {

    private const val TAG = "SleepWorkScheduler"
    private const val OVERNIGHT_WORK_TAG = "sleep_overnight_checkin"
    private const val MORNING_ANALYSIS_TAG = "sleep_morning_analysis"

    private var screenReceiver: ScreenStateReceiver? = null
    private var chargingReceiver: ChargingStateReceiver? = null

    /**
     * Schedule periodic accelerometer sampling every 15 minutes.
     * WorkManager handles Doze mode maintenance windows automatically.
     */
    fun scheduleOvernightCollection(context: Context) {
        val overnightWork = PeriodicWorkRequestBuilder<MotionSampleWorker>(
            15, TimeUnit.MINUTES,
            5, TimeUnit.MINUTES  // flex interval
        )
            .addTag(OVERNIGHT_WORK_TAG)
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            OVERNIGHT_WORK_TAG,
            ExistingPeriodicWorkPolicy.KEEP,
            overnightWork
        )

        Log.d(TAG, "Overnight motion sampling scheduled (every 15 min)")
    }

    /**
     * Schedule a one-time morning analysis job.
     * Uses wake time from SharedPreferences or defaults to 7:30 AM.
     */
    fun scheduleMorningAnalysis(context: Context) {
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        val endTimeStr = prefs.getString("lSEndTime", "07:00") ?: "07:00"
        val endHour = endTimeStr.split(":").getOrNull(0)?.toIntOrNull() ?: 7
        val endMinute = endTimeStr.split(":").getOrNull(1)?.toIntOrNull() ?: 0

        // Target 30 min after configured wake time
        val targetMinute = endHour * 60 + endMinute + 30
        val delayMs = calculateDelayUntilMinuteOfDay(targetMinute)

        val morningWork = OneTimeWorkRequestBuilder<SleepInferenceWorker>()
            .setInitialDelay(delayMs, TimeUnit.MILLISECONDS)
            .setConstraints(
                Constraints.Builder()
                    .setRequiresBatteryNotLow(true)
                    .build()
            )
            .addTag(MORNING_ANALYSIS_TAG)
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            MORNING_ANALYSIS_TAG,
            ExistingWorkPolicy.REPLACE,
            morningWork
        )

        Log.d(TAG, "Morning analysis scheduled with delay=${delayMs / 60000} min")
    }

    /**
     * Run inference immediately (triggered from Flutter when user opens app).
     */
    fun runInferenceNow(context: Context) {
        val immediateWork = OneTimeWorkRequestBuilder<SleepInferenceWorker>()
            .addTag("sleep_inference_immediate")
            .build()

        WorkManager.getInstance(context).enqueue(immediateWork)
        Log.d(TAG, "Immediate inference triggered")
    }

    /**
     * Register screen and charging BroadcastReceivers dynamically.
     */
    fun registerReceivers(context: Context) {
        if (screenReceiver == null) {
            screenReceiver = ScreenStateReceiver()
            val screenFilter = IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(Intent.ACTION_USER_PRESENT)
            }
            context.applicationContext.registerReceiver(screenReceiver, screenFilter)
            Log.d(TAG, "Screen state receiver registered (with USER_PRESENT)")
        }

        if (chargingReceiver == null) {
            chargingReceiver = ChargingStateReceiver()
            val chargingFilter = IntentFilter().apply {
                addAction(Intent.ACTION_POWER_CONNECTED)
                addAction(Intent.ACTION_POWER_DISCONNECTED)
            }
            context.applicationContext.registerReceiver(chargingReceiver, chargingFilter)
            Log.d(TAG, "Charging state receiver registered")
        }
    }

    /**
     * Unregister receivers and cancel all work.
     */
    fun cancelAll(context: Context) {
        WorkManager.getInstance(context).apply {
            cancelUniqueWork(OVERNIGHT_WORK_TAG)
            cancelUniqueWork(MORNING_ANALYSIS_TAG)
        }

        unregisterReceivers(context)
        Log.d(TAG, "All sleep tracking work cancelled")
    }

    private fun unregisterReceivers(context: Context) {
        screenReceiver?.let {
            try {
                context.applicationContext.unregisterReceiver(it)
            } catch (_: IllegalArgumentException) { }
            screenReceiver = null
        }
        chargingReceiver?.let {
            try {
                context.applicationContext.unregisterReceiver(it)
            } catch (_: IllegalArgumentException) { }
            chargingReceiver = null
        }
    }

    private fun calculateDelayUntilMinuteOfDay(targetMinute: Int): Long {
        val now = Calendar.getInstance()
        val nowMinute = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
        val delayMinutes = if (targetMinute > nowMinute) {
            targetMinute - nowMinute
        } else {
            (24 * 60 - nowMinute) + targetMinute
        }
        return delayMinutes * 60 * 1000L
    }
}
