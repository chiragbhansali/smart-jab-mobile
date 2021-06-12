import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';

List months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

class HospitalScreen extends StatefulWidget {
  final String centerId;
  final String name;
  final String address;
  final dynamic age;
  final String vaccine;
  final String selectedDate;
  final dynamic lat;
  final dynamic long;
  const HospitalScreen(
      {this.centerId,
      this.name,
      this.address,
      this.age,
      this.vaccine,
      this.selectedDate,
      this.lat,
      this.long});

  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  bool eighteenPlus = false;
  bool fortyfivePlus = false;
  bool covishield = false;
  bool covaxin = false;
  bool dose1 = false;
  bool dose2 = false;
  Map<dynamic, dynamic> slotsPerDay = {};
  Map<dynamic, dynamic> slotsHistoryPerDay = {};
  List slotsArray = [];
  List slotsHistoryArray = [];
  String addressFinal;
  bool loading = true;
  bool historyLoading = true;
  bool noSlots = false;
  bool noHistory = false;

  var apiData;
  var apiHistoryData;

  String capitalizeFirstofEach(String address) => address
      .split(" ")
      .map((str) => "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}")
      .join(" ");

  void getSlotHistory() async {
    const platform = const MethodChannel(
      'com.arnav.smartjab/flutter',
    );
    var data = await http
        .get(Uri.parse("https://smartjab.in/api/history/${widget.centerId}/"));
    var body = jsonDecode(data.body);
    apiHistoryData = body;
    Map<dynamic, dynamic> slots = {};
    var result = body['history'];

    if (result == null) {
      setState(() {
        historyLoading = false;
        noHistory = true;
      });
      return;
    }

    result.forEach((key, value) {
      if (value['opened']) {
        slots[key] = value['time'];
      } else {
        slots[key] = "Closed";
      }
    });

    /* slots.values.toList().forEach((slots) {
      if (slots > 0) {
        isNoSlots = false;
      }
    }); */

    /* if (isNoSlots) {
      setState(() {
        noSlots = true;
        loading = false;
      });
      return;
    } */

    List datesArray = [];
    slots.keys.toList().forEach((date) {
      datesArray.add({"date": date, "slots": slots[date]});
    });

    setState(() {
      slotsHistoryPerDay = slots;
      historyLoading = false;
      slotsHistoryArray = datesArray;
    });
  }

