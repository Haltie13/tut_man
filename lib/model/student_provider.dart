import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'student.dart';

class StudentProvider extends ChangeNotifier {
  static StudentProvider? _instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Student> _students = [];

  StudentProvider._internal();

  factory StudentProvider() {
    _instance ??= StudentProvider._internal();
    return _instance!;
  }

  List<Student> get students => _students;

  Future<void> loadStudents() async {
    final db = await _dbHelper.database;
    final data = await db.query('Student');
    _students = data.map((m) => Student.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addOrUpdate(Student student) async {
    final db = await DatabaseHelper().database;
    db.insert(
      'Student',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadStudents();
  }

  Future<void> delete(int? id) async {
    if (id==null) return;
    final db = await _dbHelper.database;
    await db.delete('Student', where: 'id = ?', whereArgs: [id]);
    await loadStudents();
  }

  Student? getStudent(int? id) {
    try {
      if (id == null) return null;
      return _students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addExampleStudents() async {
    await addOrUpdate(
        Student(name: 'Alice', pricePerHour: Decimal.parse('65.0')));
    await addOrUpdate(
        Student(name: 'Bob', pricePerHour: Decimal.parse('70.0')));
    await addOrUpdate(
        Student(name: 'Charlie', pricePerHour: Decimal.parse('90.0')));
    await loadStudents();
    print('Example students added');
  }
}
