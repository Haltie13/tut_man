import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tutoring_management/model/meeting_provider.dart';
import 'package:tutoring_management/model/student_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/meeting.dart';
import '../model/student.dart';

class ExportDbToFile {

  static Future<void> exportDatabaseToJson(BuildContext context) async {
    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    await meetingProvider.loadMeetings();
    await studentProvider.loadStudents();
    final students = studentProvider.students;
    final studentsMap = students.map((s) => s.toMap()).toList();
    final meetings = meetingProvider.meetings;
    final meetingsMap = meetings.map((m) => m.toMap()).toList();
    final exportData = {
      'students': studentsMap,
      'meetings': meetingsMap,
    };

    final jsonString = jsonEncode(exportData);
    final docsDir = await getTemporaryDirectory();
    final filePath =
        '${docsDir.path}/tutoring_export_${DateTime.now().toIso8601String()}.json';
    final file = File(filePath);
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Tutoring Data Export',
    );
  }

  static Future<void> importFromJson(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) return;
    File file = File(result.files.first.path!);
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString);
    final students = jsonMap['students'];

    final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    for (var studentMap in students ?? []) {
      await studentProvider.addOrUpdate(Student.fromMap(studentMap));
    }
    final meetings = jsonMap['meetings'];
    for (var meetingMap in meetings ?? []) {
      await meetingProvider.addOrUpdate(Meeting.fromMap(meetingMap));
    }
  }
}
