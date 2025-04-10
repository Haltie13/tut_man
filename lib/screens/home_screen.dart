import 'package:flutter/cupertino.dart';
import 'package:tutoring_management/add_event_example.dart';
import 'package:tutoring_management/screens/add_meeting_screen.dart';
import 'package:tutoring_management/screens/settings_screen.dart';
import 'package:tutoring_management/screens/students_screen.dart';
import 'package:tutoring_management/screens/test_button.dart';
import '/model/meeting.dart';
import 'meetings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.calendar),
                label: 'Meetings'
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.rectangle_stack_person_crop_fill),
                label: 'Students'
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Settings'
            ),
          ]
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return MeetingsScreen();
          case 1:
            return StudentsScreen();
          default:
            return SettingsScreen();
        }
      },
    );
  }
}