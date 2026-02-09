package com.tracure.main.engine

import android.util.Log
import com.tracure.main.db.SensorSample
import com.tracure.main.db.SleepSession
import com.tracure.main.db.UserSleepPattern
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

class SleepInferenceEngine {

    companion object {
        private const val TAG = "SleepInferenceEngine"
        private const val SLEEP_THRESHOLD = 0.60
        private const val MIN_SLEEP_DURATION_MS = 3 * 60 * 60 * 1000L      // 3 hours
        private const val MAX_SLEEP_DURATION_MS = 14 * 60 * 60 * 1000L     // 14 hours
        private const val SUSTAINED_INACTIVITY_MS = 30 * 60 * 1000L        // 30 min
        private const val BRIEF_WAKE_THRESHOLD_MS = 5 * 60 * 1000L         // 5 min
        private const val MINUTE_MS = 60 * 1000L
    }

    data class InferenceResult(
        val sessions: List<SleepSession>,
        val updatedPattern: UserSleepPattern?
    )

    fun infer(
        samples: List<SensorSample>,
        pattern: UserSleepPattern?,
        sleepDate: String
    ): InferenceResult {
        Log.d(TAG, "Starting inference for date=$sleepDate, samples=${samples.size}")

        if (samples.isEmpty()) {
            Log.d(TAG, "No samples available, skipping inference")
            return InferenceResult(emptyList(), null)
        }

        // Separate samples by type
        val screenEvents = samples.filter { it.signalType == "SCREEN_STATE" }
            .sortedBy { it.timestamp }
        val userPresentEvents = samples.filter { it.signalType == "USER_PRESENT" }
            .sortedBy { it.timestamp }
        val motionSamples = samples.filter { it.signalType == "ACCELEROMETER" }
            .sortedBy { it.timestamp }
        val chargingEvents = samples.filter { it.signalType == "CHARGING_STATE" }
            .sortedBy { it.timestamp }

        Log.d(TAG, "Signals: screen=${screenEvents.size}, userPresent=${userPresentEvents.size}, motion=${motionSamples.size}, charging=${chargingEvents.size}")

        // Build the analysis window: from 8PM of sleepDate to 12PM next day
        val analysisStart = getTimestamp(sleepDate, 20, 0)
        val analysisEnd = getTimestamp(sleepDate, 12, 0, nextDay = true)

        // Build minute-by-minute timeline
        val timeline = buildTimeline(
            analysisStart, analysisEnd,
            screenEvents, userPresentEvents, motionSamples, chargingEvents
        )

        if (timeline.isEmpty()) {
            Log.d(TAG, "Empty timeline, skipping inference")
            return InferenceResult(emptyList(), null)
        }

        // Find all sleep windows
        val sleepWindows = findSleepWindows(timeline, pattern)
        if (sleepWindows.isEmpty()) {
            Log.d(TAG, "No sleep windows detected")
            return InferenceResult(emptyList(), null)
        }

        val dateFormatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        val confidence = computeConfidence(screenEvents.size, motionSamples.size, chargingEvents.size)
        val sessions = mutableListOf<SleepSession>()

        for (window in sleepWindows) {
            val duration = window.second - window.first

            // Validate each window individually
            if (duration < MIN_SLEEP_DURATION_MS || duration > MAX_SLEEP_DURATION_MS) {
                Log.d(TAG, "Sleep window out of bounds: ${duration / 3600000}h, skipping")
                continue
            }

            val interruptions = countInterruptions(userPresentEvents, screenEvents, window.first, window.second)
            val quality = computeQualityScore(
                durationMs = duration,
                interruptions = interruptions,
                motionSamples = motionSamples.filter {
                    it.timestamp in window.first..window.second
                },
                pattern = pattern
            )

            val session = SleepSession(
                date = sleepDate,
                startTime = dateFormatter.format(Date(window.first)),
                endTime = dateFormatter.format(Date(window.second)),
                qualityScore = quality,
                confidenceLevel = confidence,
                interruptions = interruptions
            )

            Log.d(TAG, "Inferred sleep segment: ${session.startTime} → ${session.endTime}, quality=$quality")
            sessions.add(session)
        }

        if (sessions.isEmpty()) {
            Log.d(TAG, "All detected windows were out of bounds")
            return InferenceResult(emptyList(), null)
        }

        // Update historical pattern using the longest session
        val longestWindow = sleepWindows.maxByOrNull { it.second - it.first }!!
        val updatedPattern = updatePattern(pattern, longestWindow.first, longestWindow.second)

        Log.d(TAG, "Inference complete: ${sessions.size} sleep segment(s) detected")
        return InferenceResult(sessions, updatedPattern)
    }

