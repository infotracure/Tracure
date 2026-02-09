package com.tracure.main.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_sleep_patterns")
data class UserSleepPattern(
    @PrimaryKey val id: Int = 1,
    val avgSleepStartMinute: Int = 1380,   // 23:00 default
    val avgWakeMinute: Int = 420,           // 07:00 default
    val stdDevMinutes: Int = 60,
    val totalSessions: Int = 0,
    val lastUpdated: Long = System.currentTimeMillis()
)
