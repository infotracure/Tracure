package com.tracure.main.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sensor_samples")
data class SensorSample(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val timestamp: Long,
    val signalType: String,
    val value: Float,
    val valueSecondary: Float? = null,
    val sessionDate: String
)
