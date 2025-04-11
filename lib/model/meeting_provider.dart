import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tutoring_management/model/database_helper.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tutoring_management/model/student.dart';
import 'package:tutoring_management/model/student_provider.dart';
import 'meeting.dart';

class MeetingProvider extends ChangeNotifier {
  List<Meeting> _meetings = [];
  List<MeetingFilter> _activeFilters = [MeetingFilter.all];
  String _search = '';
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Meeting> get meetings => _meetings;
  List<Meeting> get filteredMeetings => _applyFilters(meetings);
  List<MeetingFilter> get activeFilters => _activeFilters;

  Future<void> loadMeetings() async {
    final db = await _dbHelper.database;
    final data = await db.query('Meeting');
    _meetings = data.map((m) => Meeting.fromMap(m)).toList();
    notifyListeners();
  }

  void toggleFilter(MeetingFilter filter) {
    if (filter == MeetingFilter.all) {
      _activeFilters = [MeetingFilter.all];
    } else {
      _activeFilters.remove(MeetingFilter.all);

      if (filter == MeetingFilter.paid || filter == MeetingFilter.unpaid) {
        _activeFilters.remove(MeetingFilter.paid);
        _activeFilters.remove(MeetingFilter.unpaid);
      }

      if (filter == MeetingFilter.today || filter == MeetingFilter.upcoming) {
        _activeFilters.remove(MeetingFilter.today);
        _activeFilters.remove(MeetingFilter.upcoming);
      }

      _activeFilters.add(filter);

      if (_activeFilters.isEmpty) {
        _activeFilters.add(MeetingFilter.all);
      }
    }
    notifyListeners();
  }

  void setSearch(String search) {
    _search = search;
    notifyListeners();
  }

  List<Meeting> _applyFilters(List<Meeting> meetings) {
    List<Meeting> filtered = _search.isNotEmpty
        ? meetings.where((meeting) {
      final student = _getStudent(meeting.studentId);
      return student?.name.toLowerCase().contains(_search.toLowerCase()) == true ||
          meeting.description.toLowerCase().contains(_search.toLowerCase());
    }).toList()
        : List.from(meetings);

    if (_activeFilters.contains(MeetingFilter.all)) {
      return filtered;
    }

    return filtered.where((meeting) {
      bool passesFilter = true;
      final now = tz.TZDateTime.now(tz.local);
      final meetingDate = meeting.startTime;

      if (_activeFilters.contains(MeetingFilter.today)) {
        passesFilter = passesFilter &&
            meetingDate.year == now.year &&
            meetingDate.month == now.month &&
            meetingDate.day == now.day;
      }

      if (_activeFilters.contains(MeetingFilter.upcoming)) {
        passesFilter = passesFilter && meetingDate.isAfter(now);
      }

      if (_activeFilters.contains(MeetingFilter.paid)) {
        passesFilter = passesFilter && meeting.isPaid;
      }

      if (_activeFilters.contains(MeetingFilter.unpaid)) {
        passesFilter = passesFilter && !meeting.isPaid;
      }

      return passesFilter;
    }).toList();
  }

  Student? _getStudent(int? id) {
    StudentProvider studentProvider = StudentProvider();
    return studentProvider.getStudent(id);
  }

  Future<void> addOrUpdate(Meeting meeting) async {
    final db = await _dbHelper.database;
    db.insert(
      'Meeting',
      meeting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadMeetings();
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    db.delete('Meeting', where: 'id = ?', whereArgs: [id]);
    await loadMeetings();
  }

  Future<void> addExampleMeetings() async {
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < 10; i++) {
      final meeting = Meeting(
        startTime: now.add(Duration(hours: i*6)),
        duration: 30 + i * 5,
        studentId: i % 3 +1,
        eventId: null,
        calendarId: null,
        price: Decimal.parse((50 + i * 10).toString()),
        isPaid: i % 2 == 0,
        description: 'Example meeting #$i',
      );

      await addOrUpdate(meeting);
    }

    await loadMeetings();
    print('10 example meetings added');
    notifyListeners();
  }
}

enum MeetingFilter {
  all('All Meetings'),
  today('Today'),
  upcoming('Upcoming'),
  paid('Paid'),
  unpaid('Unpaid');

  final String displayName;

  const MeetingFilter(this.displayName);
}
