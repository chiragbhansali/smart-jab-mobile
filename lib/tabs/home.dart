import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";

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
        backgroundColor: Color(0xffF5F7FA),
        elevation: 0,
        centerTitle: true,
        title: Text("Find My Jab",
            style: TextStyle(
                color: Colors.black,
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
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
  bool eighteenPlus = true;
  bool fortyfivePlus = true;
  bool covaxine = true;
  bool covishield = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 27),
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          TextField(
              decoration: InputDecoration(
                  labelText: "Enter your Pin Code",
                  fillColor: Color(0xffF5F7FA),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(width: 4, color: Color(0xffE4E7EB))))),
          // Container(
          //   height: 50,
          //   margin: EdgeInsets.only(top: 20),
          //   width: MediaQuery.of(context).size.width - 54,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: [
          //       Padding(
          //         padding: EdgeInsets.all(4),
          //         child: FilterChip(
          //           label: Text("18+",
          //               style: TextStyle(
          //                 color: !eighteenPlus
          //                     ? Color(0xff0A6CFF)
          //                     : Color(0xffffffff),
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 16,
          //               )),
          //           onSelected: (i) {
          //             setState(() {
          //               eighteenPlus = i;
          //             });
          //           },
          //           labelPadding:
          //               EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //           disabledColor: Color(0xffE3EFFF),
          //           backgroundColor: Color(0xffE3EFFF),
          //           selectedColor: Color(0xff0A6CFF),
          //           selected: eighteenPlus,
          //           checkmarkColor: Colors.white,
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.all(4.0),
          //         child: FilterChip(
          //           label: Text("45+",
          //               style: TextStyle(
          //                 color: !fortyfivePlus
          //                     ? Color(0xff0A6CFF)
          //                     : Color(0xffffffff),
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 16,
          //               )),
          //           onSelected: (i) {
          //             setState(() {
          //               fortyfivePlus = i;
          //             });
          //           },
          //           labelPadding:
          //               EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //           disabledColor: Color(0xffE3EFFF),
          //           backgroundColor: Color(0xffE3EFFF),
          //           selectedColor: Color(0xff0A6CFF),
          //           selected: fortyfivePlus,
          //           checkmarkColor: Colors.white,
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.all(4.0),
          //         child: FilterChip(
          //           label: Text("Covaxine",
          //               style: TextStyle(
          //                 color:
          //                     !covaxine ? Color(0xff0A6CFF) : Color(0xffffffff),
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 16,
          //               )),
          //           onSelected: (i) {
          //             setState(() {
          //               covaxine = i;
          //             });
          //           },
          //           labelPadding:
          //               EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //           disabledColor: Color(0xffE3EFFF),
          //           backgroundColor: Color(0xffE3EFFF),
          //           selectedColor: Color(0xff0A6CFF),
          //           selected: covaxine,
          //           checkmarkColor: Colors.white,
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.all(4.0),
          //         child: FilterChip(
          //           label: Text("Covishield",
          //               style: TextStyle(
          //                 color: !covishield
          //                     ? Color(0xff0A6CFF)
          //                     : Color(0xffffffff),
          //                 fontWeight: FontWeight.w500,
          //                 fontSize: 16,
          //               )),
          //           onSelected: (i) {
          //             setState(() {
          //               covishield = i;
          //             });
          //           },
          //           labelPadding:
          //               EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //           disabledColor: Color(0xffE3EFFF),
          //           backgroundColor: Color(0xffE3EFFF),
          //           selectedColor: Color(0xff0A6CFF),
          //           selected: covishield,
          //           checkmarkColor: Colors.white,
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 54,
            height: 65,
            child: Center(
              child: Text("Check Availability",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xff0A6CFF),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 27),
      margin: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          TextField(
              decoration: InputDecoration(
                  labelText: "Select your State",
                  fillColor: Color(0xffF5F7FA),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(width: 4, color: Color(0xffE4E7EB))))),
          SizedBox(
            height: 12,
          ),
          TextField(
              decoration: InputDecoration(
                  labelText: "Select Your District",
                  fillColor: Color(0xffF5F7FA),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          BorderSide(width: 4, color: Color(0xffE4E7EB))))),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 54,
            height: 65,
            child: Center(
              child: Text("Check Availability",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xff0A6CFF),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
    ;
  }
}
