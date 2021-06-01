import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HospitalScreen extends StatefulWidget {
  final String name;
  final String address;
  const HospitalScreen({this.name, this.address});

  @override
  _HospitalScreenState createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
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
          ],
        ),
      ),
    );
  }
}
