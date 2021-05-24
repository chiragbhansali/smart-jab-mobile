import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vaccine_slot_notifier/DatabaseProvider.dart';
import 'package:vaccine_slot_notifier/DatabaseProvider.dart';
import 'package:vaccine_slot_notifier/LocalStorage.dart';
import 'package:vaccine_slot_notifier/jabalarm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseProvider.db.getAlarms();
  await LocalStorage().initIfEmpty();
  runApp(JabAlarmApp());
}

/// Example app for Espresso plugin.
class JabAlarmApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smart Jab',
        home: JabAlarm(),
        theme: ThemeData(
            fontFamily: "Inter",
            primaryColor: Color(0xff0A6CFF),
            accentColor: Color(0xff0A6CFF)));
  }
}
