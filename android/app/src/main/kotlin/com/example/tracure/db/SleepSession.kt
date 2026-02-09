package com.tracure.main.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sleep_sessions")
data class SleepSession(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val date: String,
    val startTime: String,
    val endTime: String,
    val qualityScore: Int = 0,
    val confidenceLevel: String = "LOW",
    val interruptions: Int = 0
)
