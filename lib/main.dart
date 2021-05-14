import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:vaccine_slot_notifier/jabalarm.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
SharedPreferences prefs;

void callback() async {
  Workmanager().executeTask((taskName, inputData) async {
    //await http.get(Uri.parse("http://192.168.133.1:5000"));
    print("Hello");
    const platform = MethodChannel('com.arnav.vaccine_slot_notifier/alarms');
    try {
      await platform.invokeMethod<void>('connect');
      print('Connected to service');
    } on Exception catch (e) {
      print(e.toString());
    }
    // if (await Vibration.hasCustomVibrationsSupport()) {
    //   Vibration.vibrate(duration: 1000);
    // } else {
    //   Vibration.vibrate();
    //   await Future.delayed(Duration(milliseconds: 500));
    //   Vibration.vibrate();
    //
    //runApp(AlarmManagerExampleApp());

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(callback, isInDebugMode: true);
  Workmanager().cancelAll();
  Workmanager().registerPeriodicTask("1", "task");
  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.

  // IsolateNameServer.registerPortWithName(
  //   port.sendPort,
  //   isolateName,
  // );
  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(countKey)) {
    await prefs.setInt(countKey, 0);
  }
  runApp(JabAlarmApp());
}

/// Example app for Espresso plugin.
class JabAlarmApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JabAlarm',
      home: JabAlarm(),
      theme: ThemeData(fontFamily: "Inter", primaryColor: Color(0xff0A6CFF)),
    );
  }
}
