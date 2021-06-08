import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vaccine_slot_notifier/views/available/hospital.dart';

class CentersAvailableSlots extends StatefulWidget {
  final String selectedDate;
  final Map<dynamic, dynamic> dates;
  final String place;
  final Map<dynamic, dynamic> apiData;
  final Map<String, bool> filters;
  CentersAvailableSlots(
      {this.selectedDate, this.dates, this.place, this.apiData, this.filters});
  @override
  _CentersAvailableSlotsState createState() => _CentersAvailableSlotsState();
}

class _CentersAvailableSlotsState extends State<CentersAvailableSlots> {
  List<Map<dynamic, dynamic>> datesArray = [];
  int selectedDateIndex = 0;
  String selectedDate;

  bool eighteenPlus = false;
  bool fortyfivePlus = false;
  bool covishield = false;
  bool covaxin = false;
  bool dose1 = false;
  bool dose2 = false;

  List<Map<dynamic, dynamic>> centersList = [];

  int getSlots(Map<dynamic, dynamic> session) {
    if (eighteenPlus && !fortyfivePlus) {
      if (session['min_age_limit'] == 45) {
        return 0;
      }
    }

    if (fortyfivePlus && !eighteenPlus) {
      if (session['min_age_limit'] == 18) {
        return 0;
      }
    }

    if (covaxin && !covishield) {
      if (session['vaccine'] == 'COVISHIELD') {
        return 0;
      }
    }

    if (covishield && !covaxin) {
      if (session['vaccine'] == "COVAXIN") {
        return 0;
      }
    }

    bool skipDoseFilter = session['available_capacity_dose1'] == 0 &&
        session['available_capacity_dose2'] == 0 &&
        session['available_capacity'] > 0;

    if (dose1 && !dose2 && !skipDoseFilter) {
      return session['available_capacity_dose1'];
    }

    if (dose2 && !dose1 && !skipDoseFilter) {
      return session['available_capacity_dose2'];
    }

    //print("${session['available_capacity']} ${session['session_id']}");

    return session['available_capacity'];
  }

  void fillCentersList() {
    String date = datesArray[selectedDateIndex]['date'];

    var data = widget.apiData['centers'];
    List<Map<dynamic, dynamic>> tempCentersList = [];

    data.forEach((c) {
      Map center = {};

      center['center_id'] = c['center_id'];
      center['name'] = c['name'];
      center['address'] =
          "${c['block_name'] == "Not Applicable" ? c['district_name'] : c['block_name']}, ${c['pincode']}";
      center['mapsAddress'] = c['address'];
      center['lat'] = c['lat'];
      center['long'] = c['long'];
      center['fee'] = c['fee_type'];
      center['min_age'] = [];

      bool sessionNotFound = true;

      for (var session in c['sessions']) {
        if (session['date'] == date) {
          sessionNotFound = false;
          center['vaccine'] = session['vaccine'];
          center['slots'] = center['slots'] == null
              ? getSlots(session)
              : center['slots'] + getSlots(session);
          if (!center['min_age'].contains(session['min_age_limit'])) {
            center['min_age'].add(session['min_age_limit']);
          }
        }
      }

      if (sessionNotFound) {
        var session = c['sessions'].isEmpty ? null : c['sessions'][0];
        if (session != null) {
          center['vaccine'] = session['vaccine'];
          center['slots'] = 0;
          center['min_age'].add(session['min_age_limit']);
        } else {
          center['vaccine'] = "Not Known";
          center['slots'] = 0;
          center['min_age'].add(18);
        }
      }

      tempCentersList.add(center);
    });
    tempCentersList.sort((a, b) => b['slots'].compareTo(a['slots']));
    setState(() {
      centersList = tempCentersList;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    eighteenPlus = widget.filters['eighteenPlus'];
    fortyfivePlus = widget.filters['fortyfivePlus'];
    covaxin = widget.filters['covaxin'];
    covishield = widget.filters['covishield'];
    dose1 = widget.filters['dose1'];
    dose2 = widget.filters['dose2'];
    widget.dates.keys.toList().forEach((date) {
      datesArray.add({"date": date, "slots": widget.dates[date]});
    });
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
                        fontSize: 19),
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
              height: 50,
              margin: EdgeInsets.only(
                top: 0,
                bottom: 20,
              ),
              width: MediaQuery.of(context).size.width - 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: FilterChip(
                      label: Text("Dose 1",
                          style: TextStyle(
                            color:
                                !dose1 ? Color(0xff0A6CFF) : Color(0xffffffff),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          )),
                      onSelected: (i) {
                        setState(() {
                          dose1 = i;
                        });
                        fillCentersList();
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
                            color:
                                !dose2 ? Color(0xff0A6CFF) : Color(0xffffffff),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          )),
                      onSelected: (i) {
                        setState(() {
                          dose2 = i;
                        });
                        fillCentersList();
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
                            fontSize: 15,
                          )),
                      onSelected: (i) {
                        setState(() {
                          eighteenPlus = i;
                        });
                        fillCentersList();
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
                            fontSize: 15,
                          )),
                      onSelected: (i) {
                        setState(() {
                          fortyfivePlus = i;
                        });
                        fillCentersList();
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
                            color: !covaxin
                                ? Color(0xff0A6CFF)
                                : Color(0xffffffff),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          )),
                      onSelected: (i) {
                        setState(() {
                          covaxin = i;
                        });
                        fillCentersList();
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
                            fontSize: 15,
                          )),
                      onSelected: (i) {
                        setState(() {
                          covishield = i;
                        });
                        fillCentersList();
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
                child: Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: centersList.length,
                  itemBuilder: (context, index) {
                    //print(centersList);
                    return CenterCard(centersList[index], widget.selectedDate);
                  },
                ),
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
  final String selectedDate;
  CenterCard(this.center, this.selectedDate);
  @override
  _CenterCardState createState() => _CenterCardState();
}

