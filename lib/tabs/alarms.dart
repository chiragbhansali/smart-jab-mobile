import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:vaccine_slot_notifier/DatabaseProvider.dart';
import 'package:vaccine_slot_notifier/models/alarm.dart';
import 'package:vaccine_slot_notifier/widgets/editAlarmBottomSheet.dart';

const platform = const MethodChannel('com.jabalarm/platform');

class AlarmsTab extends StatefulWidget {
  @override
  _AlarmsTabState createState() => _AlarmsTabState();
}

// add this line wherever platform required
// final int result = await platform.invokeMethod(<NAME>)


class _AlarmsTabState extends State<AlarmsTab> {
  bool isLoading = true;
  List<Alarm> alarms;
  int length;

  Future<dynamic> getAlarms() async {
    print("called");
    setState(() {
      isLoading = true;
      alarms = [];
    });

    var res = await DatabaseProvider.db.getAlarms();

    setState(() {
      alarms = res;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color(0xffF5F7FA),
        elevation: 0,
        centerTitle: true,
        title: Text("Alarms",
            style: TextStyle(
                color: Color(0xff323F4B),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : alarms.length == 0
              ? NoAlarms()
              : Container(
                  margin: EdgeInsets.only(top: 30),
                  child: ListView.builder(
                      itemCount: alarms.length,
                      itemBuilder: (context, index) {
                        return AlarmCard(new ValueKey(alarms[index].id),
                            alarms[index], getAlarms);
                      })),
    );
  }
}

class NoAlarms extends StatefulWidget {
  @override
  _NoAlarmsState createState() => _NoAlarmsState();
}

class _NoAlarmsState extends State<NoAlarms> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Expanded(child: Container()),
        Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3,
            child: Image.asset(
              "assets/no_alarms_lg.png",
              fit: BoxFit.contain,
            )),
        SizedBox(height: 20),
        Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "You haven't created any alarms yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Color(0xff323F4B)),
            )),
        Expanded(child: Container()),
      ]),
    );
  }
}

class AlarmCard extends StatefulWidget {
  final Alarm alarm;
  final Function getAlarms;
  AlarmCard(Key key, this.alarm, this.getAlarms) : super(key: key);
  @override
  _AlarmCardState createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard> {
  Alarm alarm;

  bool toBool(String v) {
    return v == "true";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    alarm = widget.alarm;
    print(widget.alarm.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Wrap(
                children: [EditAlarmBottomSheet(alarm, widget.getAlarms)],
              );
            });

        // if (result == true) {
        //   await widget.getAlarms();
        // }
      },
      child: Container(
        //height: 170,
        width: MediaQuery.of(context).size.width - 54,
        padding: EdgeInsets.only(left: 15, top: 20, bottom: 40, right: 15),
        margin: EdgeInsets.only(left: 22, right: 22, top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Color(0xffF5F7FA),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Color(0xff3E4C59).withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: Offset(0, 2))
            ]),
        child:Column(
          children: [
            Row(
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 158),
                  child: Text(
                    alarm.pincode ?? alarm.districtName,
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff323F4B),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(child: Container()),
                Switch(
                    value: toBool(alarm.isOn),
                    onChanged: (v) async {
                      await DatabaseProvider.db.editAlarmOnState(alarm.id, v);
                      setState(() {
                        alarm.isOn = v.toString();
                      });
                    }),
              ],
            ),
            SizedBox(height: 31, width: MediaQuery.of(context).size.width,),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    const platform = const MethodChannel(
                      'com.arnav.smartjab/flutter',
                    );
                    var result =
                         await platform.invokeMethod("chooseRingtone");
                  },
                    child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 158),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: Color.fromRGBO(62, 76, 89, 1),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text("Default(Oxygen)",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromRGBO(62, 76, 89, 1),
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    )
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}
