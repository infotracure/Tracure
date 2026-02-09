package com.tracure.main.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase

@Database(
    entities = [SleepSession::class, SensorSample::class, UserSleepPattern::class],
    version = 2,
    exportSchema = true
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun sleepSessionDao(): SleepSessionDao
    abstract fun sensorSampleDao(): SensorSampleDao
    abstract fun userSleepPatternDao(): UserSleepPatternDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                // Add new columns to sleep_sessions
                db.execSQL("ALTER TABLE sleep_sessions ADD COLUMN qualityScore INTEGER NOT NULL DEFAULT 0")
                db.execSQL("ALTER TABLE sleep_sessions ADD COLUMN confidenceLevel TEXT NOT NULL DEFAULT 'LOW'")
                db.execSQL("ALTER TABLE sleep_sessions ADD COLUMN interruptions INTEGER NOT NULL DEFAULT 0")

                // Create sensor_samples table
                db.execSQL("""
                    CREATE TABLE IF NOT EXISTS sensor_samples (
                        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        timestamp INTEGER NOT NULL,
                        signalType TEXT NOT NULL,
                        value REAL NOT NULL,
                        valueSecondary REAL,
                        sessionDate TEXT NOT NULL
                    )
                """)

                // Create user_sleep_patterns table
                db.execSQL("""
                    CREATE TABLE IF NOT EXISTS user_sleep_patterns (
                        id INTEGER NOT NULL PRIMARY KEY,
                        avgSleepStartMinute INTEGER NOT NULL DEFAULT 1380,
                        avgWakeMinute INTEGER NOT NULL DEFAULT 420,
                        stdDevMinutes INTEGER NOT NULL DEFAULT 60,
                        totalSessions INTEGER NOT NULL DEFAULT 0,
                        lastUpdated INTEGER NOT NULL DEFAULT 0
                    )
                """)

                // Insert default pattern
                db.execSQL("""
                    INSERT OR IGNORE INTO user_sleep_patterns (id, avgSleepStartMinute, avgWakeMinute, stdDevMinutes, totalSessions, lastUpdated)
                    VALUES (1, 1380, 420, 60, 0, ${System.currentTimeMillis()})
                """)
            }
        }

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "sleep_db"
                )
                    .addMigrations(MIGRATION_1_2)
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
