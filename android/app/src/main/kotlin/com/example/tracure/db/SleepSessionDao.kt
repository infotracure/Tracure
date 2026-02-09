package com.tracure.main.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface SleepSessionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(session: SleepSession)

    @Query("SELECT * FROM sleep_sessions WHERE date = :date")
    suspend fun getSessionsByDate(date: String): List<SleepSession>

    @Query("SELECT * FROM sleep_sessions ORDER BY date DESC LIMIT :limit")
    suspend fun getRecentSessions(limit: Int = 30): List<SleepSession>

    @Query("DELETE FROM sleep_sessions WHERE date < :cutoffDate")
    suspend fun deleteSessionsBefore(cutoffDate: String)

    @Query("DELETE FROM sleep_sessions WHERE date = :date")
    suspend fun deleteSessionsForDate(date: String)

    @Query("SELECT * FROM sleep_sessions")
    suspend fun getAllSessions(): List<SleepSession>
}
