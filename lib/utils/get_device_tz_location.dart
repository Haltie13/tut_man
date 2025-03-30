import 'package:timezone/timezone.dart' ;
import 'package:timezone/data/latest.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

Future<String> getDeviceTimeZone() async {
  try {
    return await FlutterNativeTimezone.getLocalTimezone();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching local timezone');
    }
    return('UTC');
  }
}

Future<Location> getDeviceLocation() async {
  initializeTimeZones();
  final String timeZoneName = await getDeviceTimeZone();
  try {
    return getLocation(timeZoneName);
  } catch (e) {
    if (kDebugMode) {
      print('Could not find location $timeZoneName');
    }
    return UTC;
  }
}

TZDateTime getCurrentRoundDateTime() {
  final location = local;
  final TZDateTime now = TZDateTime.now(location).toLocal();
  return TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute - now.minute % 15,
  );
}