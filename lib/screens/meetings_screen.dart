import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tutoring_management/model/meeting_provider.dart';
import 'package:tutoring_management/model/student_provider.dart';
import 'package:tutoring_management/screens/add_meeting_screen.dart';
import '../model/student.dart';
import '/model/meeting.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Meetings'),
        ),
        child: SafeArea(child: Consumer2<MeetingProvider, StudentProvider>(
            builder: (context, meetingProvider, studentProvider, child) {
          if (meetingProvider.meetings.isEmpty) {
            return _noMeetings();
          }
          return _meetingsList(
              context, meetingProvider.meetings, studentProvider);
        })));
  }

  Widget _meetingsList(BuildContext context, List<Meeting> meetings,
      StudentProvider studentProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        final student = studentProvider.getStudent(meeting.studentId);

        return CupertinoListTile(
          leading: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                DateFormat('HH:mm').format(meeting.startTime),
                style: CupertinoTheme.of(context)
                    .textTheme
                    .textStyle
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          title: Text(
            student?.name ?? 'Unknown student',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            '${meeting.duration} min • ${DateFormat('EEE, MMM d').format(meeting.startTime)}',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${meeting.price.toStringAsFixed(2)} PLN',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: meeting.isPayed
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemRed,
                    ),
              ),
              const SizedBox(width: 8),
              if (meeting.isPayed)
                const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                    color: CupertinoColors.systemGreen, size: 20),
            ],
          ),
          onTap: () {
            // You can implement meeting details/edit navigation here
          },
        );
      },
    );
  }

  Widget _noMeetings() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.archivebox_fill),
          Text(
            'No meetings yet!',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          Text(
            'Tap the + button to add a new meeting.',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
