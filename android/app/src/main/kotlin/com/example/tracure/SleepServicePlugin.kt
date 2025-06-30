package com.tracure.main

import android.content.Context
import android.content.Intent
import android.os.Build
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

//                AlarmPermissionHelper.askIgnoringBatteryOptimizations(context);

                if (AlarmPermissionHelper.ensureExactAlarmPermission(context)) {
                    SleepAlarmScheduler.scheduleSleepTracking(context, start, end)
                    result.success("Scheduled")
                } else {
                    result.error("PERMISSION_DENIED", "User must allow exact alarms in system settings.", null)
                }
            }

            "cancelSleepTracking" -> {
                SleepAlarmScheduler.cancelSleepTracking(context)
                result.success("Cancelled")
            }

            else -> result.notImplemented()
        }
    }

    private fun startSleepService(call: MethodCall) {
        val start = call.argument<String>("lSStartTime") ?: "22:00"
        val end = call.argument<String>("lSEndTime") ?: "07:00"
        val hardStop = call.argument<String>("lSHardStopTime") ?: "10:00"
        val interval = call.argument<Int>("sleepInterval") ?: 1800
        val sleepDate = call.argument<String>("sleepDate") ?: getTodayDate()

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
        val intent = Intent(context, SleepTrackingService::class.java)
        context.stopService(intent)
    }

    private fun fetchSleepData(date: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getDatabase(context)
            val sessions = db.sleepSessionDao().getSessionsByDate(date)

            val resultList = sessions.map {
                mapOf(
                    "date" to it.date,
                    "startTime" to it.startTime,
                    "endTime" to it.endTime
                )
            }

            withContext(Dispatchers.Main) {
                result.success(resultList)
            }
        }
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