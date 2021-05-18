package com.example.vaccine_slot_notifier

import android.app.KeyguardManager
import android.content.Context
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.WindowManager
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity


class AlarmActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_alarm)

        if (mp?.isPlaying != true) {
            mp?.reset()
            mp = null
            val defaultRingtoneUri: Uri = RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_ALARM)
            mp = MediaPlayer.create(this, defaultRingtoneUri)
            mp?.start()
        }

        val v: Vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        v.cancel()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            v.vibrate(VibrationEffect.createWaveform(longArrayOf(1000, 1000), 0))
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }

        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)

        val keyGuardManager: KeyguardManager = (getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyGuardManager.requestDismissKeyguard(this, null)
        }

    }
}