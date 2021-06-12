import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

class BatteryDialog extends StatefulWidget {
  @override
  _BatteryDialogState createState() => _BatteryDialogState();
}

class _BatteryDialogState extends State<BatteryDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Warning!",
        style: TextStyle(color: Color(0xff323F4B), fontWeight: FontWeight.w500),
      ),
      content: Container(
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              text:
                  "The Alarm may not work properly on your device! Please follow the steps from ",
              style: TextStyle(
                  color: Color(0xff3E4C59),
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w500)),
          TextSpan(
              text: "here ",
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  const platform = const MethodChannel(
                    'com.arnav.smartjab/flutter',
                  );
                  var result2 =
                      await platform.invokeMethod("openDontKillMyApp");
                },
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w500)),
          TextSpan(
              text: "to ensure that it works properly",
              style: TextStyle(
                  color: Color(0xff3E4C59),
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w500))
        ])),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ))
      ],
    );
  }
}
