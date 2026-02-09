package com.tracure.main.worker

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.tracure.main.db.AppDatabase
import com.tracure.main.engine.SleepInferenceEngine
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Calendar
import java.util.Locale

class SleepInferenceWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    companion object {
        private const val TAG = "SleepInferenceWorker"
    }

    override suspend fun doWork(): Result {
        Log.d(TAG, "Starting sleep inference")

        return try {
            val db = AppDatabase.getDatabase(applicationContext)
            val engine = SleepInferenceEngine()

            // Determine which date to analyze
            // If running in the morning, analyze last night (yesterday's date if after midnight)
            val sleepDate = computeSleepDate()
            Log.d(TAG, "Analyzing sleep for date: $sleepDate")

            // Check if we already have sessions for this date
            val existingSessions = db.sleepSessionDao().getSessionsByDate(sleepDate)
            if (existingSessions.isNotEmpty()) {
                Log.d(TAG, "Sessions already exist for $sleepDate, checking if re-analysis needed")
                // If existing sessions have quality > 0, they were already inferred
                if (existingSessions.any { it.qualityScore > 0 }) {
                    Log.d(TAG, "Already inferred for $sleepDate, skipping")
                    return Result.success()
                }
                // Delete old raw sessions to replace with inferred ones
                db.sleepSessionDao().deleteSessionsForDate(sleepDate)
            }

            // Get overnight samples — we need both the sleep date and next day (for after-midnight samples)
            val nextDate = getNextDate(sleepDate)
            val samples = db.sensorSampleDao().getSamplesForDates(listOf(sleepDate, nextDate))

            if (samples.isEmpty()) {
                Log.d(TAG, "No sensor samples found for $sleepDate, nothing to infer")
                return Result.success()
            }

            // Get historical pattern
            val pattern = db.userSleepPatternDao().getPattern()

            // Run inference
            val result = engine.infer(samples, pattern, sleepDate)

            // Store results
            for (session in result.sessions) {
                db.sleepSessionDao().insert(session)
                Log.d(TAG, "Stored inferred session: ${session.startTime} → ${session.endTime}")
            }

            // Update historical pattern
            result.updatedPattern?.let {
                db.userSleepPatternDao().upsert(it)
                Log.d(TAG, "Updated sleep pattern: avg start=${it.avgSleepStartMinute}, avg wake=${it.avgWakeMinute}")
            }

            // Clean up old sensor data (>7 days)
            val cutoffDate = LocalDate.now().minusDays(7).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
            db.sensorSampleDao().deleteOlderThan(cutoffDate)
            db.sleepSessionDao().deleteSessionsBefore(cutoffDate)

            Log.d(TAG, "Inference complete: ${result.sessions.size} sessions detected")
            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Inference failed", e)
            Result.retry()
        }
    }

    private fun computeSleepDate(): String {
        val cal = Calendar.getInstance()

        // Sleep date = the evening the sleep session started.
        // Always subtract 1 day: whether inference runs at 7 AM or 3 PM,
        // we're analyzing the most recent completed night (yesterday evening → this morning).
        cal.add(Calendar.DATE, -1)

        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(cal.time)
    }

    private fun getNextDate(dateStr: String): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val cal = Calendar.getInstance().apply {
            time = sdf.parse(dateStr) ?: return dateStr
            add(Calendar.DATE, 1)
        }
        return sdf.format(cal.time)
    }
}
