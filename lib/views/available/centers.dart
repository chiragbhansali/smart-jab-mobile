import "package:flutter/material.dart";
import 'package:intl/intl.dart';

class CentersAvailableSlots extends StatefulWidget {
  final String selectedDate;
  final Map<dynamic, dynamic> dates;
  final String place;
  final Map<dynamic, dynamic> apiData;
  CentersAvailableSlots(
      {this.selectedDate, this.dates, this.place, this.apiData});
  @override
  _CentersAvailableSlotsState createState() => _CentersAvailableSlotsState();
}

class _CentersAvailableSlotsState extends State<CentersAvailableSlots> {
  List<Map<dynamic, dynamic>> datesArray = [];
  int selectedDateIndex = 0;
  String selectedDate;

  List<Map<dynamic, dynamic>> centersList = [];

  void fillCentersList() {
    String date = datesArray[selectedDateIndex]['date'];

    var data = widget.apiData['centers'];
    List<Map<dynamic, dynamic>> tempCentersList = [];

    data.forEach((c) {
      Map center = {};

      center['name'] = c['name'];
      center['address'] = "${c['block_name']}, ${c['pincode']}";
      center['fee'] = c['fee_type'];

      bool sessionNotFound = true;

      for (var session in c['sessions']) {
        if (session['date'] == date) {
          sessionNotFound = false;
          center['vaccine'] = session['vaccine'];
          center['slots'] = session['available_capacity'];
          center['min_age'] = session['min_age_limit'];
        }
      }
      if (sessionNotFound) {
        var session = c['sessions'].isEmpty ? null : c['sessions'][0];
        if (session != null) {
          center['vaccine'] = session['vaccine'];
          center['slots'] = 0;
          center['min_age'] = session['min_age_limit'];
        } else {
          center['vaccine'] = "Not Known";
          center['slots'] = 0;
          center['min_age'] = "18";
        }
      }

      tempCentersList.add(center);
    });
    setState(() {
      centersList = tempCentersList;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    widget.dates.keys.toList().forEach((date) {
      datesArray.add({"date": date, "slots": widget.dates[date]});
    });
    datesArray.sort((a, b) => a['date'].compareTo(b['date']));
    selectedDateIndex = datesArray
        .indexWhere((element) => element['date'] == widget.selectedDate);
    fillCentersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color(0xffF5F7FA),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff323F4B)),
        centerTitle: true,
        title: Text(widget.place,
            style: TextStyle(
                color: Color(0xff323F4B),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    disabledColor: Color(0xff7B8794),
                    icon: Icon(Icons.chevron_left, size: 30),
                    onPressed: selectedDateIndex > 0
                        ? () {
                            if (selectedDateIndex > 0) {
                              setState(() {
                                selectedDate =
                                    datesArray[selectedDateIndex - 1]['date'];
                                selectedDateIndex -= 1;
                              });
                              fillCentersList();
                            }
                          }
                        : null,
                  ),
                  Expanded(child: Container()),
                  Text(
                    DateFormat("MMMM dd, EEEE").format(DateTime.parse(
                        "${selectedDate.substring(6)}-${selectedDate.substring(3, 5)}-${selectedDate.substring(0, 2)} 14:04:24.367573")),
                    style: TextStyle(
                        color: Color(0xff323F4B),
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  Expanded(child: Container()),
                  IconButton(
                      disabledColor: Color(0xff7B8794),
                      icon: Icon(
                        Icons.chevron_right,
                        size: 30,
                      ),
                      onPressed: selectedDateIndex < datesArray.length - 1
                          ? () {
                              if (selectedDateIndex < datesArray.length - 1) {
                                setState(() {
                                  selectedDate =
                                      datesArray[selectedDateIndex + 1]['date'];
                                  selectedDateIndex += 1;
                                });
                                fillCentersList();
                              }
                            }
                          : null)
                ],
              ),
            ),
            Container(
                child: Expanded(
              child: ListView.builder(
                itemCount: centersList.length,
                itemBuilder: (context, index) {
                  return CenterCard(centersList[index]);
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class CenterCard extends StatefulWidget {
  final Map<dynamic, dynamic> center;
  CenterCard(this.center);
  @override
  _CenterCardState createState() => _CenterCardState();
}

class _CenterCardState extends State<CenterCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 170,
        width: MediaQuery.of(context).size.width - 54,
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
        child: Column(
          children: [
            Row(children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 158),
                margin: EdgeInsets.only(top: 24, left: 24),
                //width: MediaQuery.of(context).size.width - 118,
                child: Text(widget.center['name'],
                    //overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xff3E4C59),
                        fontSize: 19,
                        fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Container()),
              Container(
                  margin: EdgeInsets.only(top: 24, right: 24),
                  decoration: BoxDecoration(
                    color: widget.center['slots'] > 10
                        ? Color(0xff5CB70B)
                        : widget.center['slots'] == 0
                            ? Color(0xff7B8794)
                            : Color(0xffF0B429),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 30,
                  width: 60,
                  child: Center(
                    child: Text(widget.center['slots'].toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  )),
            ]),
            Container(
                width: MediaQuery.of(context).size.width - 48,
                padding: EdgeInsets.only(top: 6, left: 24, right: 24),
                child: Text(widget.center['address'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xff616E7C),
                        fontWeight: FontWeight.w500,
                        fontSize: 16))),
            Expanded(child: Container()),
            Container(
              width: MediaQuery.of(context).size.width - 48,
              padding: EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Row(
                children: [
                  Text("${widget.center['min_age']}+",
                      style: TextStyle(
                          color: Color(0xff616E7C),
                          fontWeight: FontWeight.w500,
                          fontSize: 16)),
                  Expanded(child: Container()),
                  Text(
                      "${widget.center['vaccine'][0]}${widget.center['vaccine'].substring(1).toLowerCase()} (${widget.center['fee']})",
                      style: TextStyle(
                          color: Color(0xff616E7C),
                          fontWeight: FontWeight.w500,
                          fontSize: 16))
                ],
              ),
            )
          ],
        ));
  }
}
