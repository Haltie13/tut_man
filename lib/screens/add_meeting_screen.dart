import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tutoring_management/model/database_helper.dart';
import 'package:tutoring_management/model/meeting_provider.dart';
import 'package:tutoring_management/model/student.dart';
import 'package:tutoring_management/utils/calendar_manager.dart';
import 'package:tutoring_management/utils/get_device_tz_location.dart';
import '../model/meeting.dart';
import '../model/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class AddMeetingScreen extends StatefulWidget {
  final Meeting? meeting;

  const AddMeetingScreen({Key? key, this.meeting}) : super(key: key);

  @override
  _AddMeetingScreenState createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends State<AddMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  int? meetingId;
  int? studentId = -1;
  TZDateTime startDateTime = getCurrentRoundDateTime();
  int duration = 60;
  String? eventId;
  Decimal price = Decimal.zero;
  bool iSPayed = false;
  String description = '';

  final DateFormat timeFormat = DateFormat.Hm();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  String currency = 'PLN';
  int durationInterval = 15;

  final TextEditingController _descriptionController = TextEditingController();
  var studentProvider;
  final CalendarManager calendarManager = CalendarManager();

  @override
  void initState() {
    super.initState();
    studentProvider = Provider.of<StudentProvider>(context, listen: false);
    startDateTime = widget.meeting?.startTime ?? getCurrentRoundDateTime();
    if (widget.meeting != null) {
      meetingId = widget.meeting!.id;
      studentId = widget.meeting!.studentId;
      startDateTime = widget.meeting!.startTime;
      duration = widget.meeting!.duration;
      eventId = widget.meeting!.eventId;
      price = widget.meeting!.price;
      iSPayed = widget.meeting!.isPayed;
      description = widget.meeting!.description;
    }
  }

  void _saveMeeting() async {
    if (studentId == -1) {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('You need to pick a student.'),
              actions: [
                CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Exit')
                )
              ],
            );
          }
      );
      return;
    }
    final meetingProvider = Provider.of<MeetingProvider>(
        context, listen: false);
    final student = studentProvider.getStudent(studentId);
    final studentName = student != null ? student.name : 'Tutoring';
    if (eventId != null) {
      calendarManager.removeEventFromCalendar(eventId!, defaultCalendar: true);
      if (kDebugMode) {
        print('Deleted event with id $eventId');
      }
    }
    eventId = await calendarManager.addEventToCalendar(title: studentName,
        startTime: startDateTime,
        duration: duration,
        description: description);
    Meeting meeting = Meeting(
      id: meetingId,
        startTime: startDateTime,
        duration: duration,
        studentId: studentId!,
        eventId: eventId,
        price: price,
        isPayed: iSPayed,
        description: description);
    meetingProvider.addOrUpdate(meeting);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(
        context, listen: false);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:
        Text(widget.meeting == null ? "Add New Meeting" : "Edit Meeting"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveMeeting,
          child: Text('Save'),
        ),
      ),
      child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: CupertinoFormSection.insetGrouped(
                header: Text('Meeting'),
                children: [
                  CupertinoFormRow(
                    prefix: Text('Student'),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: studentProvider.students.map((student) {
                          final isSelected = studentId == student.id;
                          return CupertinoButton(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            color: isSelected
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemGrey4,
                            onPressed: () {
                              setState(() {
                                studentId = student.id;
                              });
                            },
                            child: Text(student.name,
                                style: TextStyle(
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : CupertinoColors.systemBlue)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text('Date'),
                    controller: TextEditingController(
                        text: dateFormat.format(startDateTime)),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: startDateTime);
                      if (pickedDate != null) {
                        bool isSameDate = pickedDate.year ==
                            startDateTime.year &&
                            pickedDate.month == startDateTime.month &&
                            pickedDate.day == startDateTime.day;
                        if (!isSameDate) {
                          setState(() {
                            startDateTime = TZDateTime.local(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              startDateTime.hour,
                              startDateTime.minute,
                              startDateTime.second,
                              startDateTime.millisecond,
                              startDateTime.microsecond,
                            );
                          });
                        }
                      }
                    },
                    readOnly: true,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text('Time'),
                    controller: TextEditingController(
                        text:
                        '${timeFormat.format(startDateTime.toLocal())} - ${timeFormat
                            .format(
                            startDateTime.add(Duration(minutes: duration)).toLocal()) }'),
                    onTap: () async {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) =>
                            Container(
                              height: 250,
                              color:
                              CupertinoColors.systemBackground.resolveFrom(
                                  context),
                              child: Column(
                                children: [
                                  CupertinoButton(
                                    child: Text("Done"),
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the picker
                                    },
                                  ),
                                  Expanded(
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.time,
                                      initialDateTime: startDateTime.toLocal(),
                                      use24hFormat: true,
                                      onDateTimeChanged: (DateTime newTime) {
                                        setState(() {
                                          startDateTime = TZDateTime.local(
                                            startDateTime.year,
                                            startDateTime.month,
                                            startDateTime.day,
                                            newTime.hour,
                                            newTime.minute,
                                          );
                                        });
                                      },
                                    ),
                                  ),

                                ],
                              ),
                            ),
                      );
                    },
                    readOnly: true,
                  ),
                  CupertinoFormRow(
                    prefix: Text('Duration  $duration min'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.minus),
                          onPressed: () {
                            setState(() {
                              if (duration > durationInterval) {
                                duration -= durationInterval;
                              }
                            });
                          },
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(CupertinoIcons.add),
                          onPressed: () {
                            setState(() {
                              duration += durationInterval;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text('Price'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                            child: Text(
                              '$currency ${price.toStringAsFixed(2)}',
                              style: CupertinoTheme
                                  .of(context)
                                  .textTheme
                                  .textStyle,
                            ),
                            onPressed: () async {
                              final priceController = TextEditingController(
                                  text: price == Decimal.zero
                                      ? ''
                                      : price.toStringAsFixed(2));
                              final newPrice = await showCupertinoDialog(
                                  context: context,
                                  builder: (context) =>
                                      CupertinoAlertDialog(
                                        title: Text('Enter Price'),
                                        content: CupertinoTextField(
                                          controller: priceController,
                                          keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          placeholder: '0.00',
                                          autofocus: true,
                                          onChanged: (value) {
                                            if (Decimal.tryParse(
                                                value.replaceAll(
                                                    ',', '.')) ==
                                                null &&
                                                value.isNotEmpty) {
                                              return;
                                            }
                                          },
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            isDestructiveAction: true,
                                            isDefaultAction: true,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          CupertinoDialogAction(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context,
                                                      priceController.text),
                                              child: Text('Done'))
                                        ],
                                      ));
                              if (newPrice != null && newPrice.isNotEmpty) {
                                setState(() {
                                  price =
                                      Decimal.parse(
                                          newPrice.replaceAll(',', '.'));
                                });
                              }
                            }),
                        CupertinoButton(
                          onPressed: () {
                            setState(() {
                              double calculatedPrice =
                                  (studentProvider.getStudent(studentId!) ==
                                      null
                                      ? 0
                                      : studentProvider
                                      .getStudent(studentId!)!
                                      .pricePerHour) *
                                      duration.toDouble() /
                                      60.0;
                              price =
                                  Decimal.parse(
                                      calculatedPrice.toStringAsFixed(2));
                            });
                          },
                          child: Text(
                              '$currency ${((studentProvider.getStudent(
                                  studentId!) == null ? 0 : studentProvider
                                  .getStudent(studentId!)!.pricePerHour) *
                                  duration.toDouble() / 60.0).toStringAsFixed(
                                  2)}'),
                        ),
                      ],
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: Text('Payed'),
                    child: CupertinoCheckbox(
                        value: iSPayed,
                        onChanged: (bool? value) {
                          setState(() {
                            iSPayed = value ?? false;
                          });
                        }),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text('Description'),
                    placeholder: 'Tap to add notes',
                    controller: _descriptionController,
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    textInputAction: TextInputAction.done,
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),

                ],
              ),
            ),
          )),
    );
  }
}
