import 'package:device_calendar/device_calendar.dart';
import 'package:decimal/decimal.dart';
import 'package:timezone/timezone.dart' as tz;

class Meeting {
  final int? id;
  final TZDateTime startTime;
  final int duration; // minutes
  String? eventId;
  final int studentId;
  final Decimal price;
  final bool isPayed;
  final String description;

  Meeting({
    this.id,
    required this.startTime,
    required this.duration,
    required this.studentId,
    required this.eventId,
    required this.price,
    required this.isPayed,
    required this.description
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(), // converting TZDateTime to string
      'duration': duration,
      'eventId': eventId,
      'studentId': studentId,
      'price': price.toString(), // converting Decimal to string
      'payed': isPayed ? 1 : 0, // storing boolean as integer
      'description': description,
    };
  }

  factory Meeting.fromMap(Map<String, Object?> map) {
    return Meeting(
      id: map['id'] as int?,
      startTime: tz.TZDateTime.parse(tz.local, map['startTime'] as String),
      duration: map['duration'] as int,
      eventId: map['eventId'] as String?,
      studentId: map['studentId'] as int,
      price: Decimal.parse(map['price'] as String),
      isPayed: (map['payed'] as int) == 1,
      description: map['description'] as String,
    );
  }
}

final List<Meeting> sampleMeetings = [
  Meeting(
    id: 1,
    startTime: tz.TZDateTime.now(tz.local).add(Duration(hours: 2)),
    duration: 60,
    eventId: null,
    studentId: 101,
    price: Decimal.parse("50.00"),
    isPayed: false,
    description: "Math tutoring session",
  ),
  Meeting(
    id: 2,
    startTime: tz.TZDateTime.now(tz.local).add(Duration(days: 1)),
    duration: 45,
    eventId: null,
    studentId: 102,
    price: Decimal.parse("40.00"),
    isPayed: true,
    description: "Physics tutoring session",
  ),
];