    // --- Timeline Building ---

    private data class MinuteSlot(
        val timestamp: Long,
        var screenActive: Boolean = false,   // true only when user actually unlocked
        var screenOnPassive: Boolean = false, // screen lit up (notification) but no unlock
        var motionLevel: Float = 0f,
        var hasMotionData: Boolean = false,
        var isCharging: Boolean = false,
        var inactivityScore: Double = 0.0
    )

    private fun buildTimeline(
        startMs: Long,
        endMs: Long,
        screenEvents: List<SensorSample>,
        userPresentEvents: List<SensorSample>,
        motionSamples: List<SensorSample>,
        chargingEvents: List<SensorSample>
    ): List<MinuteSlot> {
        val slots = mutableListOf<MinuteSlot>()
        var t = startMs
        while (t < endMs) {
            slots.add(MinuteSlot(timestamp = t))
            t += MINUTE_MS
        }

        if (slots.isEmpty()) return slots

        // Build a set of timestamps (minute-rounded) where user actually unlocked
        val userUnlockMinutes = userPresentEvents.map { (it.timestamp - startMs) / MINUTE_MS }.toSet()

        // Fill screen state using USER_PRESENT as the real activity signal
        // SCREEN_ON without USER_PRESENT = passive (notification), doesn't count as active
        var lastScreenOn = false
        var screenIdx = 0
        for (slot in slots) {
            while (screenIdx < screenEvents.size && screenEvents[screenIdx].timestamp <= slot.timestamp + MINUTE_MS) {
                lastScreenOn = screenEvents[screenIdx].value == 1.0f
                screenIdx++
            }
            val slotMinute = (slot.timestamp - startMs) / MINUTE_MS
            val userUnlocked = userUnlockMinutes.contains(slotMinute)
            slot.screenActive = lastScreenOn && userUnlocked
            slot.screenOnPassive = lastScreenOn && !userUnlocked
        }

        // Fill motion data: assign motion values to nearest slot
        for (motion in motionSamples) {
            val slotIdx = ((motion.timestamp - startMs) / MINUTE_MS).toInt()
            if (slotIdx in slots.indices) {
                slots[slotIdx].motionLevel = motion.value
                slots[slotIdx].hasMotionData = true
            }
        }

        // Fill charging state
        var lastChargingState = false
        var chargingIdx = 0
        for (slot in slots) {
            while (chargingIdx < chargingEvents.size && chargingEvents[chargingIdx].timestamp <= slot.timestamp + MINUTE_MS) {
                lastChargingState = chargingEvents[chargingIdx].value == 1.0f
                chargingIdx++
            }
            slot.isCharging = lastChargingState
        }

        // Compute baseline motion for normalization
        val motionValues = slots.filter { it.hasMotionData }.map { it.motionLevel }
        val maxMotion = if (motionValues.isNotEmpty()) motionValues.max() else 15f
        val normalizedMaxMotion = max(maxMotion, 1f)

        // Compute inactivity score for each slot using a rolling window
        val windowSize = 30 // 30-minute rolling window
        for (i in slots.indices) {
            val windowStart = max(0, i - windowSize / 2)
            val windowEnd = min(slots.size - 1, i + windowSize / 2)
            val window = slots.subList(windowStart, windowEnd + 1)

            val screenInactivity = 1.0 - (window.count { it.screenActive }.toDouble() / window.size)
            val motionInactivity = if (window.any { it.hasMotionData }) {
                1.0 - (window.filter { it.hasMotionData }.map { it.motionLevel }.average() / normalizedMaxMotion)
                    .coerceIn(0.0, 1.0)
            } else {
                0.7 // no motion data = moderate inactivity assumption
            }
            val chargingScore = window.count { it.isCharging }.toDouble() / window.size

            slots[i].inactivityScore = (
                0.40 * screenInactivity +
                0.35 * motionInactivity +
                0.25 * chargingScore
            )
        }

        return slots
    }

    // --- Sleep Window Detection ---

