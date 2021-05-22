import "package:flutter/material.dart";
import 'package:vaccine_slot_notifier/tabs/alarms.dart';
import 'package:vaccine_slot_notifier/tabs/home.dart';
import 'package:vaccine_slot_notifier/tabs/settings.dart';

class JabAlarm extends StatefulWidget {
  @override
  _JabAlarmState createState() => _JabAlarmState();
}

class _JabAlarmState extends State<JabAlarm> {
  int _currentIndex = 0;
  List<Widget> screens = [HomeTab(), SettingsTab()];

  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: (pageNum) {
            setState(() {
              _currentIndex = pageNum;
            });
          },
          children: [
            HomeTab(),
            AlarmsTab(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 64,
          decoration: BoxDecoration(color: Color(0xffF5F7FA)),
          child: BottomNavigationBar(
            onTap: (i) {
              _currentIndex = i;
              _pageController.animateToPage(i,
                  duration: Duration(milliseconds: 300), curve: Curves.linear);
              setState(() {});
            },
            backgroundColor: Color(0xffF5F7FA),
            elevation: 0,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedItemColor: Theme.of(context).primaryColor,
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    size: 28,
                  ),
                  title: Text("Home",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500))),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.alarm,
                    size: 28,
                  ),
                  title: Text("Alarms",
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500))),
            ],
          ),
        ));
  }
}
