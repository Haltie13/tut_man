import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tutoring_management/screens/add_student_screen.dart';

import '../model/student.dart';
import '../model/student_provider.dart';

class StudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Students'),
          trailing: CupertinoButton(
              padding: EdgeInsets.all(0.0),
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => AddStudentScreen())
              ),
              child: Icon(
                CupertinoIcons.plus,
                size: 30,
              )),
        ),
        child: SafeArea(
          child: Consumer<StudentProvider>(
            builder: (context, studentProvider, child) {
              if (studentProvider.students.isEmpty) {
                return _noStudents();
              }
              return _studentsList(context, studentProvider.students);
            },
          ),
        ));
  }

  Widget _studentsList(BuildContext context, List<Student> students) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return _studentTile(context, student);
        });
  }

  Widget _studentTile(BuildContext context, Student student) {
    return CupertinoListTile(
      leading: Icon(CupertinoIcons.person),
      title: Text(student.name),
      trailing: CupertinoListTileChevron(),
      onTap: () => Navigator.of(context).push(CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) => AddStudentScreen(
                student: student,
              ))),
    );
  }

  Widget _noStudents() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.archivebox_fill),
          Text(
            'No students yet!',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          Text(
            'Tap the + button to add a new student.',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
