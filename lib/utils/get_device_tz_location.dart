import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';


Future<void> initializeAppTimezones() async {
  tz_data.initializeTimeZones();

  try {
    final String timezoneName = await _getDeviceTimezone();
    final location = _resolveLocation(timezoneName);
    tz.setLocalLocation(location);

    if (kDebugMode) {
      print('Successfully set timezone to: ${location.name}');
    }
  } catch (e) {
    final defaultLocation = tz.getLocation('Europe/Warsaw');
    tz.setLocalLocation(defaultLocation);

    if (kDebugMode) {
      print('Failed to detect timezone ($e), using fallback: Europe/Warsaw');
    }
  }
}

Future<String> _getDeviceTimezone() async {
  try {
    // First try the flutter_timezone package
    return await FlutterTimezone.getLocalTimezone();
  } catch (e) {
    // Fallback to platform channel
    const platform = MethodChannel('flutter_native_timezone');
    try {
      return await platform.invokeMethod('getLocalTimezone');
    } catch (_) {
      // Final fallback to system timezone name
      return DateTime.now().timeZoneName;
    }
  }
}

tz.Location _resolveLocation(String timezoneIdentifier) {
  final abbreviationMap = {
    'CEST': 'Europe/Paris',
    'CET': 'Europe/Paris',
    'EST': 'America/New_York',
    'EDT': 'America/New_York',
    'PST': 'America/Los_Angeles',
    'PDT': 'America/Los_Angeles',
    'GMT': 'Europe/London',
    'UTC': 'UTC',
  };

  try {
    return tz.getLocation(timezoneIdentifier);
  } catch (_) {
    final ianaTz = abbreviationMap[timezoneIdentifier];
    if (ianaTz != null) {
      return tz.getLocation(ianaTz);
    }

    final offset = DateTime.now().timeZoneOffset;
    return _getLocationByOffset(offset);
  }
}

tz.Location _getLocationByOffset(Duration offset) {
  final hours = offset.inHours;

  if (hours == 1 || hours == 2) {
    return tz.getLocation('Europe/Warsaw');
  } else if (hours == 0) {
    return tz.getLocation('UTC');
  } else {
    return tz.getLocation('Europe/Warsaw');
  }
}

tz.TZDateTime getCurrentRoundDateTime() {
  final now = tz.TZDateTime.now(tz.local);
  return tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute - now.minute % 15,
  );
}

