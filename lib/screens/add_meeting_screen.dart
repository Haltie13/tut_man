import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:tutoring_management/custom_widgets/custom_text_button.dart';
import 'package:tutoring_management/model/meeting_provider.dart';
import 'package:tutoring_management/utils/calendar_manager.dart';
import '../model/meeting.dart';
import '../model/student_provider.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../utils/get_device_tz_location.dart';

class AddMeetingScreen extends StatefulWidget {
  final Meeting? meeting;

  const AddMeetingScreen({Key? key, this.meeting}) : super(key: key);

  @override
  _AddMeetingScreenState createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends State<AddMeetingScreen> {
  int? meetingId;
  int? studentId = -1;
  TZDateTime startDateTime = getCurrentRoundDateTime();
  int duration = 60;
  String? eventId;
  String? calendarId;
  Decimal price = Decimal.zero;
  bool iSPaid = false;
  String description = '';

  final DateFormat timeFormat = DateFormat.Hm();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  String currency = 'PLN';
  int durationInterval = 15;
  List<Map<String, dynamic>> _holidays = [];
  String? _holidayName;
  bool _isHolidayLoading = false;

  final TextEditingController _descriptionController = TextEditingController();

  late StudentProvider studentProvider;
  final CalendarManager calendarManager = CalendarManager();

  bool _showTimePicker = false;
  bool _showDatePicker = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    studentProvider = Provider.of<StudentProvider>(context, listen: false);
    startDateTime = widget.meeting?.startTime ?? getCurrentRoundDateTime();
    _fetchHolidays();

    if (widget.meeting != null) {
      meetingId = widget.meeting!.id;
      studentId = widget.meeting!.studentId;
      startDateTime = widget.meeting!.startTime;
      duration = widget.meeting!.duration;
      eventId = widget.meeting!.eventId;
      price = widget.meeting!.price;
      iSPaid = widget.meeting!.isPaid;
      description = widget.meeting!.description;
      _descriptionController.text = description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currency = prefs.getString('currency') ?? 'PLN';
      durationInterval = prefs.getInt('durationInterval') ?? 15;
      if (widget.meeting == null) {
        duration = durationInterval;
      }
    });
  }

  Future<void> _fetchHolidays() async {
    setState(() => _isHolidayLoading = true);
    try {
      final year = DateTime.now().year;
      final response = await http.get(
        Uri.parse('https://date.nager.at/api/v3/PublicHolidays/$year/PL'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _holidays = data.map((holiday) => {
            'date': DateTime.parse(holiday['date']),
            'name': holiday['localName'] ?? holiday['name'] ?? 'Holiday'
          }).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch holidays: $e');
      }
    } finally {
      setState(() => _isHolidayLoading = false);
    }
  }


  void _checkHoliday(DateTime date) {
    final holiday = _holidays.firstWhere(
          (h) =>
      h['date'].year == date.year &&
          h['date'].month == date.month &&
          h['date'].day == date.day,
      orElse: () => {'name': null},
    );

    setState(() {
      _holidayName = holiday['name'];
    });
  }

  void _saveMeeting() async {
    if (studentId == -1) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('You need to pick a student.'),
          actions: [
            CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Exit'))
          ],
        ),
      );
      return;
    }

    final meetingProvider =
        Provider.of<MeetingProvider>(context, listen: false);
    final student = studentProvider.getStudent(studentId);
    final studentName = student?.name ?? 'Deleted student';

    if (eventId != null) {
      calendarManager.removeEventFromCalendar(eventId!, calendarId: calendarId);
      if (kDebugMode) {
        print('Deleted event with id $eventId');
      }
    }

    final result = await calendarManager.addEventToCalendar(
        title: studentName,
        startTime: startDateTime,
        duration: duration,
        description: '$currency $price\n$description');

    if (result != null) {
      calendarId = result[0];
      eventId = result[1];
    }

    final meeting = Meeting(
        id: meetingId,
        startTime: startDateTime,
        duration: duration,
        studentId: studentId,
        eventId: eventId,
        calendarId: calendarId,
        price: price,
        isPaid: iSPaid,
        description: description);

    meetingProvider.addOrUpdate(meeting);
    Navigator.of(context).pop();
  }

  Future<void> _deleteMeeting() async {
    if (meetingId == null) return;

    if (eventId != null) {
      calendarManager.removeEventFromCalendar(eventId!, calendarId: calendarId);
      if (kDebugMode) {
        print('Deleted event with id $eventId');
      }
    }

    final meetingProvider =
        Provider.of<MeetingProvider>(context, listen: false);
    await meetingProvider.delete(meetingId!);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:
            Text(widget.meeting == null ? "Add New Meeting" : "Edit Meeting"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveMeeting,
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CupertinoFormSection.insetGrouped(
                      header: const Text('Meeting'),
                      children: [
                        _buildStudentSelector(),
                        _buildDateRow(),
                        _buildTimeRow(),
                        _buildDurationRow(),
                        _buildPriceRow(),
                        _buildPaymentStatusRow(),
                        _buildDescriptionField(),
                      ],
                    ),
                    _buildSettingsHint(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDeleteButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector() {
    return CupertinoFormRow(
      prefix: const Text('Student'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: studentProvider.students.map((student) {
            final isSelected = studentId == student.id;
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              pressedOpacity: 0.6,
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : CupertinoDynamicColor.resolve(
                      CupertinoColors.secondarySystemFill,
                      context,
                    ),
              onPressed: () => setState(() => studentId = student.id!),
              child: Text(
                student.name,
                style: TextStyle(
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoDynamicColor.resolve(
                          CupertinoColors.secondaryLabel,
                          context,
                        ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    return Column(
      children: [
        CupertinoFormRow(
          prefix: const Text('Date'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextButton(
                onPressed: () => setState(() => _showDatePicker = !_showDatePicker),
                text: dateFormat.format(startDateTime),
              ),
              if (_holidayName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _holidayName!,
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_showDatePicker)
          Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: startDateTime.toLocal(),
              minimumDate: DateTime(2000),
              maximumDate: DateTime(2100),
              showDayOfWeek: true,
              dateOrder: DatePickerDateOrder.dmy,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  startDateTime = TZDateTime.local(
                    newDate.year,
                    newDate.month,
                    newDate.day,
                    startDateTime.hour,
                    startDateTime.minute,
                  );
                  _checkHoliday(newDate);
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTimeRow() {
    return Column(
      children: [
        CupertinoFormRow(
          prefix: const Text('Time'),
          child: CustomTextButton(
            onPressed: () => setState(() => _showTimePicker = !_showTimePicker),
            text: '${timeFormat.format(startDateTime.toLocal())} - '
                '${timeFormat.format(startDateTime.add(Duration(minutes: duration)).toLocal())}',
          ),
        ),
        if (_showTimePicker)
          Container(
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }

  Widget _buildDurationRow() {
    return CupertinoFormRow(
      prefix: Text('Duration  $duration min'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.minus),
            onPressed: () {
              if (duration > durationInterval) {
                setState(() => duration -= durationInterval);
              }
            },
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add),
            onPressed: () => setState(() => duration += durationInterval),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return CupertinoFormRow(
      prefix: const Text('Price'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            child: Text(
              '$currency ${price.toStringAsFixed(2)}',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            onPressed: () async {
              final priceController = TextEditingController(
                  text: price == Decimal.zero ? '' : price.toStringAsFixed(2));

              final newPrice = await showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Enter Price'),
                  content: CupertinoTextField(
                    controller: priceController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    placeholder: '0.00',
                    autofocus: true,
                    onChanged: (value) {
                      if (Decimal.tryParse(value.replaceAll(',', '.')) ==
                              null &&
                          value.isNotEmpty) {
                        return;
                      }
                    },
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoDialogAction(
                      child: const Text('Done'),
                      onPressed: () =>
                          Navigator.pop(context, priceController.text),
                    ),
                  ],
                ),
              );

              if (newPrice != null && newPrice.isNotEmpty) {
                setState(() {
                  price = Decimal.parse(newPrice.replaceAll(',', '.'));
                });
              }
            },
          ),
          CupertinoButton(
            onPressed: () {
              final student = studentProvider.getStudent(studentId);
              final pricePerHour = student?.pricePerHour ?? 0;
              final calculatedPrice =
                  (pricePerHour as Decimal).toDouble() * duration / 60.0;
              setState(() {
                price = Decimal.parse(calculatedPrice.toString());
              });
            },
            child: Text(
                '$currency ${((studentProvider.getStudent(studentId)?.pricePerHour.toDouble() ?? 0) * duration.toDouble() / 60.0).toStringAsFixed(2)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusRow() {
    return CupertinoFormRow(
      prefix: const Text('Payed'),
      child: CupertinoCheckbox(
        value: iSPaid,
        onChanged: (bool? value) => setState(() => iSPaid = value ?? false),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return CupertinoTextFormFieldRow(
      prefix: const Text('Description'),
      placeholder: 'Tap to add notes',
      controller: _descriptionController,
      onChanged: (value) => setState(() => description = value),
      textInputAction: TextInputAction.done,
      minLines: 1,
      maxLines: 3,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildDeleteButton() {
    return CupertinoButton(
      onPressed: () async {
        final bool? confirmed = await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Delete meeting'),
              content: const Text('Are you sure you want to delete this meeting? This action cannot be undone.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('No'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          _deleteMeeting();
          Navigator.of(context).pop();
        }
      },
      child: const Text(
        'Delete',
        style: TextStyle(color: CupertinoColors.destructiveRed),
      ),
    );
  }

  Widget _buildSettingsHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.gear,
              size: 20,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You can change duration interval and currency in Settings',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
