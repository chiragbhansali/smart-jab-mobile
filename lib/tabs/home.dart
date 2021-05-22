import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
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

class PincodeTab extends StatefulWidget {
  @override
  _PincodeTabState createState() => _PincodeTabState();
}

class _PincodeTabState extends State<PincodeTab> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    var pincode;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 27),
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
                initialValue: pincode,
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
          Expanded(
            flex: 1,
            child: Container(),
          ),
          GestureDetector(
            onTap: () {
              var isValid = _formKey.currentState.validate();
              if (isValid) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AvailableDaysSlots(
                              pincode: pincode,
                            )));
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

  Map<dynamic, dynamic> districts;

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
    fillDistrictsMap(_chosenStateId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AvailableDaysSlots(
                            stateId: _chosenStateId,
                            districtId: _chosenDistrictId,
                            districtName: districtName,
                          )));
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
