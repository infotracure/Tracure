package com.tracure.main.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query

@Dao
interface SensorSampleDao {
    @Insert
    suspend fun insertAll(samples: List<SensorSample>)

    @Insert
    suspend fun insert(sample: SensorSample)

    @Query("SELECT * FROM sensor_samples WHERE sessionDate = :date ORDER BY timestamp ASC")
    suspend fun getSamplesForDate(date: String): List<SensorSample>

    @Query("SELECT * FROM sensor_samples WHERE sessionDate IN (:dates) ORDER BY timestamp ASC")
    suspend fun getSamplesForDates(dates: List<String>): List<SensorSample>

    @Query("SELECT * FROM sensor_samples WHERE signalType = :type AND sessionDate = :date ORDER BY timestamp ASC")
    suspend fun getSamplesByTypeAndDate(type: String, date: String): List<SensorSample>

    @Query("DELETE FROM sensor_samples WHERE sessionDate < :cutoffDate")
    suspend fun deleteOlderThan(cutoffDate: String)
}