    private fun findSleepWindows(
        timeline: List<MinuteSlot>,
        pattern: UserSleepPattern?
    ): List<Pair<Long, Long>> {
        if (timeline.isEmpty()) return emptyList()

        // Apply historical prior
        val scored = timeline.map { slot ->
            val rawScore = slot.inactivityScore
            val prior = if (pattern != null && pattern.totalSessions >= 3) {
                computeTimePrior(slot.timestamp, pattern)
            } else {
                computeDefaultTimePrior(slot.timestamp)
            }
            val adjusted = 0.7 * rawScore + 0.3 * prior
            slot to adjusted
        }

        // Find ALL sustained periods above threshold (minimum 30 min each)
        val runs = mutableListOf<Pair<Int, Int>>() // startIdx to endIdx
        var currentStart = -1
        var currentLength = 0

        for (i in scored.indices) {
            if (scored[i].second > SLEEP_THRESHOLD) {
                if (currentStart == -1) currentStart = i
                currentLength++
            } else {
                if (currentLength >= 30) {
                    runs.add(currentStart to (currentStart + currentLength - 1))
                }
                currentStart = -1
                currentLength = 0
            }
        }
        // Check final run
        if (currentLength >= 30) {
            runs.add(currentStart to (currentStart + currentLength - 1))
        }

        if (runs.isEmpty()) return emptyList()

        // Refine each run and return as timestamp pairs
        return runs.map { (startIdx, endIdx) ->
            val rawStart = timeline[startIdx].timestamp
            val rawEnd = timeline[endIdx].timestamp
            val refinedStart = refineOnset(rawStart, timeline)
            val refinedEnd = refineWake(rawEnd, timeline)
            Pair(refinedStart, refinedEnd)
        }
    }

    private fun refineOnset(detectedStart: Long, timeline: List<MinuteSlot>): Long {
        // Find the last screen-OFF transition before detectedStart
        var lastScreenOff = detectedStart
        for (slot in timeline) {
            if (slot.timestamp > detectedStart) break
            if (!slot.screenActive) {
                lastScreenOff = slot.timestamp
            }
        }
        return lastScreenOff
    }

    private fun refineWake(detectedEnd: Long, timeline: List<MinuteSlot>): Long {
        // Find the first sustained screen-ON after detectedEnd
        var consecutiveOn = 0
        for (slot in timeline) {
            if (slot.timestamp < detectedEnd) continue
            if (slot.screenActive) {
                consecutiveOn++
                if (consecutiveOn >= 5) { // 5 minutes of screen-on
                    return slot.timestamp - (4 * MINUTE_MS)
                }
            } else {
                consecutiveOn = 0
            }
        }
        return detectedEnd
    }

    // --- Time Prior (Bayesian) ---

    private fun computeTimePrior(timestampMs: Long, pattern: UserSleepPattern): Double {
        val cal = Calendar.getInstance().apply { timeInMillis = timestampMs }
        var minuteOfDay = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)

        // Normalize around midnight for sleep times
        val sleepCenter = if (pattern.avgSleepStartMinute > 720) {
            // Sleep starts in PM — center is between sleep start and wake
            val adjustedStart = pattern.avgSleepStartMinute - 1440 // make negative for math
            (adjustedStart + pattern.avgWakeMinute) / 2.0
        } else {
            (pattern.avgSleepStartMinute + pattern.avgWakeMinute) / 2.0
        }

        if (minuteOfDay > 720) minuteOfDay -= 1440 // normalize PM to negative

