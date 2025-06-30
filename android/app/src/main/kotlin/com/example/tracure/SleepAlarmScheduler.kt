package com.tracure.main

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar

object SleepAlarmScheduler {

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

        Log.d("SleepAlarmScheduler", "Sleep tracking alarms cancelled")
    }
}
