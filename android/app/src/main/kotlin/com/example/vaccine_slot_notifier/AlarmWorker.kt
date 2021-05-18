package com.example.vaccine_slot_notifier

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.work.Worker
import androidx.work.WorkerParameters

class AlarmWorker(appContext: Context, workerParams: WorkerParameters) : Worker(appContext, workerParams) {
    override fun doWork(): Result {
        val am: AlarmManager = applicationContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val i: Intent = Intent(applicationContext, AlarmReceiver::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getBroadcast(applicationContext, 0, i, 0)
        am.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), pendingIntent)

        return Result.success()
    }
}