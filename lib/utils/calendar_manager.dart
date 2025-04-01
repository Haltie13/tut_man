import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tutoring_management/model/meeting.dart';

import '../model/student.dart';
import '../model/student_provider.dart';

class CalendarManager {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin(shouldInitTimezone: false);

  CalendarManager();

  Future<String?> addEventToCalendar(
      {required String title,
      required TZDateTime startTime,
      required int duration,
      String? description}) async {
    try {
      final permissions = await _plugin.hasPermissions();
      if (permissions.data != true) {
        await _plugin.requestPermissions();
      }

      Calendar? defaultCalendar = await _defaultCalendar();
      if (defaultCalendar == null) {
        return null;
      }

      final event = Event(defaultCalendar.id)
        ..title = title
        ..description = description
        ..start = startTime
        ..end = startTime.add(Duration(minutes: duration));

      final createEventResult = await _plugin.createOrUpdateEvent(event);
      return createEventResult!.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to calendar: $e');
      }
      return null;
    }
  }
  
  Future<void> removeEventFromCalendar(String eventId, {bool defaultCalendar = true}) async {
    Calendar? calendar;
    if (defaultCalendar) {
       calendar = await _defaultCalendar();
    } else {
    //   Need to change later to chosen Calendar
      calendar = await _defaultCalendar();
    }
    try {
      _plugin.deleteEvent(calendar?.id, eventId);
    } catch (e) {
      print("Could not remove from calendar");
    }
  }

  Future<Calendar?> _defaultCalendar() async {
    final calendarsResult = await _plugin.retrieveCalendars();
    final calendars = calendarsResult.data;
    if (calendars == null || calendars.isEmpty) return null;

    return calendars.firstWhere(
          (cal) => cal.isDefault ?? false,
      orElse: () => calendars.first,
    );
  }
}
