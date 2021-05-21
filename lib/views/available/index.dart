import 'dart:convert';

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:vaccine_slot_notifier/data/districts.dart';
import 'package:vaccine_slot_notifier/models/alarm.dart';
import "package:vaccine_slot_notifier/views/available/centers.dart";
import 'package:vaccine_slot_notifier/widgets/addAlarmBottomSheet.dart';

class AvailableDaysSlots extends StatefulWidget {
  final String pincode;
  final int districtId;
  final String districtName;
  final String stateId;
  AvailableDaysSlots(
      {this.pincode, this.districtId, this.stateId, this.districtName});
  @override
  _AvailableDaysSlotsState createState() => _AvailableDaysSlotsState();
}

class _AvailableDaysSlotsState extends State<AvailableDaysSlots> {
  GlobalKey<FormState> _pincodeKey = GlobalKey<FormState>();

  bool eighteenPlus = false;
  bool fortyfivePlus = false;
  bool covishield = false;
  bool covaxin = false;
  bool dose1 = false;
  bool dose2 = false;

  bool loading = true;
  bool noSlots = false;

  Map<dynamic, dynamic> slotsPerDay = {};
  var apiData;

  String _chosenStateId;
  int _chosenDistrictId;
  String districtName;

  Map<dynamic, dynamic> districts;

  List slotsArray = [];

  void fillDistrictsMap(stateId, bool fromUseEffect) {
    var districtsList = statesAndDistricts[stateId]['districts'];
    Map<dynamic, dynamic> districtsMap = {};

    for (var district in districtsList) {
      districtsMap[district['district_id']] = district['district_name'];
    }
    if (fromUseEffect) {
      setState(() {
        districts = districtsMap;
      });
    } else {
      var firstDistrictId = districtsMap.keys.toList()[0];
      getSlotsThroughDistrict(firstDistrictId);
      setState(() {
        _chosenDistrictId = firstDistrictId;
        districts = districtsMap;
      });
    }
  }

