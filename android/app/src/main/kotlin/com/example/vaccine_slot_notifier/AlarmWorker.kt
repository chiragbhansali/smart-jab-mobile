package com.example.vaccine_slot_notifier

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.Worker
import androidx.work.WorkerParameters
import okhttp3.ConnectionSpec
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

data class Alarm(
        val id: Int,
        val pincode: String?,
        val districtId: String?,
        val districtName: String?,
        val isOn: Boolean,
        val eighteenPlus: Boolean,
        val fortyfivePlus: Boolean,
        val covaxin: Boolean,
        val covishield: Boolean,
        val dose1: Boolean,
        val dose2: Boolean,
        val minAvailable: Int
)

class AlarmWorker(appContext: Context, workerParams: WorkerParameters) : CoroutineWorker(appContext, workerParams) {
    override suspend fun doWork(): Result {

        var alarmsList: Array<Alarm> = arrayOf();
        var triggerAlarm: Boolean = false

        val db: SQLiteDatabase = SQLiteDatabase.openOrCreateDatabase(applicationContext.getDatabasePath("alarms.db").absolutePath, null)
        db.execSQL("""CREATE TABLE IF NOT EXISTS Alarm(
                id integer primary key AUTOINCREMENT,
                pincode TEXT,
                districtId TEXT,
                districtName TEXT,
                isOn TEXT,
                eighteenPlus TEXT,
                fortyfivePlus TEXT,
                covaxin TEXT,
                covishield TEXT,
                dose1 TEXT,
                dose2 TEXT,
                minAvailable INTEGER
                )""")
        val cursor = db.rawQuery("select * from Alarm", null)

        if (cursor.moveToFirst()) {
            while (!cursor.isAfterLast) {
                val toAddAlarm: Alarm = Alarm(
                        cursor.getInt(0),
                        cursor.getString(1),
                        cursor.getString(2),
                        cursor.getString(3),
                        toBool(cursor.getString(4)),
                        toBool(cursor.getString(5)),
                        toBool(cursor.getString(6)),
                        toBool(cursor.getString(7)),
                        toBool(cursor.getString(8)),
                        toBool(cursor.getString(9)),
                        toBool(cursor.getString(10)),
                        cursor.getInt(11)
                )
                alarmsList = append(alarmsList, toAddAlarm)
                cursor.moveToNext()
            }
        }

        cursor.close()
        db.close()

        for (alarm in alarmsList) {

            if(!alarm.isOn){
                continue
            }

            val formatter = SimpleDateFormat("dd-MM-yyy", Locale.getDefault())
            val date = formatter.format(getCurrentDateTime())

            var slotsIn = 0

            val url = if (alarm.pincode != null) {
                "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=${alarm.pincode}&date=$date"
            } else {
                "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=${alarm.districtId}&date=$date"
            }

            val httpClient = OkHttpClient()
            val request = Request.Builder()
                    .header("Accept-Language", "en_US")
                    .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36 Edg/90.0.818.51")
                    .url(url)
                    .build()
            val response: Response = httpClient.newCall(request).execute()
            val json = JSONObject(response.body()!!.string())

            if (json.isNull("centers")) {
                continue
            }

            val centers = json.getJSONArray("centers")

            val slots = JSONObject()

            if (centers.length() == 0) {
                continue
            }

            for (i in 0 until centers.length()) {
                val center = centers.getJSONObject(i)
                val sessions = center.getJSONArray("sessions")

                var areSlots = false

                for (i2 in 0 until sessions.length()) {
                    val session = sessions.getJSONObject(i2)

                    val eighteenPlus = alarm.eighteenPlus
                    val fortyfivePlus = alarm.fortyfivePlus
                    val covaxin = alarm.covaxin
                    val covishield = alarm.covishield
                    val dose1 = alarm.dose1
                    val dose2 = alarm.dose2

                    if (eighteenPlus && !fortyfivePlus) {
                        if (session.getInt("min_age_limit") == 45) {
                            continue
                        }
                    }

                    if (fortyfivePlus && !eighteenPlus) {
                        if (session.getInt("min_age_limit") == 18) {
                            continue
                        }
                    }

                    if (covaxin && !covishield) {
                        if (session.getString("vaccine") == "COVISHIELD") {
                            continue
                        }
                    }

                    if (covishield && !covaxin) {
                        if (session.getString("vaccine") == "COVAXIN") {
                            continue
                        }
                    }

                    val skipDoseFilter = session.getInt("available_capacity_dose1") == 0 &&
                            session.getInt("available_capacity_dose2") == 0 &&
                            session.getInt("available_capacity") > 0

                    if(dose1 && !dose2 && !skipDoseFilter){
                        if (slots.isNull(session.getString("date"))) {
                            slots.put(session.getString("date"), session.getInt("available_capacity_dose1"))
                        } else {
                            slots.put(session.getString("date"), slots.getInt(session.getString("date")) + session.getInt("available_capacity_dose1"))
                        }
                        continue
                    }

                    if(dose2 && !dose1 && !skipDoseFilter){
                        if (slots.isNull(session.getString("date"))) {
                            slots.put(session.getString("date"), session.getInt("available_capacity_dose2"))
                        } else {
                            slots.put(session.getString("date"), slots.getInt(session.getString("date")) + session.getInt("available_capacity_dose2"))
                        }
                        continue
                    }

                    if (slots.isNull(session.getString("date"))) {
                        slots.put(session.getString("date"), session.getInt("available_capacity"))
                    } else {
                        slots.put(session.getString("date"), slots.getInt(session.getString("date")) + session.getInt("available_capacity"))
                    }

                    if(session.getInt("available_capacity") > 0){
                        areSlots = true
                    }
                }

                if(areSlots){
                    slotsIn += 1
                }
            }

            var isNoSlots: Boolean = true
            var slotsOpen = 0

            slots.keys().forEach {
                if(slots.getInt(it) > alarm.minAvailable){
                    isNoSlots = false
                    slotsOpen += slots.getInt(it)
                }
            }

            Log.d("AlarmWorker", isNoSlots.toString())

            if(!isNoSlots){
                triggerAlarm = true
                val sharedPrefs = applicationContext.getSharedPreferences(applicationContext.getString(R.string.shared_prefs_key), Context.MODE_PRIVATE)
                with(sharedPrefs.edit()){
                    val place = alarm.pincode ?: alarm.districtName
                    putString("place", place)
                    putInt("slotsIn", slotsIn)
                    putInt("slotsOpen", slotsOpen)
                    commit()
                }
                break
            }
        }

        if(triggerAlarm){
            triggerAlarm()
        }

        return Result.success()
    }

    private fun toBool(v: String): Boolean {
        return v == "true"
    }

    private fun append(arr: Array<Alarm>, element: Alarm): Array<Alarm> {
        val list: MutableList<Alarm> = arr.toMutableList()
        list.add(element)
        return list.toTypedArray()
    }

    private fun triggerAlarm() {
        val am: AlarmManager = applicationContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val i: Intent = Intent(applicationContext, AlarmReceiver::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getBroadcast(applicationContext, 0, i, 0)
        am.set(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), pendingIntent)
    }

    fun getCurrentDateTime(): Date {
        return Calendar.getInstance().time
    }

}