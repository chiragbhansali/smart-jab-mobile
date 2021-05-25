import 'dart:async';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vaccine_slot_notifier/LocalStorage.dart';
import 'package:vaccine_slot_notifier/data/districts.dart';
import 'package:vaccine_slot_notifier/views/available/index.dart';
import 'package:vaccine_slot_notifier/widgets/dropdown.dart';



class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int tabIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Color(0xffF5F7FA),
        elevation: 0,
        centerTitle: true,
        title: Text("Smart Jab",
            style: TextStyle(
                color: Color(0xff323F4B),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Text(
                  "Check available vaccination slots • Get notified instantly through an alarm",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 54,
                height: 50,
                child: CupertinoSlidingSegmentedControl(
                  backgroundColor: Color(0xffE3EFFF),
                  thumbColor: Color(0xff0A6CFF),
                  children: {
                    0: Container(
                      height: 44,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Pincode",
                            style: TextStyle(
                                fontSize: 16,
                                color: tabIndex == 0
                                    ? Color(0xffffffff)
                                    : Color(0xff0A6CFF),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    1: Container(
                      height: 44,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "District",
                            style: TextStyle(
                                fontSize: 16,
                                color: tabIndex == 1
                                    ? Color(0xffffffff)
                                    : Color(0xff0A6CFF),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  },
                  onValueChanged: (i) {
                    setState(() {
                      tabIndex = i;
                    });
                    _pageController.animateToPage(i,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.bounceInOut);
                  },
                  groupValue: tabIndex,
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height - 300,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      setState(() {
                        tabIndex = i;
                      });
                    },
                    children: [PincodeTab(), DistrictsTab()],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}



class PincodeTab extends StatefulWidget {
  @override
  _PincodeTabState createState() => _PincodeTabState();
}

class _PincodeTabState extends State<PincodeTab> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var pincode;
  var pincodeController = TextEditingController();

  final storage = LocalStorage();

  void getSavedPincode() async {
    String storedPincode = await storage.getItem("pincode");
    print(storedPincode);
    if (storedPincode != null) {
      pincodeController.text = storedPincode;
      pincode = storedPincode;
      setState(() {
        // pincode = storedPincode;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSavedPincode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 27),
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
                controller: pincodeController,
                onChanged: (value) {
                  pincode = value;
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
                    hintStyle: TextStyle(fontSize: 16),
                    labelText: "Enter your PIN Code",
                    fillColor: Color(0xffF5F7FA),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(width: 4, color: Color(0xffE4E7EB))))),
          ),
          // Current location button
          TextButton.icon(
            onPressed: () async {
              // Get the position
              Position position = await _determinePosition();
              // Get the placemarks
              List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
              // print(placemarks[0].postalCode);
              // Setting the placemarks' postalcode to the pincode
              pincode = placemarks[0].postalCode;
              pincodeController.text = placemarks[0].postalCode;
              setState(() {
              });
              // automatically go to the next screen
              /*var isValid = _formKey.currentState.validate();
              if (isValid) {
                await storage.setItem("pincode", pincode);
                Navigator.push(
                    context,
                    PageTransition(
                        child: AvailableDaysSlots(
                          pincode: pincode,
                        ),
                        type: PageTransitionType.bottomToTop,
                        duration: Duration(milliseconds: 250),
                        reverseDuration: Duration(milliseconds: 250)));
              }*/
            },
            label: Text("Use my current location",
                style: TextStyle(
                  fontSize: 16.5,
                  color: Color.fromRGBO(10, 108, 255, 1),
                  fontWeight: FontWeight.w500,
                )
            ),
            icon: Icon(Icons.my_location , size: 16.5, color: Color.fromRGBO(10, 108, 255, 1)),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          GestureDetector(
            onTap: () async {
              var isValid = _formKey.currentState.validate();
              if (isValid) {
                await storage.setItem("pincode", pincode);
                Navigator.push(
                    context,
                    PageTransition(
                        child: AvailableDaysSlots(
                          pincode: pincode,
                        ),
                        type: PageTransitionType.bottomToTop,
                        duration: Duration(milliseconds: 250),
                        reverseDuration: Duration(milliseconds: 250)));
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 54,
              height: 60,
              child: Center(
                child: Text("Check Availability",
                    style: TextStyle(
                      fontSize: 16.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xff0A6CFF),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 14,
          )
        ],
      ),
    );
  }
}

class DistrictsTab extends StatefulWidget {
  @override
  _DistrictsTabState createState() => _DistrictsTabState();
}

class _DistrictsTabState extends State<DistrictsTab> {
  String _chosenStateId = "1";
  int _chosenDistrictId = 1;
  String districtName;

  var storage = LocalStorage();

  Map<dynamic, dynamic> districts;

  void getStored() async {
    String storedStateId = await storage.getItem("stateId");
    int storedDistrictId = await storage.getItem("districtId");
    if (storedStateId != null && storedDistrictId != null) {
      fillDistrictsMap(storedStateId);
      _chosenStateId = storedStateId;
      _chosenDistrictId = storedDistrictId;
      districtName = districts[storedDistrictId];
      setState(() {});
    }
  }

  void fillDistrictsMap(stateId) {
    //print(statesAndDistricts[stateId]['districts']);
    var districtsList = statesAndDistricts[stateId]['districts'];
    Map<dynamic, dynamic> districtsMap = {};

    for (var district in districtsList) {
      districtsMap[district['district_id']] = district['district_name'];
    }

    var firstDistrictId = districtsMap.keys.toList()[0];
    setState(() {
      _chosenDistrictId = firstDistrictId;
      districtName = districtsMap[firstDistrictId];
      districts = districtsMap;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStored();
    fillDistrictsMap(_chosenStateId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 27),
      margin: EdgeInsets.only(top: 40),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              height: 60,
              child: DropdownBelow(
                itemWidth: MediaQuery.of(context).size.width - 56,
                itemTextstyle: TextStyle(
                    fontSize: 16,
                    //fontWeight: FontWeight.w500,
                    color: Color(0XFF7B8794)),
                boxTextstyle: TextStyle(
                    fontSize: 16,
                    //fontWeight: FontWeight.w500,
                    color: Color(0XFF7B8794)),
                boxPadding: EdgeInsets.fromLTRB(13, 12, 0, 12),
                boxHeight: 60,
                boxWidth: MediaQuery.of(context).size.width - 54,
                value: _chosenStateId ?? "1",
                hint: Text(statesAndDistricts[_chosenStateId]['name'],
                    style: TextStyle(
                        fontSize: 16,
                        //fontWeight: FontWeight.w500,
                        color: Color(0XFF323F4B))),
                onChanged: (v) {
                  print(v);
                  setState(() {
                    _chosenStateId = v;
                  });
                  fillDistrictsMap(v);
                },
                items: statesAndDistricts.keys
                    .toList()
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            statesAndDistricts[e]['name'],
                            style: TextStyle(
                                color: Color(0xff323F4B), fontSize: 16),
                          ),
                        ))
                    .toList(),
              )),
          SizedBox(height: 12),
          DropdownBelow(
              itemWidth: MediaQuery.of(context).size.width - 56,
              itemTextstyle: TextStyle(
                  fontSize: 16,
                  //fontWeight: FontWeight.w500,
                  color: Color(0XFF7B8794)),
              boxTextstyle: TextStyle(
                  fontSize: 16,
                  //fontWeight: FontWeight.w500,
                  color: Color(0XFF7B8794)),
              boxPadding: EdgeInsets.fromLTRB(13, 12, 0, 12),
              boxHeight: 60,
              boxWidth: MediaQuery.of(context).size.width - 54,
              value: _chosenDistrictId ?? 1,
              hint: Text(districts[_chosenDistrictId],
                  style: TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.w500,
                      color: Color(0XFF323F4B))),
              onChanged: (v) {
                setState(() {
                  _chosenDistrictId = v;
                  districtName = districts[v];
                });
              },
              items: districts.keys
                  .toList()
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(districts[e],
                            style: TextStyle(
                                color: Color(0xff323F4B), fontSize: 16)),
                      ))
                  .toList()),
          Expanded(
            child: Container(),
          ),
          GestureDetector(
            onTap: () async {
              await storage.setItem("stateId", _chosenStateId);
              await storage.setItem("districtId", _chosenDistrictId);
              Navigator.push(
                  context,
                  PageTransition(
                      child: AvailableDaysSlots(
                        stateId: _chosenStateId,
                        districtId: _chosenDistrictId,
                        districtName: districtName,
                      ),
                      type: PageTransitionType.bottomToTop,
                      duration: Duration(milliseconds: 250),
                      reverseDuration: Duration(milliseconds: 250)));
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 54,
              height: 60,
              child: Center(
                child: Text("Check Availability",
                    style: TextStyle(
                      fontSize: 16.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xff0A6CFF),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 14,
          )
        ],
      ),
    );
  }
}