  void getCenterData() async {
    var data = await http.get(Uri.parse(
        "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByCenter?center_id=${widget.centerId}&date=${widget.selectedDate}"));
    var body = jsonDecode(data.body);
    apiData = body;

    if (body['centers'] == null) {
      setState(() {
        noSlots = true;
        loading = false;
      });
      return;
    }

    if (body['centers'].length < 1) {
      setState(() {
        noSlots = true;
        loading = false;
      });
      return;
    }

    Map<dynamic, dynamic> slots = {};

    /*  body['centers'].forEach((center) {
      var sessions = center['sessions'];
      sessions.forEach((session) {
        if (slots[session['date']] != null) {
          slots[session['date']] =
              slots[session['date']] + session['available_capacity'];
        } else {
          slots[session['date']] = session['available_capacity'];
        }
      });
    }); */
    var centers = body['centers'];
    centers['sessions'].forEach((session) {
      if (slots[session['date']] != null) {
        slots[session['date']] =
            slots[session['date']] + session['available_capacity'];
      } else {
        slots[session['date']] = session['available_capacity'];
      }
    });

    bool isNoSlots = true;

    slots.values.toList().forEach((slots) {
      if (slots > 0) {
        isNoSlots = false;
      }
    });

    if (isNoSlots) {
      setState(() {
        noSlots = true;
        loading = false;
      });
      return;
    }
    List datesArray = [];
    slots.keys.toList().forEach((date) {
      datesArray.add({"date": date, "slots": slots[date]});
    });

    print(datesArray.toString());
    datesArray.sort((a, b) {
      DateTime aDate = DateTime.parse(
          "${a['date'].substring(6)}-${a['date'].substring(3, 5)}-${a['date'].substring(0, 2)} 14:04:24.367573");
      DateTime bDate = DateTime.parse(
          "${b['date'].substring(6)}-${b['date'].substring(3, 5)}-${b['date'].substring(0, 2)} 14:04:24.367573");
      if (aDate.isBefore(bDate)) {
        return 0;
      } else {
        return 1;
      }
    });
    print(datesArray.toString());

    setState(() {
      noSlots = false;
      slotsPerDay = slots;
      loading = false;
      slotsArray = datesArray;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCenterData();
    getSlotHistory();
    addressFinal = capitalizeFirstofEach(widget.address.toLowerCase());
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
        title: Text(widget.name,
            style: TextStyle(
                color: Color(0xff323F4B),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          const platform = const MethodChannel(
            'com.arnav.smartjab/flutter',
          );
          try {
            var result = await platform.invokeMethod("openMaps", {
              "address": "${widget.name}, ${widget.address}}",
              "lat": widget.lat,
              "long": widget.long
            });
          } catch (e) {}
        },
        backgroundColor: Color(0xff0A6CFF),
        child: Center(
          child: Icon(
            Icons.directions_outlined,
            color: Colors.white,
          ),
        ),
      ),
      body: (loading | historyLoading)
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(left: 27, right: 27),
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Address",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Color(0xff323F4B),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text("$addressFinal",
                          style: TextStyle(
                              height: 1.5,
                              color: Color(0xff3E4C59),
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Wrap(
                            spacing: 4,
                            children: widget.age
                                .map<Widget>(
                                  (a) => Container(
                                    child: Text("$a+",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff3E4C59))),
                                  ),
                                )
                                .toList(),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Icon(
                            Icons.medication_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "${widget.vaccine}",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff3E4C59)),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Slot Opening History",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff323F4B)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          noHistory
                              ? NoData()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return SlotsHistoryCard(
                                      slotsHistoryArray[index]['date'],
                                      (slotsHistoryArray[index]['slots']),
                                      slotsMap: slotsHistoryPerDay,
                                      apiData: apiHistoryData,
                                      filters: {
                                        "eighteenPlus": eighteenPlus,
                                        "fortyfivePlus": fortyfivePlus,
                                        "covaxin": covaxin,
                                        "covishield": covishield,
                                        "dose1": dose1,
                                        "dose2": dose2
                                      },
                                    );
                                  },
                                  itemCount: slotsHistoryArray.length),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Slot Availability",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff323F4B)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          noHistory
                              ? NoSlots(false)
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return SlotsPerDayCard(
                                      slotsArray[index]['date'],
                                      (slotsArray[index]['slots']).round(),
                                      slotsMap: slotsPerDay,
                                      apiData: apiData,
                                      filters: {
                                        "eighteenPlus": eighteenPlus,
                                        "fortyfivePlus": fortyfivePlus,
                                        "covaxin": covaxin,
                                        "covishield": covishield,
                                        "dose1": dose1,
                                        "dose2": dose2
                                      },
                                    );
                                  },
                                  itemCount: slotsArray.length),
                        ],
                      ),
                      SizedBox(
                        height: 56,
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class SlotsPerDayCard extends StatefulWidget {
  final String date;
  final int slots;
  final Map<dynamic, dynamic> slotsMap;
  final Map<dynamic, dynamic> apiData;
  final Map<String, bool> filters;
  final String place;
  SlotsPerDayCard(this.date, this.slots,
      {this.slotsMap, this.apiData, this.place, this.filters});

  @override
  _SlotsPerDayCardState createState() => _SlotsPerDayCardState();
}

class _SlotsPerDayCardState extends State<SlotsPerDayCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 65,
        width: MediaQuery.of(context).size.width - 54,
        margin: EdgeInsets.symmetric(vertical: 0),
        child: Row(
          children: [
            Container(
                child: Text(
              DateFormat("MMM dd, E").format(DateTime.parse(
                  "${widget.date.substring(6)}-${widget.date.substring(3, 5)}-${widget.date.substring(0, 2)} 14:04:24.367573")),
              style: TextStyle(
                  color:
                      widget.slots == 0 ? Color(0xff7B8794) : Color(0xff3E4C59),
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
            )),
            Expanded(child: Container()),
            Container(
              padding: EdgeInsets.only(right: 12),
              child: Text(
                  "${widget.slots} ${widget.slots == 1 ? "Slot" : "Slots"}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.slots == 0
                          ? Color(0xff7B8794)
                          : widget.slots > 10
                              ? Color(0xff399709)
                              : Color(0xffDE911D))),
            ),
            /* Icon(Icons.chevron_right,
                size: 28,
                color: widget.slots == 0
                    ? Color(0xff7B8794)
                    : Color(0xff616E7C)), */
          ],
        ));
  }
}