        val stdDev = max(pattern.stdDevMinutes, 30).toDouble()
        val diff = abs(minuteOfDay - sleepCenter)
        return exp(-(diff * diff) / (2 * stdDev * stdDev))
    }

    private fun computeDefaultTimePrior(timestampMs: Long): Double {
        val cal = Calendar.getInstance().apply { timeInMillis = timestampMs }
        val hour = cal.get(Calendar.HOUR_OF_DAY)
        // Default: highest probability 11PM-6AM
        return when {
            hour in 23..23 || hour in 0..5 -> 0.9
            hour == 22 || hour == 6 -> 0.6
            hour == 21 || hour == 7 -> 0.3
            else -> 0.1
        }
    }

    // --- Interruptions ---

    private fun countInterruptions(
        userPresentEvents: List<SensorSample>,
        screenEvents: List<SensorSample>,
        sleepStart: Long,
        sleepEnd: Long
    ): Int {
        // Only count as an interruption if the user actually unlocked the phone
        // and used it for >5 minutes (screen stayed on after unlock)
        var count = 0

        for (unlock in userPresentEvents) {
            if (unlock.timestamp !in sleepStart..sleepEnd) continue

            // Find the next screen-OFF after this unlock
            val nextOff = screenEvents.firstOrNull {
                it.timestamp > unlock.timestamp && it.value == 0.0f
            }

            val usageDuration = if (nextOff != null) {
                nextOff.timestamp - unlock.timestamp
            } else {
                // Screen never turned off again within data — count it
                BRIEF_WAKE_THRESHOLD_MS + 1
            }

            if (usageDuration > BRIEF_WAKE_THRESHOLD_MS) {
                count++
            }
        }
        return count
    }

    // --- Quality Score ---

    private fun computeQualityScore(
        durationMs: Long,
        interruptions: Int,
        motionSamples: List<SensorSample>,
        pattern: UserSleepPattern?
    ): Int {
        // Duration score: 7-9 hours is ideal
        val durationHours = durationMs / 3600000.0
        val durationScore = (1.0 - abs(durationHours - 8.0) / 4.0).coerceIn(0.0, 1.0)

        // Continuity score: fewer interruptions is better
        val continuityScore = (1.0 - interruptions / 10.0).coerceIn(0.0, 1.0)

        // Motion score: less motion during sleep is better
        val motionScore = if (motionSamples.isNotEmpty()) {
            val avgMotion = motionSamples.map { it.value.toDouble() }.average()
            // Lower motion = higher quality. Gravity is ~9.8, so normalize around that.
            val deviation = motionSamples.map { it.valueSecondary?.toDouble() ?: 0.0 }.average()
            (1.0 - (deviation / 5.0).coerceIn(0.0, 1.0))
        } else 0.5

        // Consistency score: close to historical pattern is better
        val consistencyScore = if (pattern != null && pattern.totalSessions >= 3) {
            val avgDuration = pattern.let {
                val sleepMin = if (it.avgSleepStartMinute > it.avgWakeMinute) {
                    (1440 - it.avgSleepStartMinute + it.avgWakeMinute)
                } else {
                    it.avgWakeMinute - it.avgSleepStartMinute
                }
                sleepMin.toDouble()
            }
            val deviation = abs(durationMs / 60000.0 - avgDuration)
            (1.0 - (deviation / 120.0).coerceIn(0.0, 1.0))
        } else 0.5

        val overall = (
            0.30 * durationScore +
            0.30 * continuityScore +
            0.25 * motionScore +
            0.15 * consistencyScore
        )

        return (overall * 100).toInt().coerceIn(0, 100)
    }

    // --- Confidence ---

    private fun computeConfidence(
        screenCount: Int,
        motionCount: Int,
        chargingCount: Int
    ): String {
        var score = 0
        var signals = 0

        if (screenCount >= 4) { score += 3; signals++ }
        else if (screenCount >= 2) { score += 2; signals++ }

        if (motionCount >= 10) { score += 3; signals++ }
        else if (motionCount >= 4) { score += 2; signals++ }

        if (chargingCount >= 1) { score += 1; signals++ }

        return when {
            score >= 6 && signals >= 2 -> "HIGH"
            score >= 3 && signals >= 2 -> "MEDIUM"
            else -> "LOW"
        }
    }

    // --- Pattern Update ---

    private fun updatePattern(
        existing: UserSleepPattern?,
        sleepStartMs: Long,
        sleepEndMs: Long
    ): UserSleepPattern {
        val startCal = Calendar.getInstance().apply { timeInMillis = sleepStartMs }
        val endCal = Calendar.getInstance().apply { timeInMillis = sleepEndMs }

        val startMinute = startCal.get(Calendar.HOUR_OF_DAY) * 60 + startCal.get(Calendar.MINUTE)
        val endMinute = endCal.get(Calendar.HOUR_OF_DAY) * 60 + endCal.get(Calendar.MINUTE)

        if (existing == null || existing.totalSessions == 0) {
            return UserSleepPattern(
                avgSleepStartMinute = startMinute,
                avgWakeMinute = endMinute,
                stdDevMinutes = 60,
                totalSessions = 1,
                lastUpdated = System.currentTimeMillis()
            )
        }

        // Exponential moving average (weight=0.3 for new data)
        val alpha = 0.3
        val newAvgStart = (alpha * startMinute + (1 - alpha) * existing.avgSleepStartMinute).toInt()
        val newAvgWake = (alpha * endMinute + (1 - alpha) * existing.avgWakeMinute).toInt()

        // Update std deviation (running approximation)
        val diff = abs(startMinute - existing.avgSleepStartMinute)
        val newStdDev = (alpha * diff + (1 - alpha) * existing.stdDevMinutes).toInt()
            .coerceIn(15, 180)

        return existing.copy(
            avgSleepStartMinute = newAvgStart,
            avgWakeMinute = newAvgWake,
            stdDevMinutes = newStdDev,
            totalSessions = existing.totalSessions + 1,
            lastUpdated = System.currentTimeMillis()
        )
    }

    // --- Helpers ---

    private fun getTimestamp(dateStr: String, hour: Int, minute: Int, nextDay: Boolean = false): Long {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val cal = Calendar.getInstance().apply {
            time = sdf.parse(dateStr) ?: Date()
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (nextDay) add(Calendar.DATE, 1)
        }
        return cal.timeInMillis
    }
}
