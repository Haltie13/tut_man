import 'package:flutter/cupertino.dart';
import 'package:tutoring_management/screens/add_meeting_screen.dart';
import '/model/meeting.dart';

class MeetingsCupertinoList extends StatelessWidget {
  final List<Meeting> meetings;

  const MeetingsCupertinoList({Key? key, required this.meetings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Meetings'),
      ),
      child: ListView.builder(
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context,
              CupertinoPageRoute(builder: (context) => AddMeetingScreen(meeting: meetings[index],)));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                    blurRadius: 4.0,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start: ${meeting.startTime.toIso8601String()}',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dun: ${meeting.duration} mins',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Student ID: ${meeting.studentId}',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: ${meeting.price}',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Payed: ${meeting.isPayed ? 'Yes' : 'No'}',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Description: ${meeting.description}',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}