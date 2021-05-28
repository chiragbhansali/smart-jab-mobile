package com.example.vaccine_slot_notifier

import android.app.*
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.coroutineScope
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.util.concurrent.TimeUnit


class MainActivity : FlutterActivity() {

    private var ALARM_CHECK_WORKER = "ALARM_CHECK_WORKER"
    private val CHANNEL = "com.arnav.smartjab/flutter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openMaps") {
                val url = Uri.parse("geo:${call.argument<Int>("lat")},${call.argument<Int>("long")}?q=${call.argument<String>("address")}")
                val mapIntent = Intent(Intent.ACTION_VIEW, url)
                startActivity(mapIntent)
                result.success("")
            }
//            if (call.method = ""){
//
//            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val fromAlarm = intent.getStringExtra("FROM_ALARM")

        if (fromAlarm != "TRUE") {

            var wm: WorkManager = WorkManager.getInstance(applicationContext)
            wm.cancelAllWork()

            var constraints: Constraints = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()

            var periodicAlarmCheckWorker1: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                    .addTag(ALARM_CHECK_WORKER + "_1").setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
//                    .setInitialDelay(0, TimeUnit.MINUTES)
                    .build()
            var periodicAlarmCheckWorker2: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                    .addTag(ALARM_CHECK_WORKER + "_2").setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
                    .setInitialDelay(5, TimeUnit.MINUTES)
                    .build()
            var periodicAlarmCheckWorker3: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                    .addTag(ALARM_CHECK_WORKER + "_3").setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
                    .setInitialDelay(10, TimeUnit.MINUTES)
                    .build()

            wm.enqueueUniquePeriodicWork("ALARM_CHECKER_1", ExistingPeriodicWorkPolicy.KEEP, periodicAlarmCheckWorker1)
            wm.enqueueUniquePeriodicWork("ALARM_CHECKER_2", ExistingPeriodicWorkPolicy.KEEP, periodicAlarmCheckWorker2)
            wm.enqueueUniquePeriodicWork("ALARM_CHECKER_3", ExistingPeriodicWorkPolicy.KEEP, periodicAlarmCheckWorker3)
        }
    }


}
