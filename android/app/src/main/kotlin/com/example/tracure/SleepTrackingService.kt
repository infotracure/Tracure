package com.tracure.main


import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*
import com.tracure.main.db.AppDatabase
import com.tracure.main.db.SleepSession
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import kotlin.math.abs
import kotlin.math.sqrt

class SleepTrackingService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var lastMovementTime: Long = 0
    private var isSleeping = false
    private var sleepStartTime: String? = null

    private var startTimeHour = 22
    private var endTimeHour = 7
    private var hardStopTimeHour = 10
    private var idleDurationMs = 1 * 60 * 1000L // default 5 min
//    private var todayDate: String = ""

    private var lastX = 0f
    private var lastY = 0f
    private var lastZ = 0f
    private var initialized = false

    private val THRESHOLD = 2f

    companion object {
        var isRunning = false
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("Abhay","OnCreate Started")
        isRunning = true
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        startForegroundService()
        accelerometer?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
        lastMovementTime = System.currentTimeMillis()
        sleepStartTime = getCurrentTime()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Get params from Flutter
        Log.d("Abhay","OnStart Started")
        val startTimeStr = intent?.getStringExtra("lSStartTime") ?: "22:00"
        val endTimeStr = intent?.getStringExtra("lSEndTime") ?: "07:00"
        val hardStopStr = intent?.getStringExtra("lSHardStopTime") ?: "10:00"
        val intervalSecs = intent?.getIntExtra("sleepInterval", 1800) ?: 1800
        val sleepDateStr = computeSleepStartDate(endTimeStr)

//        todayDate = sleepDateStr

        startTimeHour = startTimeStr.split(":").getOrNull(0)?.toIntOrNull() ?: 22
        endTimeHour = endTimeStr.split(":").getOrNull(0)?.toIntOrNull() ?: 7
        hardStopTimeHour = hardStopStr.split(":").getOrNull(0)?.toIntOrNull() ?: 10
        idleDurationMs = (intervalSecs * 1000L).coerceAtLeast(60000L)

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        if (isSleeping && sleepStartTime != null) {
            val sleepEnd = getCurrentTime()
            sendSleepData(sleepStartTime!!, sleepEnd)
        }
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onSensorChanged(event: SensorEvent) {
        if (!isWithinSleepWindow()) return

        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]
        val now = System.currentTimeMillis()

        if (!initialized) {
            lastX = x
            lastY = y
            lastZ = z
            initialized = true
            lastMovementTime = now
            return
        }

        val deltaX = abs(lastX - x)
        val deltaY = abs(lastY - y)
        val deltaZ = abs(lastZ - z)

        lastX = x
        lastY = y
        lastZ = z

        val movement = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)

        // Log the movement for debugging
        Log.d("Sensor", "Δ Movement: $movement  : time: $sleepStartTime")

        if (isSleeping && isEndService) {
            val sleepEnd = getCurrentTime()
            sendSleepData(sleepStartTime ?: "Unknown", sleepEnd)
            isEndService = false
        }

        if (movement > THRESHOLD) {
            if (isSleeping) {
                isSleeping = false
                val sleepEnd = getCurrentTime()
                sendSleepData(sleepStartTime ?: "Unknown", sleepEnd)
//                sleepStartTime = null
            }
            lastMovementTime = now
            sleepStartTime = getCurrentTime()

        } else if (!isSleeping && now - lastMovementTime > idleDurationMs) {
            isSleeping = true
            //sleepStartTime = getCurrentTime()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun isWithinSleepWindow(): Boolean {
        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        return (hour >= startTimeHour || hour < endTimeHour)
    }

    private fun getCurrentTime(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        return sdf.format(Date())
    }

    private fun getTodayDate(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(Date())
    }

    private fun sendSleepData(start: String, end: String) {
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
        val startDateTime = LocalDateTime.parse(start, formatter)
        val sleepDate = calculateSleepDate(startDateTime)
        Log.d("SleepTracking", "Sleep on $sleepDate from $start to $end")

        val session = SleepSession(
            date = sleepDate,
            startTime = start,
            endTime = end
        )

        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getDatabase(applicationContext)
            db.sleepSessionDao().insert(session)
            deletePast7daysEntries()
        }
    }

    private fun calculateSleepDate(startDateTime: LocalDateTime): String {
        val cutoffHour = 4

        val sleepDate = if (startDateTime.hour < cutoffHour) {
            startDateTime.toLocalDate().minusDays(1)
        } else {
            startDateTime.toLocalDate()
        }

        return sleepDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))
    }

    private fun deletePast7daysEntries(){
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getDatabase(applicationContext)
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
            val cutoffDate = LocalDate.now().minusDays(7).format(formatter)
            db.sleepSessionDao().deleteSessionsBefore(cutoffDate)
        }
    }

    private fun computeSleepStartDate(endTimeStr: String): String {
        val endHour = endTimeStr.split(":").getOrNull(0)?.toIntOrNull() ?: 7
        val endMinute = endTimeStr.split(":").getOrNull(1)?.toIntOrNull() ?: 0

        val now = Calendar.getInstance()
        val currentHour = now.get(Calendar.HOUR_OF_DAY)
        val currentMinute = now.get(Calendar.MINUTE)

        val isBeforeEnd = currentHour < endHour || (currentHour == endHour && currentMinute < endMinute)

        if (isBeforeEnd) {
            now.add(Calendar.DATE, -1)
        }

        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(now.time)
    }

    private fun startForegroundService() {
        val channelId = "SleepTrackingChannel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(
                channelId,
                "Sleep Tracking Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(chan)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Sleep tracking active")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(1, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH)
        } else {
            startForeground(1, notification)
        }
    }
}

