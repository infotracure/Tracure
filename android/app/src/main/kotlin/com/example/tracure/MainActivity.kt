package com.tracure.main


import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.*
import com.google.android.gms.common.api.Scope
import com.google.android.gms.fitness.*
import com.google.android.gms.fitness.data.*
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.tasks.Tasks
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.LocalDate
import java.time.ZoneId
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tracure.main/fit"
    private val REQUEST_OAUTH_REQUEST_CODE = 1001
    private var resultCallback: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSteps" -> {
                    resultCallback = result
                    checkPermissionsAndReadSteps()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPermissionsAndReadSteps() {
        val fitnessOptions = getFitnessOptions()
        val account = GoogleSignIn.getAccountForExtension(this, fitnessOptions)

        if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
            GoogleSignIn.requestPermissions(
                this,
                REQUEST_OAUTH_REQUEST_CODE,
                account,
                fitnessOptions
            )
        } else {
            readSteps(account)
        }
    }

    private fun getFitnessOptions(): FitnessOptions {
        return FitnessOptions.builder()
            .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
            .build()
    }

    private fun readSteps(account: GoogleSignInAccount) {
        val end = System.currentTimeMillis()
        val start = LocalDate.now().atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()

        val readRequest = DataReadRequest.Builder()
            .aggregate(DataType.TYPE_STEP_COUNT_DELTA)
            .bucketByTime(1, TimeUnit.DAYS)
            .setTimeRange(start, end, TimeUnit.MILLISECONDS)
            .build()

        val historyClient = Fitness.getHistoryClient(this, account)
        val response = historyClient.readData(readRequest)

        Thread {
            try {
                val readResponse = Tasks.await(response)
                var totalSteps = 0

                for (bucket in readResponse.buckets) {
                    for (dataSet in bucket.dataSets) {
                        for (dp in dataSet.dataPoints) {
                            for (field in dp.dataType.fields) {
                                totalSteps += dp.getValue(field).asInt()
                            }
                        }
                    }
                }

                runOnUiThread {
                    resultCallback?.success(totalSteps)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    resultCallback?.error("FIT_ERROR", "Failed to read steps: ${e.message}", null)
                }
            }
        }.start()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_OAUTH_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            val account = GoogleSignIn.getAccountForExtension(this, getFitnessOptions())
            if (GoogleSignIn.hasPermissions(account, getFitnessOptions())) {
                readSteps(account)
            } else {
                resultCallback?.error("PERMISSION_REQUIRED", "Google Fit permission not granted", null)
            }
        } else if (requestCode == REQUEST_OAUTH_REQUEST_CODE) {
            resultCallback?.error("PERMISSION_REQUIRED", "User denied Google Fit permissions", null)
        }
    }
}