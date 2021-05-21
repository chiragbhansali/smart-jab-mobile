package com.example.vaccine_slot_notifier

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.*
import java.util.concurrent.TimeUnit

class BootReceiver : BroadcastReceiver() {
    private var ALARM_CHECK_WORKER = "ALARM_CHECK_WORKER"
    override fun onReceive(context: Context, p1: Intent) {
        Log.d("BootReceiver", "Restarted Device")

        if (p1 != null) {
            val action = p1.action
            if (action != null) {
                if (action.equals("android.intent.action.BOOT_COMPLETED")) {
                    Log.d("BootReceiver", "Setting Up WorkManager")
                    var wm: WorkManager = WorkManager.getInstance(context)
                    wm.cancelAllWork()


                    var constraints: Constraints = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()

                    var periodicAlarmCheckWorker: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                            .addTag(ALARM_CHECK_WORKER).setConstraints(constraints)
                            .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
                            .build()

                    wm.enqueueUniquePeriodicWork("ALARM_CHECKER", ExistingPeriodicWorkPolicy.KEEP, periodicAlarmCheckWorker)
                }
            }
        }
    }
}