package com.example.vaccine_slot_notifier

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log

var mp: MediaPlayer? = null

class AlarmActionsReceiver : BroadcastReceiver() {

    var v: Vibrator? = null

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.extras != null) {
            val action: String? = intent.getStringExtra("ACTION")
            val sharedPrefs = context.getSharedPreferences(context.getString(R.string.shared_prefs_key), Context.MODE_PRIVATE)
            val isVibrateOn = sharedPrefs.getBoolean("vibrate", false)

            if (action == "DISMISS") {
                context.sendBroadcast(Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS))
                val notifManager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notifManager.cancel(19002007)

                v = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                v?.cancel()


                mp?.stop()
                mp?.reset()
                mp?.release()
                mp = null
            } else if (action == "START") {
                if (isVibrateOn) {
                    v = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                    v?.cancel()
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        v?.vibrate(VibrationEffect.createWaveform(longArrayOf(1000, 1000), 0))
                    } else {
                        v?.vibrate(longArrayOf(1000, 1000), 0)
                    }
                }
//                val ringtoneUri: Uri = RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_ALARM)
                val default = RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_ALARM)
                val ringtoneUri = Uri.parse(sharedPrefs.getString("ringtoneUri", default.toString()))
                mp = MediaPlayer()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    mp?.setAudioAttributes(
                        AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                    )
                } else {
                    mp?.setAudioStreamType(AudioManager.STREAM_ALARM)
                }
                mp?.setDataSource(context, ringtoneUri)
                mp?.prepare()
//                mp = MediaPlayer.create(context, defaultRingtoneUri)
                mp?.start()
            }else if(action == "OPENCOWIN"){

//                val i = Intent(context, CowinActivity::class.java);
//                context.startActivity(i)

                Log.d("AlarmWorker", "HERE")

                context.sendBroadcast(Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS))
                val notifManager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notifManager.cancel(19002007)

                v = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                v?.cancel()


                mp?.stop()
                mp?.reset()
                mp?.release()
                mp = null

                val cowinIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://selfregistration.cowin.gov.in/"))
                cowinIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(cowinIntent)
            }
        }
    }
}