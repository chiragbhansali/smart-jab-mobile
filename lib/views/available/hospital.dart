import 'dart:convert';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  var apiData;
  void getCenterData() async {
    print(widget.selectedDate);
    var data = await http.get(Uri.parse(
        "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByCenter?center_id=${widget.centerId}&date=${widget.selectedDate}"));
    var body = jsonDecode(data.body);
    apiData = body;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      body: Container(
        padding: EdgeInsets.only(
          bottom: 20,
          left: 22,
          right: 22,
          top: 20,
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 12,
            ),
            Text("${widget.address}",
                style: TextStyle(
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
                  spacing: 8,
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
            Text(
              "Slot opening history",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff323F4B)),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Slot Availability",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff323F4B)),
            ),
          ],
        ),
      ),
    );
  }
}
