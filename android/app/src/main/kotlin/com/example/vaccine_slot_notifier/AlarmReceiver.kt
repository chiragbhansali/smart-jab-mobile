package com.example.vaccine_slot_notifier

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat


class AlarmReceiver : BroadcastReceiver() {

    val CHANNEL_ID = "20071900"

    override fun onReceive(context: Context, intent: Intent) {

        Log.d("AlarmReceiver", "HELLO")

        val sdkVersion = android.os.Build.VERSION.SDK_INT

        if (sdkVersion < 20) {
            Log.d("Alarm Service", sdkVersion.toString())
            val i: Intent = Intent(context, AlarmActivity::class.java)
            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        } else {
            createNotificationChannel(context)
            val notif: Notification = buildNotification(context)
            with(NotificationManagerCompat.from(context)) {
                // notificationId is a unique int for each notification that you must define
                notify(19002007, notif)
            }
            val vibrateIntent: Intent = Intent(context, AlarmActionsReceiver::class.java)
            vibrateIntent.putExtra("ACTION", "START")
            context.sendBroadcast(vibrateIntent)
        }
    }

    private fun buildNotification(context: Context): Notification {
        val dismissIntent = Intent(context, AlarmActionsReceiver::class.java)
        dismissIntent.putExtra("ACTION", "DISMISS")
        val dismissPendingIntent = PendingIntent.getBroadcast(context, 1201, dismissIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val openIntent = Intent(context, AlarmActionsReceiver::class.java)
        openIntent.putExtra("ACTION", "OPENCOWIN")
        val openPendingIntent = PendingIntent.getBroadcast(context, 1202, openIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val fullScreenIntent: Intent = Intent(context, AlarmActivity::class.java)
        fullScreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        val fullScreenPendingIntent = PendingIntent.getActivity(context, 0,
                fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val sharedPrefs = context.getSharedPreferences(context.getString(R.string.shared_prefs_key), Context.MODE_PRIVATE)
        val slotsIn = sharedPrefs.getInt("slotsIn", 1)
        val place = sharedPrefs.getString("place", "")

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
                .setDefaults(0)
                .setSmallIcon(R.drawable.logo)
                .setContentTitle("Vaccines available in $slotsIn centers")
                .setContentText("Slots are available in $place")
                .setStyle(NotificationCompat.BigTextStyle()
                        .bigText("Slots are available in $place"))
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .addAction(R.drawable.dismiss, "Dismiss", dismissPendingIntent)
                .addAction(R.drawable.open, "Open CoWin", openPendingIntent)
                .setVibrate(longArrayOf(1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000))
                .setOngoing(true)

        val defaultRingtoneUri: Uri = RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_ALARM)
        builder.setSound(defaultRingtoneUri)



        return builder.build()
    }

    private fun createNotificationChannel(context: Context) {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Smart Jab Alarm"
            val descriptionText = "Notification Channel"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel("20071900", name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

}