package com.tracure.main.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface UserSleepPatternDao {
    @Query("SELECT * FROM user_sleep_patterns WHERE id = 1")
    suspend fun getPattern(): UserSleepPattern?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(pattern: UserSleepPattern)
}
