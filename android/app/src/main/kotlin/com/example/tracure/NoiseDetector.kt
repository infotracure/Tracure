package com.tracure.main

import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.content.ContextCompat
import java.io.File
import kotlin.math.log10

data class NoiseStats(
    val avgDb: Float,
    val maxDb: Float,
    val minDb: Float
)

class NoiseDetector(
    private val context: Context,
    private val sampleIntervalMs: Long = 30_000L
) {
    private var mediaRecorder: MediaRecorder? = null
    private val handler = Handler(Looper.getMainLooper())

    private var sampleCount = 0
    private var sumDb = 0.0
    private var maxDb = Float.MIN_VALUE
    private var minDb = Float.MAX_VALUE

    /** Latest sampled noise level in dB. -1 means no reading yet. */
    var latestDb: Float = -1f
        private set

    private val sampleRunnable = object : Runnable {
        override fun run() {
            sample()
            handler.postDelayed(this, sampleIntervalMs)
        }
    }

    fun start() {
        if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "RECORD_AUDIO permission not granted — noise detection skipped")
            return
        }
        try {
            val tempFile = File(context.cacheDir, "noise_temp.3gp")
            mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(context)
            } else {
                @Suppress("DEPRECATION")
                MediaRecorder()
            }
            mediaRecorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
                setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
                setOutputFile(tempFile.absolutePath)
                prepare()
                start()
            }
            // First call resets the internal amplitude counter
            mediaRecorder?.maxAmplitude
            handler.postDelayed(sampleRunnable, sampleIntervalMs)
            Log.d(TAG, "Noise detection started (interval=${sampleIntervalMs}ms)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start noise detection: ${e.message}")
            mediaRecorder = null
        }
    }

    fun stop() {
        handler.removeCallbacks(sampleRunnable)
        try {
            mediaRecorder?.stop()
            mediaRecorder?.release()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping MediaRecorder: ${e.message}")
        }
        mediaRecorder = null
    }

    /** Returns the accumulated noise stats and resets counters for the next segment. */
    fun getStatsAndReset(): NoiseStats {
        val stats = NoiseStats(
            avgDb = if (sampleCount > 0) (sumDb / sampleCount).toFloat() else 0f,
            maxDb = if (maxDb != Float.MIN_VALUE) maxDb else 0f,
            minDb = if (minDb != Float.MAX_VALUE) minDb else 0f
        )
        resetStats()
        return stats
    }

    private fun sample() {
        val amplitude = mediaRecorder?.maxAmplitude ?: return
        if (amplitude <= 0) return

        val db = (20 * log10(amplitude.toDouble())).toFloat()
        latestDb = db
        sampleCount++
        sumDb += db
        if (db > maxDb) maxDb = db
        if (db < minDb) minDb = db

        Log.d(TAG, "Noise sample: ${db}dB (amplitude=$amplitude)")
    }

    private fun resetStats() {
        sampleCount = 0
        sumDb = 0.0
        maxDb = Float.MIN_VALUE
        minDb = Float.MAX_VALUE
    }

    companion object {
        private const val TAG = "NoiseDetector"
    }
}