class _CenterCardState extends State<CenterCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Wrap(
                children: [
                  Container(
                      child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            top: 20, left: 20, right: 20, bottom: 20),
                        child: Text(widget.center['name'],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20,
                                color: Color(0xff323F4B),
                                fontWeight: FontWeight.w600)),
                      ),
                      Column(
                        children: [
                          ListTile(
                            onTap: () async {
                              const platform = const MethodChannel(
                                'com.arnav.smartjab/flutter',
                              );
                              try {
                                await platform.invokeMethod("openCowin");
                              } catch (e) {}
                            },
                            leading: Icon(Icons.open_in_new,
                                color: Color(0xff616E7C), size: 28),
                            title: Text(
                              "Open CoWin",
                              style: TextStyle(
                                  color: Color(0xff323F4B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          ListTile(
                            onTap: () async {
                              const platform = const MethodChannel(
                                'com.arnav.smartjab/flutter',
                              );
                              try {
                                var result =
                                    await platform.invokeMethod("openMaps", {
                                  "address":
                                      "${widget.center['name']}, ${widget.center['mapsAddress']}, ${widget.center['address']}",
                                  "lat": widget.center['lat'],
                                  "long": widget.center['long']
                                });
                              } catch (e) {}
                            },
                            leading: Icon(Icons.directions_outlined,
                                color: Color(0xff616E7C), size: 28),
                            title: Text(
                              "Get Directions",
                              style: TextStyle(
                                  color: Color(0xff323F4B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          ListTile(
                            onTap: () async {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: HospitalScreen(
                                          centerId:
                                              "${widget.center['center_id']}",
                                          name: "${widget.center['name']}",
                                          address:
                                              "${widget.center['mapsAddress']}, ${widget.center['address']}",
                                          age: widget.center['min_age'],
                                          vaccine:
                                              "${widget.center['vaccine'][0]}${widget.center['vaccine'].substring(1).toLowerCase()} (${widget.center['fee']})",
                                          selectedDate: widget.selectedDate,
                                          lat: widget.center['lat'],
                                          long: widget.center['long']),
                                      type: PageTransitionType.bottomToTop,
                                      duration: Duration(milliseconds: 250),
                                      reverseDuration:
                                          Duration(milliseconds: 250)));
                            },
                            leading: Icon(Icons.info_outlined,
                                color: Color(0xff616E7C), size: 28),
                            title: Text(
                              "View Details",
                              style: TextStyle(
                                  color: Color(0xff323F4B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20)
                    ],
                  ))
                ],
              );
            });
      },
      child: Container(
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
                          fontWeight: FontWeight.w600)),
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
                    Row(
                        children: widget.center['min_age']
                            .map<Widget>(
                              (a) => Container(
                                margin: EdgeInsets.only(right: 8),
                                child: Text("$a+",
                                    style: TextStyle(
                                        color: Color(0xff616E7C),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16)),
                              ),
                            )
                            .toList()),
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
          )),
    );
  }
}
