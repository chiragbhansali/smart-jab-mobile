import "package:flutter/material.dart";
import 'package:vaccine_slot_notifier/DatabaseProvider.dart';
import 'package:vaccine_slot_notifier/models/alarm.dart';

class AddAlarmBottomSheet extends StatefulWidget {
  final Alarm alarmData;
  AddAlarmBottomSheet(this.alarmData);
  @override
  _AddAlarmBottomSheetState createState() => _AddAlarmBottomSheetState();
}

class _AddAlarmBottomSheetState extends State<AddAlarmBottomSheet> {
  Alarm alarmData;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool eighteenPlus;
  bool fortyfivePlus;
  bool covishield;
  bool covaxin;
  bool dose1;
  bool dose2;

  String minAvailable;

  bool isError = false;
  bool isLoading = false;

  bool toBool(String v) {
    if (v.toLowerCase() == "true") {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    alarmData = widget.alarmData;
    eighteenPlus = toBool(widget.alarmData.eighteenPlus);
    fortyfivePlus = toBool(widget.alarmData.fortyfivePlus);
    covishield = toBool(widget.alarmData.covishield);
    covaxin = toBool(widget.alarmData.covaxin);
    dose1 = toBool(widget.alarmData.dose1);
    dose2 = toBool(widget.alarmData.dose2);
    minAvailable = widget.alarmData.minAvailable.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 20,
            ),
            width: MediaQuery.of(context).size.width,
            child: Text(
              "Set alarm for ${alarmData.pincode != null ? alarmData.pincode : alarmData.districtName}",
              style: TextStyle(
                  color: Color(0xff1F2933),
                  fontWeight: FontWeight.w600,
                  fontSize: 19),
            ),
          ),
          Container(
            //height: 50,
            margin: EdgeInsets.only(
              top: 20,
            ),
            width: MediaQuery.of(context).size.width,
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: FilterChip(
                    label: Text("Dose 1",
                        style: TextStyle(
                          color: !dose1 ? Color(0xff0A6CFF) : Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    onSelected: (i) {
                      setState(() {
                        dose1 = i;
                      });
                    },
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    disabledColor: Color(0xffE3EFFF),
                    backgroundColor: Color(0xffE3EFFF),
                    selectedColor: Color(0xff0A6CFF),
                    selected: dose1,
                    checkmarkColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: FilterChip(
                    label: Text("Dose 2",
                        style: TextStyle(
                          color: !dose2 ? Color(0xff0A6CFF) : Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    onSelected: (i) {
                      setState(() {
                        dose2 = i;
                      });
                    },
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    disabledColor: Color(0xffE3EFFF),
                    backgroundColor: Color(0xffE3EFFF),
                    selectedColor: Color(0xff0A6CFF),
                    selected: dose2,
                    checkmarkColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: FilterChip(
                    label: Text("18+",
                        style: TextStyle(
                          color: !eighteenPlus
                              ? Color(0xff0A6CFF)
                              : Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    onSelected: (i) {
                      setState(() {
                        eighteenPlus = i;
                      });
                    },
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    disabledColor: Color(0xffE3EFFF),
                    backgroundColor: Color(0xffE3EFFF),
                    selectedColor: Color(0xff0A6CFF),
                    selected: eighteenPlus,
                    checkmarkColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FilterChip(
                    label: Text("45+",
                        style: TextStyle(
                          color: !fortyfivePlus
                              ? Color(0xff0A6CFF)
                              : Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    onSelected: (i) {
                      setState(() {
                        fortyfivePlus = i;
                      });
                    },
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    disabledColor: Color(0xffE3EFFF),
                    backgroundColor: Color(0xffE3EFFF),
                    selectedColor: Color(0xff0A6CFF),
                    selected: fortyfivePlus,
                    checkmarkColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FilterChip(
                    label: Text("Covaxin",
                        style: TextStyle(
                          color:
                              !covaxin ? Color(0xff0A6CFF) : Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    onSelected: (i) {
                      setState(() {
                        covaxin = i;
                      });
                    },
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    disabledColor: Color(0xffE3EFFF),
                    backgroundColor: Color(0xffE3EFFF),
                    selectedColor: Color(0xff0A6CFF),
                    selected: covaxin,
                    checkmarkColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FilterChip(
                    label: Text("Covishield",
                        style: TextStyle(
                          color: !covishield
                              ? Color(0xff0A6CFF)
                              : Color(0xffffffff),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        )),
                    onSelected: (i) {
                      setState(() {
                        covishield = i;
                      });
                    },
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    disabledColor: Color(0xffE3EFFF),
                    backgroundColor: Color(0xffE3EFFF),
                    selectedColor: Color(0xff0A6CFF),
                    selected: covishield,
                    checkmarkColor: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width / 6) * 2.5,
                  child: Text(
                    "Notify if more than:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Color(0xff3E4C59)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 4, right: 4),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: TextFormField(
                            textAlign: TextAlign.center,
                            initialValue: minAvailable.toString(),
                            onChanged: (value) {
                              minAvailable = value;
                            },
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff323F4B),
                                fontWeight: FontWeight.w500),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 16),
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 20),
                              //labelText: "Enter your PIN Code",
                              fillColor: Color(0xff212121).withOpacity(0.08),
                              filled: true,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text("slots available",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Color(0xff3E4C59))),
                )
              ],
            ),
          ),
          isError
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 5),
                  child: Text("Please enter a valid Number greater than 0",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500)))
              : Container(),
          GestureDetector(
            onTap: !isLoading
                ? () async {
                    if (minAvailable.isEmpty || minAvailable == "0") {
                      setState(() {
                        isError = true;
                      });
                    } else {
                      setState(() {
                        isError = false;
                      });
                      Alarm finalAlarm = Alarm(
                          pincode: alarmData.pincode,
                          districtId: alarmData.districtId,
                          districtName: alarmData.districtName,
                          covaxin: covaxin.toString(),
                          covishield: covishield.toString(),
                          eighteenPlus: eighteenPlus.toString(),
                          fortyfivePlus: fortyfivePlus.toString(),
                          dose1: dose1.toString(),
                          dose2: dose2.toString(),
                          isOn: "true",
                          minAvailable: double.parse(minAvailable).round());
                      setState(() {
                        isLoading = true;
                      });
                      var res =
                          await DatabaseProvider.db.createAlarm(finalAlarm);
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xff323232),
                        content: Container(
                          height: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Alarm set for ${alarmData.pincode != null ? alarmData.pincode : alarmData.districtName}",
                                  style: TextStyle(
                                      color: Color(0xffE4E7EB),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17)),
                            ],
                          ),
                        ),
                      ));
                      Navigator.pop(context, true);
                    }
                  }
                : () {},
            child: Container(
              width: MediaQuery.of(context).size.width - 54,
              margin: EdgeInsets.only(top: 30),
              height: 60,
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text("Set An Alarm",
                        style: TextStyle(
                          fontSize: 16.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xff0A6CFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
