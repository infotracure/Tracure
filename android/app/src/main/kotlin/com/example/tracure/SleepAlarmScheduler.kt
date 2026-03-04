package com.tracure.main

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

object SleepAlarmScheduler {

    private const val WATCHDOG_BASE_REQUEST_CODE = 200
    private const val MAX_WATCHDOG_ALARMS = 12 // max 12 hours of watchdog coverage

    fun scheduleSleepTracking(
        context: Context,
        startTime: String = "22:00",
        endTime: String = "07:00"
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val startIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "START_SLEEP_TRACKING"
        }

        val stopIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "STOP_SLEEP_TRACKING"
        }

        val startPendingIntent = PendingIntent.getBroadcast(
            context, 100, startIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopPendingIntent = PendingIntent.getBroadcast(
            context, 101, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val now = Calendar.getInstance()
        val (startHour, startMin) = startTime.split(":").map { it.toInt() }
        val (endHour, endMin) = endTime.split(":").map { it.toInt() }

        val startCal = now.clone() as Calendar
        startCal.set(Calendar.HOUR_OF_DAY, startHour)
        startCal.set(Calendar.MINUTE, startMin)
        startCal.set(Calendar.SECOND, 0)
        if (startCal.before(now)) startCal.add(Calendar.DATE, 1) // schedule for next day if already past

        val endCal = now.clone() as Calendar
        endCal.set(Calendar.HOUR_OF_DAY, endHour)
        endCal.set(Calendar.MINUTE, endMin)
        endCal.set(Calendar.SECOND, 0)
        if (endCal.before(startCal)) endCal.add(Calendar.DATE, 1)

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            startCal.timeInMillis,
            startPendingIntent
        )

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            endCal.timeInMillis,
            stopPendingIntent
        )

        Log.d("SleepAlarmScheduler", "Sleep tracking scheduled: start=${startCal.time}, end=${endCal.time}")

        // Schedule hourly watchdog alarms between start and end
        scheduleWatchdogAlarms(context, startCal, endCal)
    }

    private fun scheduleWatchdogAlarms(context: Context, startCal: Calendar, endCal: Calendar) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val watchdogCal = startCal.clone() as Calendar
        watchdogCal.add(Calendar.HOUR_OF_DAY, 1) // first watchdog 1 hour after start

        var requestCode = WATCHDOG_BASE_REQUEST_CODE
        var count = 0

        while (watchdogCal.before(endCal) && count < MAX_WATCHDOG_ALARMS) {
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = "WATCHDOG_SLEEP_TRACKING"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context, requestCode, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                watchdogCal.timeInMillis,
                pendingIntent
            )
            Log.d("SleepAlarmScheduler", "Watchdog alarm #$count at ${watchdogCal.time} (rc=$requestCode)")
            watchdogCal.add(Calendar.HOUR_OF_DAY, 1)
            requestCode++
            count++
        }
    }

    fun cancelSleepTracking(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val startIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "START_SLEEP_TRACKING"
        }

        val stopIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "STOP_SLEEP_TRACKING"
        }

        val startPendingIntent = PendingIntent.getBroadcast(
            context, 100, startIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val stopPendingIntent = PendingIntent.getBroadcast(
            context, 101, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(startPendingIntent)
        alarmManager.cancel(stopPendingIntent)

        // Cancel all watchdog alarms
        for (i in 0 until MAX_WATCHDOG_ALARMS) {
            val watchdogIntent = Intent(context, AlarmReceiver::class.java).apply {
                action = "WATCHDOG_SLEEP_TRACKING"
            }
            val watchdogPending = PendingIntent.getBroadcast(
                context, WATCHDOG_BASE_REQUEST_CODE + i, watchdogIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(watchdogPending)
        }

        Log.d("SleepAlarmScheduler", "Sleep tracking alarms cancelled (including watchdogs)")
    }
}
