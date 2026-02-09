package com.tracure.main

import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import com.tracure.main.db.AppDatabase
import com.tracure.main.scheduler.SleepWorkScheduler
import kotlinx.coroutines.*

class SleepServicePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        private const val TAG = "SleepServicePlugin"
    }

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
                startTracking(call)
                result.success("Started")
            }

            "stopSleepTracking" -> {
                stopTracking()
                result.success("Stopped")
            }

            "getSleepDataForDate" -> {
                val date = call.argument<String>("date") ?: getTodayDate()
                fetchSleepData(date, result)
            }

            "scheduleSleepTracking" -> {
                scheduleSleepTracking(call)
                result.success("Scheduled")
            }

            "cancelSleepTracking" -> {
                cancelSleepTracking()
                result.success("Cancelled")
            }

            "checkExactAlarmPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val isGranted = AlarmPermissionHelper.ensureExactAlarmPermission(context)
                    result.success(isGranted)
                } else {
                    result.success(true)
                }
            }

            "runInferenceNow" -> {
                SleepWorkScheduler.runInferenceNow(context)
                result.success("Inference triggered")
            }

            "getSleepQuality" -> {
                val date = call.argument<String>("date") ?: getTodayDate()
                fetchSleepQuality(date, result)
            }

            "requestBatteryExemption" -> {
                val granted = AlarmPermissionHelper.requestBatteryExemption(context)
                result.success(granted)
            }

            else -> result.notImplemented()
        }
    }

    private fun startTracking(call: MethodCall) {
        val start = call.argument<String>("lSStartTime") ?: "22:00"
        val end = call.argument<String>("lSEndTime") ?: "07:00"
        val hardStop = call.argument<String>("lSHardStopTime") ?: "10:00"
        val interval = call.argument<Int>("sleepInterval") ?: 1800

        // Save settings to SharedPreferences
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString("lSStartTime", start)
            putString("lSEndTime", end)
            putString("lSHardStopTime", hardStop)
            putInt("sleepInterval", interval)
            putString("sleepDate", getTodayDate())
            putBoolean("trackingEnabled", true)
            apply()
        }

        // Schedule WorkManager jobs instead of starting foreground service
        SleepWorkScheduler.scheduleOvernightCollection(context)
        SleepWorkScheduler.scheduleMorningAnalysis(context)
        SleepWorkScheduler.registerReceivers(context)

        Log.d(TAG, "Sleep tracking started via WorkManager")
    }

    private fun stopTracking() {
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("trackingEnabled", false).apply()

        SleepWorkScheduler.cancelAll(context)
        Log.d(TAG, "Sleep tracking stopped")
    }

    private fun scheduleSleepTracking(call: MethodCall) {
        val start = call.argument<String>("lSStartTime") ?: "22:00"
        val end = call.argument<String>("lSEndTime") ?: "07:00"

        // Save settings
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putString("lSStartTime", start)
            putString("lSEndTime", end)
            putBoolean("trackingEnabled", true)
            apply()
        }

        // Schedule WorkManager + register receivers
        SleepWorkScheduler.scheduleOvernightCollection(context)
        SleepWorkScheduler.scheduleMorningAnalysis(context)
        SleepWorkScheduler.registerReceivers(context)

        // Also keep alarm-based scheduling as a backup for reliability
        if (AlarmPermissionHelper.ensureExactAlarmPermission(context)) {
            SleepAlarmScheduler.scheduleSleepTracking(context, start, end)
        }

        Log.d(TAG, "Sleep tracking scheduled: start=$start, end=$end")
    }

    private fun cancelSleepTracking() {
        val prefs = context.getSharedPreferences("SleepPrefs", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("trackingEnabled", false).apply()

        SleepWorkScheduler.cancelAll(context)
        SleepAlarmScheduler.cancelSleepTracking(context)
        Log.d(TAG, "All sleep tracking cancelled")
    }

    private fun fetchSleepData(date: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val db = AppDatabase.getDatabase(context)
                val sessions = db.sleepSessionDao().getSessionsByDate(date)
                val temp = db.sleepSessionDao().getAllSessions()
                Log.e(TAG, "All sleep data $temp")

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
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching sleep data", e)
                withContext(Dispatchers.Main) {
                    result.success(emptyList<Map<String, String>>())
                }
            }
        }
    }

    private fun fetchSleepQuality(date: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val db = AppDatabase.getDatabase(context)
                val sessions = db.sleepSessionDao().getSessionsByDate(date)

                val qualityData = sessions.map {
                    mapOf(
                        "date" to it.date,
                        "startTime" to it.startTime,
                        "endTime" to it.endTime,
                        "qualityScore" to it.qualityScore,
                        "confidenceLevel" to it.confidenceLevel,
                        "interruptions" to it.interruptions
                    )
                }

                withContext(Dispatchers.Main) {
                    result.success(qualityData)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error fetching sleep quality", e)
                withContext(Dispatchers.Main) {
                    result.success(emptyList<Map<String, Any>>())
                }
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