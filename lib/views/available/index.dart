import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';

class AvailableDaysSlots extends StatefulWidget {
  final String pincode;
  final String districtId;
  final String stateId;
  AvailableDaysSlots({this.pincode, this.districtId, this.stateId});
  @override
  _AvailableDaysSlotsState createState() => _AvailableDaysSlotsState();
}

class _AvailableDaysSlotsState extends State<AvailableDaysSlots> {
  GlobalKey<FormState> _pincodeKey = GlobalKey<FormState>();

  void getSlotsThroughPincode(pincode) async {
    var date = DateTime.now();
    var formattedDate = DateFormat('dd-MM-yyyy').format(date);
    var data = await http.get(Uri.parse(
        "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$pincode&date=$formattedDate"));
    print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSlotsThroughPincode(widget.pincode);
  }

  @override
  Widget build(BuildContext context) {
    print("${widget.pincode}" + "${widget.districtId}" + "${widget.stateId}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF5F7FA),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xff323F4B)),
        centerTitle: true,
        title: Text("Available Slots",
            style: TextStyle(
                color: Color(0xff323F4B),
                fontWeight: FontWeight.w500,
                fontSize: 20)),
      ),
      body: Container(
          padding: EdgeInsets.only(left: 27, right: 27, top: 40),
          child: Column(
            children: [
              widget.pincode != null
                  ? Form(
                      key: _pincodeKey,
                      child: TextFormField(
                          initialValue: widget.pincode,
                          onFieldSubmitted: (value) {
                            _pincodeKey.currentState.validate();
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
                  : DropdownButton(items: []),
            ],
          )),
    );
  }
}
