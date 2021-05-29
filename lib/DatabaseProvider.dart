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
        version: 2, onCreate: (Database db, int version) async {
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
          "radius INTEGER"
          ")");
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute("ALTER TABLE Alarm ADD radius INTEGER");
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
