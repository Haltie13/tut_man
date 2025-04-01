import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;


class AddEventExample extends StatelessWidget {
  const AddEventExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
          child: CupertinoButton.filled(
              onPressed: () => (),
              child: Icon(
                CupertinoIcons.add,
                color: CupertinoTheme.of(context).primaryContrastingColor,
              )),
        ));
  }

  Future<void> addEventToCalendar({
    required String title,
    required String description,
    required TZDateTime startDate,
    required TZDateTime endDate,
  }) async {
    print('AEEL ${tz.local}, ${tz.TZDateTime.now(tz.local)}');
    print(startDate);
    print(startDate.location);
    final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();

    var permissionStatusFull = await Permission.calendarFullAccess.status;

    if (!permissionStatusFull.isGranted ) {
      permissionStatusFull = await Permission.calendarFullAccess.request();

      if (!permissionStatusFull.isGranted) {
        print("Brak uprawnień do kalendarza!");
        return;
      }
    }

    var calendarsResult = await _calendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
      final calendar = calendarsResult.data![1];

      List<Calendar> calendars = calendarsResult.data!;
      for (var calendar in calendars) {
        print("Kalendarz: ${calendar.name}, ID: ${calendar.id}");
      }

      final event = Event(
        calendar.id,
        title: title,
        description: description,
        start: startDate,
        end: endDate,
      );

      final result = await _calendarPlugin.createOrUpdateEvent(event);
      if (result!.isSuccess) {
        print("Wydarzenie dodane do kalendarza!");
      } else {
        print("Nie udało się dodać wydarzenia.");
      }
    } else {
      print("Brak dostępnych kalendarzy.");
    }
  }


}