  void getSlotsThroughDistrict(districtId) async {
    if (districtId != null) {
      setState(() {
        eighteenPlus = false;
        fortyfivePlus = false;
        covaxin = false;
        covishield = false;
      });
      var date = DateTime.now();
      var formattedDate = DateFormat('dd-MM-yyyy').format(date);
      var data = await http.get(Uri.parse(
          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtId&date=$formattedDate"));
      var body = jsonDecode(data.body);
      apiData = body;
      //print(apiData);

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

      body['centers'].forEach((center) {
        var sessions = center['sessions'];
        sessions.forEach((session) {
          if (slots[session['date']] != null) {
            slots[session['date']] =
                slots[session['date']] + session['available_capacity'];
          } else {
            slots[session['date']] = session['available_capacity'];
          }
        });
      });

      bool isNoSlots = true;
      print(slots);

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
      datesArray.sort((a, b) => a['date'].compareTo(b['date']));

      setState(() {
        noSlots = false;
        slotsPerDay = slots;
        loading = false;
        slotsArray = datesArray;
      });
    }
  }

  void getSlotsThroughPincode(pincode) async {
    if (pincode != null) {
      setState(() {
        eighteenPlus = false;
        fortyfivePlus = false;
        covaxin = false;
        covishield = false;
      });
      var date = DateTime.now();
      var formattedDate = DateFormat('dd-MM-yyyy').format(date);
      var data = await http.get(Uri.parse(
          "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$pincode&date=$formattedDate"));
      var body = jsonDecode(data.body);
      apiData = body;
      if (body['centers'].length < 1) {
        setState(() {
          noSlots = true;
          loading = false;
        });
        return;
      }
      Map<dynamic, dynamic> slots = {};

      body['centers'].forEach((center) {
        var sessions = center['sessions'];
        sessions.forEach((session) {
          if (slots[session['date']] != null) {
            slots[session['date']] =
                slots[session['date']] + session['available_capacity'];
          } else {
            slots[session['date']] = session['available_capacity'];
          }
        });
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
      datesArray.sort((a, b) => a['date'].compareTo(b['date']));

      setState(() {
        noSlots = false;
        slotsPerDay = slots;
        loading = false;
        slotsArray = datesArray;
      });
    }
  }

  void filterSlots() {
    var body = apiData;
    print(fortyfivePlus.toString());

    if (body['centers'].length < 1) {
      setState(() {
        noSlots = true;
        loading = false;
      });
      return;
    }
    Map<dynamic, dynamic> slots = {};

    body['centers'].forEach((center) {
      var sessions = center['sessions'];
      for (var session in sessions) {
        if (eighteenPlus && !fortyfivePlus) {
          if (session['min_age_limit'] == 45) {
            continue;
          }
        }

        if (fortyfivePlus && !eighteenPlus) {
          if (session['min_age_limit'] == 18) {
            continue;
          }
        }

        if (covaxin && !covishield) {
          if (session['vaccine'] == 'COVISHIELD') {
            continue;
          }
        }

        if (covishield && !covaxin) {
          if (session['vaccine'] == 'COVAXIN') {
            continue;
          }
        }

        bool skipDoseFilter = session['available_capacity_dose1'] == 0 &&
            session['available_capacity_dose2'] == 0 &&
            session['available_capacity'] > 0;

        if (dose1 && !dose2 && !skipDoseFilter) {
          if (slots[session['date']] != null) {
            slots[session['date']] =
                slots[session['date']] + session['available_capacity_dose1'];
          } else {
            slots[session['date']] = session['available_capacity_dose1'];
          }
          continue;
        }

        if (dose2 && !dose1 && !skipDoseFilter) {
          if (slots[session['date']] != null) {
            slots[session['date']] =
                slots[session['date']] + session['available_capacity_dose2'];
          } else {
            slots[session['date']] = session['available_capacity_dose2'];
          }
          continue;
        }

        if (slots[session['date']] != null) {
          slots[session['date']] =
              slots[session['date']] + session['available_capacity'];
        } else {
          slots[session['date']] = session['available_capacity'];
        }
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
      });
      return;
    }
    List datesArray = [];

    slots.keys.toList().forEach((date) {
      datesArray.add({"date": date, "slots": slots[date]});
    });
    datesArray.sort((a, b) => a['date'].compareTo(b['date']));

    apiData = body;
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
    if (widget.pincode != null) {
      getSlotsThroughPincode(widget.pincode);
    } else {
      getSlotsThroughDistrict(widget.districtId);
      print(widget.districtId);
      fillDistrictsMap(widget.stateId, true);
      _chosenStateId = widget.stateId;
      _chosenDistrictId = widget.districtId;
      districtName = widget.districtName;
      print(widget.districtId);
    }
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
        title: Text("Available Slots",
            style: TextStyle(
                color: Color(0xff323F4B),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
      ),
      body: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 27, right: 27, top: 40),
          child: Column(
            children: [
              widget.pincode != null
                  ? Form(
                      key: _pincodeKey,
                      child: TextFormField(
                          initialValue: widget.pincode,
                          onFieldSubmitted: (value) {
                            var isValid = _pincodeKey.currentState.validate();
                            if (isValid) {
                              getSlotsThroughPincode(value);
                            }
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter a PIN code";
                            } else if (value.length != 6) {
                              return "Invalid PIN Code";
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 16),
                              labelText: "PIN Code",
                              fillColor: Color(0xffF5F7FA),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                      width: 4, color: Color(0xffE4E7EB))))),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            child: FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                      fillColor: Color(0xffF5F7FA),
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              width: 4,
                                              color: Color(0xffE4E7EB)))),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        value: _chosenStateId,
                                        style: TextStyle(
                                            color: Color(0xff323F4B),
                                            fontSize: 16),
                                        onChanged: (v) {
                                          setState(() {
                                            _chosenStateId = v;
                                          });
                                          fillDistrictsMap(v, false);
                                        },
                                        items: statesAndDistricts.keys
                                            .toList()
                                            .map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    statesAndDistricts[e]
                                                        ['name'],
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff323F4B),
                                                        fontSize: 16),
                                                  ),
                                                ))
                                            .toList()),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            height: 60,
                            child: FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                      fillColor: Color(0xffF5F7FA),
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                              width: 4,
                                              color: Color(0xffE4E7EB)))),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        value: _chosenDistrictId,
                                        style: TextStyle(
                                            color: Color(0xff323F4B),
                                            fontSize: 16),
                                        onChanged: (v) {
                                          setState(() {
                                            _chosenDistrictId = v;
                                            districtName = districts[v];
                                          });
                                          getSlotsThroughDistrict(v);
                                        },
                                        items: districts.keys
                                            .toList()
                                            .map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(districts[e],
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff323F4B),
                                                          fontSize: 16)),
                                                ))
                                            .toList()),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width - 54,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: FilterChip(
                        label: Text("Dose 1",
                            style: TextStyle(
                              color: !dose1
                                  ? Color(0xff0A6CFF)
                                  : Color(0xffffffff),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            )),
                        onSelected: (i) {
                          setState(() {
                            dose1 = i;
                          });
                          filterSlots();
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
                              color: !dose2
                                  ? Color(0xff0A6CFF)
                                  : Color(0xffffffff),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            )),
                        onSelected: (i) {
                          setState(() {
                            dose2 = i;
                          });
                          filterSlots();
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
                          filterSlots();
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
                          filterSlots();
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
                              fontSize: 16,
                            )),
                        onSelected: (i) {
                          setState(() {
                            covaxin = i;
                          });
                          filterSlots();
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
                          filterSlots();
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
              Expanded(
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : noSlots
                          ? NoSlots(Alarm(
                              pincode: widget.pincode,
                              districtId: _chosenDistrictId.toString(),
                              districtName: districtName,
                              eighteenPlus: eighteenPlus.toString(),
                              fortyfivePlus: fortyfivePlus.toString(),
                              covaxin: covaxin.toString(),
                              covishield: covishield.toString(),
                              dose1: dose1.toString(),
                              dose2: dose2.toString(),
                              minAvailable: 1,
                              isOn: "true"))
                          : Container(
                              margin: EdgeInsets.only(top: 15),
                              child: ListView.builder(
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
                                        place: widget.pincode != null
                                            ? widget.pincode
                                            : districts[_chosenDistrictId]);
                                  },
                                  itemCount: slotsArray.length),
                            ))
            ],
          )),
    );
  }
}

