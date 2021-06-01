package com.example.vaccine_slot_notifier

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.media.RingtoneManager
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.work.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit


class MainActivity : FlutterActivity() {

    private var ALARM_CHECK_WORKER = "ALARM_CHECK_WORKER"
    private val CHANNEL = "com.arnav.smartjab/flutter"
    private val RINGTONE = 1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMaps" -> {
                    val url = Uri.parse("geo:${call.argument<Int>("lat")},${call.argument<Int>("long")}?q=${call.argument<String>("address")}")
                    val mapIntent = Intent(Intent.ACTION_VIEW, url)
                    startActivity(mapIntent)
                    result.success("")
                }
                // Ringtone Picker Method
                "chooseRingtone" -> {
                    // Choose Ringtone Picker intent
                    val chooseIntent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER)
                    val sharedPrefs = applicationContext.getSharedPreferences(
                        applicationContext.getString(R.string.shared_prefs_key),
                        Context.MODE_PRIVATE
                    )
                    with(sharedPrefs.edit()) {
                        call.argument<Int>("alarmId")?.let { putInt("alarmId", it) }
                        commit()
                    }
                    startActivityForResult(chooseIntent, RINGTONE)
                    result.success("")
                }
                "getDefaultRingtoneName" -> {
                    val defaultRingtoneUri: Uri = RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_ALARM)
                    val ringtone = RingtoneManager.getRingtone(this, defaultRingtoneUri)
                    val ringtoneName = ringtone.getTitle(this)
                    result.success(ringtoneName)
                }
                "openCowin" -> {
                    val url = Uri.parse("https://selfregistration.cowin.gov.in/")
                    val cowinIntent = Intent(Intent.ACTION_VIEW, url)
                    startActivity(cowinIntent)
                    result.success("")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val fromAlarm = intent.getStringExtra("FROM_ALARM")

        if (fromAlarm != "TRUE") {

            val wm: WorkManager = WorkManager.getInstance(applicationContext)
            wm.cancelAllWork()

            val constraints: Constraints = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()

            val periodicAlarmCheckWorker1: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                    .addTag(ALARM_CHECK_WORKER + "_1").setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
//                    .setInitialDelay(0, TimeUnit.MINUTES)
                    .build()
            val periodicAlarmCheckWorker2: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                    .addTag(ALARM_CHECK_WORKER + "_2").setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
                    .setInitialDelay(5, TimeUnit.MINUTES)
                    .build()
            val periodicAlarmCheckWorker3: PeriodicWorkRequest = PeriodicWorkRequest.Builder(AlarmWorker::class.java, 15, TimeUnit.MINUTES)
                    .addTag(ALARM_CHECK_WORKER + "_3").setConstraints(constraints)
                    .setBackoffCriteria(BackoffPolicy.LINEAR, PeriodicWorkRequest.MIN_BACKOFF_MILLIS, TimeUnit.MILLISECONDS)
                    .setInitialDelay(10, TimeUnit.MINUTES)
                    .build()

            wm.enqueueUniquePeriodicWork("ALARM_CHECKER_1", ExistingPeriodicWorkPolicy.REPLACE, periodicAlarmCheckWorker1)
            wm.enqueueUniquePeriodicWork("ALARM_CHECKER_2", ExistingPeriodicWorkPolicy.REPLACE, periodicAlarmCheckWorker2)
            wm.enqueueUniquePeriodicWork("ALARM_CHECKER_3", ExistingPeriodicWorkPolicy.REPLACE, periodicAlarmCheckWorker3)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Get Uri from picker
        if (requestCode == RINGTONE) {
            // Returns Uri
            val ringtoneUri = data?.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
            val ringtone = RingtoneManager.getRingtone(this, ringtoneUri)
            val ringtoneName = ringtone.getTitle(this)

            val db: SQLiteDatabase = SQLiteDatabase.openOrCreateDatabase(
                applicationContext.getDatabasePath("alarms.db").absolutePath,
                null
            );
            val cv: ContentValues = ContentValues()
            cv.put("ringtoneUri", ringtoneUri.toString())
            cv.put("ringtoneName", ringtoneName)

            val sharedPrefs = getSharedPreferences(getString(R.string.shared_prefs_key), Context.MODE_PRIVATE)


            db.update("Alarm", cv, "id = ?", arrayOf<String>(sharedPrefs.getInt("alarmId", 1).toString()))
            // TODO: Update DB 
//            Log.d("ringtone path", ringtone.toString())
            with(sharedPrefs.edit()) {
                remove("alarmId")
                commit()
            }
        }
    }
}
