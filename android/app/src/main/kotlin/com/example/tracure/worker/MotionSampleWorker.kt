package com.tracure.main.worker

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.tracure.main.db.AppDatabase
import com.tracure.main.db.SensorSample
import kotlinx.coroutines.suspendCancellableCoroutine
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import kotlin.coroutines.resume
import kotlin.math.sqrt

class MotionSampleWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    companion object {
        private const val TAG = "MotionSampleWorker"
        private const val SAMPLE_DURATION_MS = 30_000L // 30 seconds
    }

    override suspend fun doWork(): Result {
        Log.d(TAG, "Starting motion sample collection")

        val sensorManager = applicationContext
            .getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        if (accelerometer == null) {
            Log.w(TAG, "No accelerometer available, skipping")
            return Result.success()
        }

        return try {
            val readings = collectAccelerometerSamples(sensorManager, accelerometer)

            if (readings.isNotEmpty()) {
                val magnitudes = readings.map {
                    sqrt(it.x * it.x + it.y * it.y + it.z * it.z)
                }
                val mean = magnitudes.average().toFloat()
                val variance = if (magnitudes.size > 1) {
                    magnitudes.map { (it - mean) * (it - mean) }.average().toFloat()
                } else 0f

                val now = System.currentTimeMillis()
                val sessionDate = getSessionDate(now)

                val db = AppDatabase.getDatabase(applicationContext)
                db.sensorSampleDao().insert(
                    SensorSample(
                        timestamp = now,
                        signalType = "ACCELEROMETER",
                        value = mean,
                        valueSecondary = variance,
                        sessionDate = sessionDate
                    )
                )
                Log.d(TAG, "Stored motion sample: mean=$mean, variance=$variance, readings=${readings.size}")
            }

            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Error collecting motion sample", e)
            Result.retry()
        }
    }

    private suspend fun collectAccelerometerSamples(
        sensorManager: SensorManager,
        accelerometer: Sensor
    ): List<AccelReading> = suspendCancellableCoroutine { cont ->
        val readings = mutableListOf<AccelReading>()

        val handlerThread = HandlerThread("AccelSampler").apply { start() }
        val handler = Handler(handlerThread.looper)

        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                synchronized(readings) {
                    readings.add(
                        AccelReading(event.values[0], event.values[1], event.values[2])
                    )
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        sensorManager.registerListener(
            listener,
            accelerometer,
            SensorManager.SENSOR_DELAY_NORMAL,
            handler
        )

        handler.postDelayed({
            sensorManager.unregisterListener(listener)
            handlerThread.quitSafely()
            synchronized(readings) {
                cont.resume(readings.toList())
            }
        }, SAMPLE_DURATION_MS)

        cont.invokeOnCancellation {
            sensorManager.unregisterListener(listener)
            handlerThread.quitSafely()
        }
    }

    private fun getSessionDate(timestampMs: Long): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val date = Date(timestampMs)
        val calendar = Calendar.getInstance().apply { time = date }
        if (calendar.get(Calendar.HOUR_OF_DAY) < 4) {
            calendar.add(Calendar.DATE, -1)
        }
        return sdf.format(calendar.time)
    }

    private data class AccelReading(val x: Float, val y: Float, val z: Float)
}
