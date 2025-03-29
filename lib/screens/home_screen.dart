import 'package:flutter/cupertino.dart';
import 'package:tutoring_management/add_event_example.dart';
import 'package:tutoring_management/screens/add_meeting_screen.dart';
import '/screens/meetings_tab.dart';
import '/model/meeting.dart';

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
                icon: Icon(CupertinoIcons.plus),
                label: 'Add'
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
            return MeetingsCupertinoList(meetings: sampleMeetings);
          case 1:
            return AddMeetingScreen();
          default:
            return AddEventExample();
        }
      },
    );
  }
}