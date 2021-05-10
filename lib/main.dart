import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
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

void printHello() async {
  Workmanager().executeTask((taskName, inputData) async {
    await http.get(Uri.parse("http://192.168.133.1:5000"));
    print("Hello");
    if (await Vibration.hasCustomVibrationsSupport()) {
      Vibration.vibrate(duration: 1000);
    } else {
      Vibration.vibrate();
      await Future.delayed(Duration(milliseconds: 500));
      Vibration.vibrate();
    }
    //runApp(AlarmManagerExampleApp());

    return Future.value(true);
  });
}

Future<void> main() async {
  // TODO(bkonyi): uncomment
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(printHello, isInDebugMode: true);
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
  runApp(AlarmManagerExampleApp());
}

/// Example app for Espresso plugin.
class AlarmManagerExampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(),
    );
  }
}

class _AlarmHomePage extends StatefulWidget {
  _AlarmHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<_AlarmHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // AndroidAlarmManager.initialize();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => {await _incrementCounter()});
  }

  Future<void> _incrementCounter() async {
    print('Increment counter!');

    // Ensure we've loaded the updated count from the background isolate.
    await prefs.reload();

    setState(() {
      _counter++;
    });
  }

  // The background
  static SendPort uiSendPort;

  // The callback for our alarm
  static Future<void> callback() async {
    print('Alarm fired!');

    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(countKey);
    await prefs.setInt(countKey, currentCount + 1);

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline4;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Alarm fired $_counter times',
              style: textStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Total alarms fired: ',
                  style: textStyle,
                ),
                Text(
                  prefs.getInt(countKey).toString(),
                  key: ValueKey('BackgroundCountText'),
                  style: textStyle,
                ),
              ],
            ),
            ElevatedButton(
              key: ValueKey('RegisterOneShotAlarm'),
              onPressed: () async {
                print("Click");
              },
              child: Text(
                'Schedule OneShot Alarm',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
