package com.example.vaccine_slot_notifier

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import androidx.core.content.ContextCompat.getSystemService

var mp: MediaPlayer? = null

class AlarmActionsReceiver : BroadcastReceiver() {

    var v: Vibrator? = null

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.extras != null) {
            val action: String? = intent.getStringExtra("ACTION")

            if (action == "DISMISS") {
                context.sendBroadcast(Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS))
                val notifManager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notifManager.cancel(19002007)

                v = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                v?.cancel()

                mp?.reset()
                mp = null
            } else if (action == "START") {
                v = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    v?.vibrate(VibrationEffect.createWaveform(longArrayOf(1000, 1000), 0));
                }

                val defaultRingtoneUri: Uri = RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_ALARM)

                mp = MediaPlayer.create(context, defaultRingtoneUri)
                mp?.start()
            }
        }
    }
}