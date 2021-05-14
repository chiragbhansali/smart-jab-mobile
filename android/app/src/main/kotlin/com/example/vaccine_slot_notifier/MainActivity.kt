package com.example.vaccine_slot_notifier

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() , MethodChannel.MethodCallHandler{

    val TAG = "Main Activity....."
    val CHANNEL = "com.arnav.vaccine_slot_notifier/alarms"
    var keepResult: MethodChannel.Result? = null
    var serviceConnected = false

    private fun connectToService() {
        if (!serviceConnected) {
            val service = Intent(this, OverlayService::class.java)
            startService(service)
            serviceConnected = true
        } else {
            if (keepResult != null) {
                keepResult!!.success(null)
                keepResult = null
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);
        MethodChannel(getFlutterEngine()?.getDartExecutor()?.getBinaryMessenger(), CHANNEL).setMethodCallHandler(::onMethodCall)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (call.method == "connect") {
                connectToService()
                keepResult = result
            } else if (serviceConnected) {
                if (call.method == "start") {
                    val _data: String = "Hi"
                    result.success(_data)
                }
            } else {
                result.error(null, "App not connected to service", null)
            }
        } catch (e: Exception) {
            result.error(null, e.message, null)
        }
    }
}
