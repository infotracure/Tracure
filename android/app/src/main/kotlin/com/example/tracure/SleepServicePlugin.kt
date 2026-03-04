package com.tracure.main

import android.app.ActivityManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.tracure.main.db.AppDatabase
import kotlinx.coroutines.*

var isEndService = false

class SleepServicePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sleep_service")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "startSleepTracking" -> {
                startSleepService(call)
                result.success("Started")
            }

            "stopSleepTracking" -> {
                stopSleepService()
                result.success("Stopped")
            }

            "getSleepDataForDate" -> {
                val date = call.argument<String>("date") ?: getTodayDate()
                fetchSleepData(date, result)
            }

            "scheduleSleepTracking" -> {
                val start = call.argument<String>("lSStartTime") ?: "22:00"
                val end = call.argument<String>("lSEndTime") ?: "07:00"
                val hardStop = call.argument<String>("lSHardStopTime") ?: "10:00"
                val interval = call.argument<Int>("lSInterval") ?: 1800
                val sleepDate = getTodayDate()

//                AlarmPermissionHelper.askIgnoringBatteryOptimizations(context);
                val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
                prefs.edit().apply {
                    putString("lSStartTime", start)
                    putString("lSEndTime", end)
                    putString("lSHardStopTime", hardStop)
                    putInt("sleepInterval", interval)
                    putString("sleepDate", sleepDate)
                    apply()
                }


                if (AlarmPermissionHelper.ensureExactAlarmPermission(context)) {
                    prefs.edit().putBoolean("sleepTrackingEnabled", true).apply()
                    SleepAlarmScheduler.scheduleSleepTracking(context, start, end)
                    result.success("Scheduled")
                } else {
                    result.error("PERMISSION_DENIED", "User must allow exact alarms in system settings.", null)
                }
            }

            "cancelSleepTracking" -> {
                val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
                prefs.edit().putBoolean("sleepTrackingEnabled", false).apply()
                SleepAlarmScheduler.cancelSleepTracking(context)
                result.success("Cancelled")
            }
            "startIfInSleepWindow" -> {
                val status = startServiceIfInSleepWindow()
                result.success(status)
            }

            "runInferenceNow" -> {
                // No-op for now — inference engine not yet implemented
                Log.d("SleepServicePlugin", "runInferenceNow called (no-op)")
                result.success(null)
            }

            "checkExactAlarmPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                   val isGranted = AlarmPermissionHelper.ensureExactAlarmPermission(context)
                    result.success(isGranted)
                } else {
                    result.success(true)
                }
            }

            "debugCheckAlarms" -> {
                val status = checkAlarmStatus()
                Log.d("SleepServicePlugin", "Alarm status: $status")
                result.success(status)
            }

            else -> result.notImplemented()
        }
    }

    private fun startSleepService(call: MethodCall) {

        val start = call.argument<String>("lSStartTime") ?: "22:00"
        val end = call.argument<String>("lSEndTime") ?: "07:00"
        val hardStop = call.argument<String>("lSHardStopTime") ?: "10:00"
        val interval = call.argument<Int>("sleepInterval") ?: 1800
        val sleepDate = getTodayDate()

        // ✅ Save to SharedPreferences
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString("lSStartTime", start)
            putString("lSEndTime", end)
            putString("lSHardStopTime", hardStop)
            putInt("sleepInterval", interval)
            putString("sleepDate", sleepDate)
            apply()
        }

        val intent = Intent(context, SleepTrackingService::class.java).apply {
            putExtra("lSStartTime", start)
            putExtra("lSEndTime", end)
            putExtra("lSHardStopTime", hardStop)
            putExtra("sleepInterval", interval)
            putExtra("sleepDate", sleepDate)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun stopSleepService() {
        isEndService = true
        val intent = Intent(context, SleepTrackingService::class.java)
        context.stopService(intent)
    }

    private fun startServiceIfInSleepWindow(): String {
        if (SleepTrackingService.isRunning) return "already_running"

        // ACTIVITY_RECOGNITION is required for FOREGROUND_SERVICE_TYPE_HEALTH on Android 14+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val hasActivityPerm = context.checkSelfPermission(android.Manifest.permission.ACTIVITY_RECOGNITION) ==
                    android.content.pm.PackageManager.PERMISSION_GRANTED
            if (!hasActivityPerm) {
                Log.w("SleepServicePlugin", "ACTIVITY_RECOGNITION not granted — cannot start service")
                return "missing_permission"
            }
        }

        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        val startStr = prefs.getString("lSStartTime", "22:00") ?: "22:00"
        val endStr = prefs.getString("lSEndTime", "07:00") ?: "07:00"

        val startHour = startStr.split(":").getOrNull(0)?.toIntOrNull() ?: 22
        val startMin = startStr.split(":").getOrNull(1)?.toIntOrNull() ?: 0
        val endHour = endStr.split(":").getOrNull(0)?.toIntOrNull() ?: 7
        val endMin = endStr.split(":").getOrNull(1)?.toIntOrNull() ?: 0

        val cal = java.util.Calendar.getInstance()
        val nowMinutes = cal.get(java.util.Calendar.HOUR_OF_DAY) * 60 + cal.get(java.util.Calendar.MINUTE)
        val startMinutes = startHour * 60 + startMin
        val endMinutes = endHour * 60 + endMin

        val isInWindow = if (startMinutes <= endMinutes) {
            // Same-day window (e.g. 06:00 – 10:00)
            nowMinutes in startMinutes until endMinutes
        } else {
            // Crosses midnight (e.g. 22:00 – 07:00)
            nowMinutes >= startMinutes || nowMinutes < endMinutes
        }

        if (!isInWindow) return "not_in_window"

        // Start the service with saved prefs
        val hardStop = prefs.getString("lSHardStopTime", "10:00") ?: "10:00"
        val interval = prefs.getInt("sleepInterval", 1800)
        val sleepDate = getTodayDate()

        val intent = Intent(context, SleepTrackingService::class.java).apply {
            putExtra("lSStartTime", startStr)
            putExtra("lSEndTime", endStr)
            putExtra("lSHardStopTime", hardStop)
            putExtra("sleepInterval", interval)
            putExtra("sleepDate", sleepDate)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }

        Log.d("SleepServicePlugin", "Service started — app opened during sleep window ($startStr - $endStr)")
        return "started"
    }

    private fun fetchSleepData(date: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getDatabase(context)
            val sessions = db.sleepSessionDao().getSessionsByDate(date)
            val temp = db.sleepSessionDao().getAllSessions()
            Log.e("All Sleep Data",temp.toString())
            val resultList = sessions.map {
                val hasNoise = it.avgNoise > 0f || it.maxNoise > 0f || it.minNoise > 0f
                mapOf(
                    "date" to it.date,
                    "startTime" to it.startTime,
                    "endTime" to it.endTime,
                    "avgNoise" to if (hasNoise) it.avgNoise else "",
                    "maxNoise" to if (hasNoise) it.maxNoise else "",
                    "minNoise" to if (hasNoise) it.minNoise else ""
                )
            }

            withContext(Dispatchers.Main) {
                result.success(resultList)
            }
        }
    }

    private fun checkAlarmStatus(): Map<String, Any> {
        val results = mutableMapOf<String, Any>()

        // Check START alarm (request code 100)
        val startIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "START_SLEEP_TRACKING"
        }
        val startPending = PendingIntent.getBroadcast(
            context, 100, startIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        results["startAlarm"] = (startPending != null)

        // Check STOP alarm (request code 101)
        val stopIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "STOP_SLEEP_TRACKING"
        }
        val stopPending = PendingIntent.getBroadcast(
            context, 101, stopIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        results["stopAlarm"] = (stopPending != null)

        // Check watchdog alarms (request codes 200–211)
        val watchdogStatuses = mutableListOf<Boolean>()
        for (i in 0 until 12) {
            val wdIntent = Intent(context, AlarmReceiver::class.java).apply {
                action = "WATCHDOG_SLEEP_TRACKING"
            }
            val wdPending = PendingIntent.getBroadcast(
                context, 200 + i, wdIntent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )
            watchdogStatuses.add(wdPending != null)
        }
        results["watchdogAlarms"] = watchdogStatuses

        // Service running status
        results["serviceRunning"] = SleepTrackingService.isRunning

        // Saved prefs for context
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        results["scheduledStart"] = prefs.getString("lSStartTime", "not set") ?: "not set"
        results["scheduledEnd"] = prefs.getString("lSEndTime", "not set") ?: "not set"

        return results
    }

    private fun getTodayDate(): String {
        val sdf = java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.getDefault())
        return sdf.format(java.util.Date())
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivityForConfigChanges() {}
}