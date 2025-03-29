import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tutoring_management/model/database_helper.dart';
import 'meeting.dart';

class MeetingProvider extends ChangeNotifier {
  List<Meeting> _meetings = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Meeting> get meetings => _meetings;

  Future<void> loadMeetings() async {
    final db = await _dbHelper.database;
    final data = await db.query('Meetings');
    _meetings = data.map((m) => Meeting.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addOrUpdate(Meeting meeting) async {
    final db = await _dbHelper.database;
    db.insert('Meetings', meeting.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    loadMeetings();
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    db.delete('Meetings', where: 'id = ?', whereArgs: [id]);
    loadMeetings();
  }
}