class NoSlots extends StatefulWidget {
  final Alarm alarm;
  NoSlots(this.alarm);
  @override
  _NoSlotsState createState() => _NoSlotsState();
}

class _NoSlotsState extends State<NoSlots> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Expanded(child: Container()),
        Image.asset(
          "assets/sadold.png",
        ),
        Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "No Slots Available in this Area",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Color(0xff323F4B)),
            )),
        Expanded(child: Container()),
        GestureDetector(
          onTap: () async {
            var result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Wrap(
                    children: [
                      AddAlarmBottomSheet(widget.alarm),
                    ],
                  );
                });

            if (result == true) {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width - 54,
            height: 65,
            child: Center(
              child: Text("Set An Alarm",
                  style: TextStyle(
                    fontSize: 17,
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
        Expanded(child: Container())
      ]),
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.slots > 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CentersAvailableSlots(
                        selectedDate: widget.date,
                        dates: widget.slotsMap,
                        apiData: widget.apiData,
                        place: widget.place,
                        filters: widget.filters,
                      )));
        }
      },
      child: Container(
          height: 65,
          width: MediaQuery.of(context).size.width - 54,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    DateFormat("MMMM dd, EEEE").format(DateTime.parse(
                        "${widget.date.substring(6)}-${widget.date.substring(3, 5)}-${widget.date.substring(0, 2)} 14:04:24.367573")),
                    style: TextStyle(
                        color: widget.slots == 0
                            ? Color(0xff7B8794)
                            : Color(0xff3E4C59),
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  )),
              Expanded(child: Container()),
              Container(
                padding: EdgeInsets.only(right: 24),
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
              Icon(Icons.chevron_right,
                  size: 28,
                  color: widget.slots == 0
                      ? Color(0xff7B8794)
                      : Color(0xff616E7C)),
            ],
          )),
    );
  }
}