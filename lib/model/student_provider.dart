import 'package:flutter/foundation.dart';
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
    final List<Map<String, dynamic>> maps = await db.query('Student');
    // print("Loaded students: $maps");
    _students = List.generate(maps.length, (i) => Student.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> insertStudent(Student student) async {
    final db = await _dbHelper.database;
    int id = await db.insert('Student', student.toMap());
    // print("Inserted student with id: $id");
    await loadStudents();
  }

  Future<void> updateStudent(Student student) async {
    final db = await _dbHelper.database;
    await db.update('Student', student.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
    await loadStudents();
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('Student', where: 'id = ?', whereArgs: [id]);
    await loadStudents();
  }

  Student? getStudent(int id){
    try {
      return _students.firstWhere((s) => s.id == id);
    }catch (e) {
      return null;
    }
  }
}



Future<void> addExampleStudents() async {
  StudentProvider sp = StudentProvider();

  await sp.insertStudent(Student(name: 'Alice', pricePerHour: 25.0));
  await sp.insertStudent(Student(name: 'Bob', pricePerHour: 30.0));
  await sp.insertStudent(Student(name: 'Charlie', pricePerHour: 18.75));

  print('Example students added');
}