class SlotsHistoryCard extends StatefulWidget {
  final String date;
  final String slots;
  final Map<dynamic, dynamic> slotsMap;
  final Map<dynamic, dynamic> apiData;
  final Map<String, bool> filters;
  final String place;
  SlotsHistoryCard(this.date, this.slots,
      {this.slotsMap, this.apiData, this.place, this.filters});

  @override
  _SlotsHistoryCardState createState() => _SlotsHistoryCardState();
}

class _SlotsHistoryCardState extends State<SlotsHistoryCard> {
  String date;
  @override
  void initState() {
    super.initState();
    date = widget.date.replaceAll("-", " ");
    print("hi" +
        "2021-${(months.indexOf(date.substring(date.length - 3)) + 1).toString().length == 1 ? "0" + (months.indexOf(date.substring(date.length - 3)) + 1).toString() : (months.indexOf(date.substring(date.length - 3)) + 1).toString()}-${(date.substring(0, date.length - 3))} 14:04:24.367573");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 65,
        width: MediaQuery.of(context).size.width - 54,
        child: Row(
          children: [
            Container(
                margin: EdgeInsets.symmetric(vertical: 0),
                child: Text(
                  // "2021-${}-${int.parse(date.substring(0, date.length - 3))} 14:04:24.367573"
                  "${DateFormat("MMM dd, E").format(DateTime.parse('2021-${(months.indexOf(date.substring(date.length - 3)) + 1).toString().length == 1 ? "0" + (months.indexOf(date.substring(date.length - 3)) + 1).toString() : (months.indexOf(date.substring(date.length - 3)) + 1).toString()}-${date.substring(0, date.length - 4)} 00:00:00.000'))}",
                  style: TextStyle(
                      color: widget.slots == "Closed"
                          ? Color(0xff7B8794)
                          : Color(0xff3E4C59),
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                )),
            Expanded(child: Container()),
            Container(
              padding: EdgeInsets.only(right: 12),
              child: Text("${widget.slots}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.slots == "Closed"
                          ? Color(0xff7B8794)
                          : Color(0xff399709))),
            ),
            /* Icon(Icons.chevron_right,
                size: 28,
                color: widget.slots == 0
                    ? Color(0xff7B8794)
                    : Color(0xff616E7C)), */
          ],
        ));
    /* DateFormat("MMMM dd, EEEE").format(DateTime.parse(
                    "${widget.date.substring(6)}-${widget.date.substring(3, 5)}-${widget.date.substring(0, 2)} 14:04:24.367573") */
  }
}

class NoData extends StatefulWidget {
  const NoData({Key key}) : super(key: key);

  @override
  _NoDataState createState() => _NoDataState();
}

class _NoDataState extends State<NoData> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: MediaQuery.of(context).size.width - 54,
      decoration: BoxDecoration(
          color: Color(0xffFFF3C4), borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 20),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text("Slots Opening History Not available for 45+ slots"),
      )),
    );
  }
}

class NoSlots extends StatefulWidget {
  final bool isHistory;
  NoSlots(this.isHistory);

  @override
  NoSlotsState createState() => NoSlotsState();
}

class NoSlotsState extends State<NoSlots> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        SizedBox(
          height: 20,
        ),
        Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.width / 4,
            child: Image.asset(
              "assets/empty_box_lg.png",
              fit: BoxFit.contain,
            )),
        Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              widget.isHistory ? "No Data Available" : "No Slots Available",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xff323F4B)),
            )),
      ]),
    );
  }
}
