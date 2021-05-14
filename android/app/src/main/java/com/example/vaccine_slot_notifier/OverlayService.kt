package com.example.vaccine_slot_notifier

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.WindowManager
import android.widget.TextView
import androidx.core.content.ContextCompat

class OverlayService : Service() {
    private lateinit var wm: WindowManager
    var textview: TextView? = null
    lateinit var params:WindowManager.LayoutParams

    override fun onCreate() {
        super.onCreate()
        wm = getSystemService(WINDOW_SERVICE) as WindowManager

        textview = TextView(this)
        textview!!.text = "Alarm test"
        textview!!.textSize = 32f
        textview!!.setTextColor(ContextCompat.getColor(this, android.R.color.white))
        params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT
        )
        params.width = WindowManager.LayoutParams.WRAP_CONTENT
        params.height = WindowManager.LayoutParams.WRAP_CONTENT
        params.gravity = Gravity.END or Gravity.TOP
        wm.addView(textview, params)

    }

    override fun onBind(intent: Intent): IBinder {
        TODO("Return the communication channel to the service.")
    }

    override fun onDestroy() {
        super.onDestroy()
        if (textview != null) {
            wm.removeView(textview)
            textview = null
        }
    }


}