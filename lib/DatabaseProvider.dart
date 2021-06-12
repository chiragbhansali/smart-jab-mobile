import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vaccine_slot_notifier/models/alarm.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    return await openDatabase(join(await getDatabasesPath(), "alarms.db"),
        version: 4, onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE IF NOT EXISTS Alarm("
              "id integer primary key AUTOINCREMENT,"
              "pincode TEXT,"
              "districtId TEXT,"
              "districtName TEXT,"
              "isOn TEXT,"
              "eighteenPlus TEXT,"
              "fortyfivePlus TEXT,"
              "covaxin TEXT,"
              "covishield TEXT,"
              "dose1 TEXT,"
              "dose2 TEXT,"
              "minAvailable INTEGER,"
              "radius INTEGER,"
              "ringtoneUri TEXT,"
              "ringtoneName TEXT,"
              "vibrate TEXT,"
              "paid TEXT,"
              "free TEXT"
              ")");
        }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (newVersion == 2) {
            await db.execute("ALTER TABLE Alarm ADD radius INTEGER");
          } else if (newVersion == 3) {
            if(oldVersion != 2) {
              await db.execute("ALTER TABLE Alarm ADD radius INTEGER");
            }
            await db.execute(
                """ALTER TABLE Alarm ADD ringtoneUri TEXT DEFAULT 'default'""");
            await db.execute(
                """ALTER TABLE Alarm ADD ringtoneName TEXT DEFAULT 'default'""");
            await db
                .execute("""ALTER TABLE Alarm ADD vibrate TEXT DEFAULT 'true'""");
          } else if (newVersion == 4) {
            if (oldVersion != 3){
              if(oldVersion != 2) {
                await db.execute("ALTER TABLE Alarm ADD radius INTEGER");
              }
              await db.execute(
                  """ALTER TABLE Alarm ADD ringtoneUri TEXT DEFAULT 'default'""");
              await db.execute(
                  """ALTER TABLE Alarm ADD ringtoneName TEXT DEFAULT 'default'""");
              await db
                  .execute("""ALTER TABLE Alarm ADD vibrate TEXT DEFAULT 'true'""");
            }
            await db.execute("""ALTER TABLE Alarm ADD paid TEXT DEFAULT 'false'""");
            await db.execute("""ALTER TABLE Alarm ADD free TEXT DEFAULT 'false'""");
          }
        });
  }

  Future<dynamic> createAlarm(Alarm alarm) async {
    final db = await database;
    var raw = await db.insert("Alarm", alarm.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return raw;
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await database;
    var res = await db.query("Alarm");

    List<Alarm> alarmsList = [];
    res.forEach((element) {
      print(element);
      alarmsList.add(Alarm.fromMap(element));
    });
    return alarmsList;
  }

  Future<bool> editAlarmOnState(int id, bool state) async {
    final db = await database;
    var res = await db.update("Alarm", {"isOn": state.toString()},
        where: "id = ?", whereArgs: [id]);

    return true;
  }

  Future<bool> editAlarmVibrateState(int id, bool state) async {
    final db = await database;
    var res = await db.update("Alarm", {"vibrate": state.toString()},
        where: "id = ?", whereArgs: [id]);

    return true;
  }

  Future<bool> deleteAlarm(int id) async {
    final db = await database;
    var res = await db.delete("Alarm", where: "id = ?", whereArgs: [id]);

    return true;
  }

  Future<bool> editAlarm(int id, Map<dynamic, dynamic> toUpdate) async {
    final db = await database;
    var res =
    await db.update("Alarm", toUpdate, where: "id = ?", whereArgs: [id]);
    return true;
  }
}
