package com.example.vaccine_slot_notifier

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import java.util.concurrent.TimeUnit


class MainActivity : FlutterActivity() {

    private var ALARM_CHECK_WORKER = "ALARM_CHECK_WORKER"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var wm: WorkManager = WorkManager.getInstance(applicationContext)
        wm.cancelAllWork()

        sendBroadcast(Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS))
        var constraints: Constraints = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()

        var periodicAlarmCheckWorker: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                .addTag(ALARM_CHECK_WORKER).setConstraints(constraints)
                .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
                .build()

        wm.enqueueUniquePeriodicWork("ALARM_CHECKER", ExistingPeriodicWorkPolicy.KEEP, periodicAlarmCheckWorker)
    }


}
