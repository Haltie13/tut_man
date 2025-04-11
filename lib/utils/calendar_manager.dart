import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutoring_management/utils/settings_provider.dart';

class CalendarManager {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin(shouldInitTimezone: false);

  CalendarManager();

  Future<bool> _checkAndRequestPermissions() async {
    final status = await Permission.calendar.status;
    if (!status.isGranted) {
      final result = await Permission.calendar.request();
      return result.isGranted;
    }
    return true;
  }

  Future<List<String?>?> addEventToCalendar({
    required String title,
    required TZDateTime startTime,
    required int duration,
    String? description,
    String? calendarId,
  }) async {
    try {
      final hasPermissions2 = await _hasPermissions();
      if (!hasPermissions2) {
        final hasPermissions = await _checkAndRequestPermissions();
        if (!hasPermissions) return null;
      }

      String targetCalendarId;
      if (calendarId != null) {
        targetCalendarId = calendarId;
      } else {
        final prefs = await SharedPreferences.getInstance();
        targetCalendarId = prefs.getString('calendarId') ?? '';
        if (targetCalendarId.isEmpty) {
          final defaultCalendar = await getDefaultCalendar();
          if (defaultCalendar != null) {
            targetCalendarId = defaultCalendar.id!;
          } else {
            final newCalendarId = await createCalendar("TutMan");
            if (newCalendarId == null) return null;
            targetCalendarId = newCalendarId;
          }
        }
      }

      final calendar = await _getCalendarById(targetCalendarId);
      if (calendar == null) return null;

      final event = Event(targetCalendarId)
        ..title = title
        ..description = description
        ..start = startTime
        ..end = startTime.add(Duration(minutes: duration));

      final result = await _plugin.createOrUpdateEvent(event);
      return <String?>[targetCalendarId, result!.data];
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to calendar: $e');
      }
      return null;
    }
  }

  Future<void> removeEventFromCalendar(String eventId, {String? calendarId, bool defaultCalendar = true}) async {
    try {
      final calendar = calendarId != null
          ? await _getCalendarById(calendarId)
          : await getDefaultCalendar();

      if (calendar != null) {
        await _plugin.deleteEvent(calendar.id, eventId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing event: $e');
      }
    }
  }

  Future<Calendar?> getDefaultCalendar() async {
    final calendars = await getCalendars();
    if (calendars == null || calendars.isEmpty) {
      return null;
    }

    try {
      return calendars.firstWhere(
            (cal) => cal.isDefault ?? false,
        orElse: () => calendars.first,
      );
    } catch (e) {
      return calendars.first;
    }
  }

  Future<Calendar?> _getCalendarById(String calendarId) async {
    final calendars = await getCalendars();
    if (calendars == null) return null;

    try {
      return calendars.firstWhere((cal) => cal.id == calendarId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _hasPermissions() async {
    final permissions = await _plugin.hasPermissions();
    if (permissions.data != true) {
      final requestResult = await _plugin.requestPermissions();
      return requestResult.data == true;
    }
    return true;
  }

  Future<List<Calendar>?> getCalendars() async {
    try {
      final result = await _plugin.retrieveCalendars();
      if (result.data == null || result.data!.isEmpty) return null;

      return result.data!.where((cal) => !cal.isReadOnly!).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving calendars: $e');
      }
      return null;
    }
  }

  Future<String?> getCalendarName(String? calendarId) async {
    if (calendarId == null) return null;

    try {
      final calendars = await getCalendars();
      if (calendars == null) return null;

      final calendar = calendars.firstWhere(
            (cal) => cal.id == calendarId,
      );
      return calendar.name;
    } catch (_) {
      return null;
    }
  }

  Future<String?> createCalendar(String calendarName) async {
    try {
      final result = await _plugin.createCalendar(calendarName);
      return result.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating calendar: $e');
      }
      return null;
    }
  }
}