import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          trailing: CupertinoButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => AddMeetingScreen()));
              },
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.plus,
                size: 30,
              )),
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


  Future<Widget> _meetingsList(BuildContext context, List<Meeting> meetings,
      StudentProvider studentProvider) async {
    meetings.sort((a, b) => a.startTime.compareTo(b.startTime));
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('currency') ?? 'PLN';

    final Map<String, List<Meeting>> groupedByDate = {};
    for (final meeting in meetings) {
      final dateKey = DateFormat('yyyy-MM-dd')
          .format(meeting.startTime.toLocal());
      groupedByDate.putIfAbsent(dateKey, () => []).add(meeting);
    }

    final sortedDateKeys = groupedByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    final List<_ListItem> items = [];

    for (final dateKey in sortedDateKeys) {
      final dateObj = DateTime.parse(dateKey);
      final dateHeaderText = DateFormat('EEE, MMM d, yyyy').format(dateObj);

      items.add(_ListItem(dateString: dateHeaderText));

      for (final meeting in groupedByDate[dateKey]!) {
        items.add(_ListItem(meeting: meeting));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item.isDateHeader) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              item.dateString!,
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        } else {
          // This is a regular meeting row
          final meeting = item.meeting!;
          final student = studentProvider.getStudent(meeting.studentId);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => AddMeetingScreen(meeting: meeting),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 60, // Fixed width for time
                    child: Text(
                      DateFormat('HH:mm').format(meeting.startTime.toLocal()),
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.name ?? 'Unknown student',
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${meeting.duration} min • ',
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(
                                color: CupertinoColors.systemGrey,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$currency ${meeting.price.toStringAsFixed(2)}',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(
                              color: meeting.isPayed
                                  ? CupertinoColors.systemGreen
                                  : CupertinoColors.systemRed,
                            ),
                      ),
                      if (meeting.isPayed) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.checkmark_alt_circle_fill,
                          color: CupertinoColors.systemGreen,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }
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

class _ListItem {
  final String? dateString;
  final Meeting? meeting;

  _ListItem({this.dateString, this.meeting})
      : assert(dateString != null || meeting != null);

  bool get isDateHeader => dateString != null;
}
