import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutoring_management/utils/settings_provider.dart';
import '../custom_widgets/custom_text_button.dart';
import '../utils/calendar_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    CalendarManager calendarManager = CalendarManager();
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SafeArea(
            child: ListView(
              children: [
                CupertinoFormSection.insetGrouped(
                  header: const Text('MEETING'),
                  children: [
                    CupertinoFormRow(
                      prefix: Text(
                        'Duration interval',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      child: CustomTextButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        onPressed: () =>
                            _showDurationDialog(context, settingsProvider),
                        text: '${settingsProvider.durationInterval} min',
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: Text(
                        'Currency',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      child: CustomTextButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        onPressed: () =>
                            _showCurrencyDialog(context, settingsProvider),
                        text: settingsProvider.currency,
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: Text(
                        'Calendar',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      child: FutureBuilder<String?>(
                        future: calendarManager
                            .getCalendarName(settingsProvider.calendarId),
                        builder: (context, snapshot) {
                          String displayText =
                              snapshot.hasData && snapshot.data != null
                                  ? snapshot.data!
                                  : 'Select Calendar';
                          if (displayText.length > 20) {
                            displayText = '${displayText.substring(0, 20)}...';
                          }
                          return CustomTextButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            onPressed: () =>
                                _showCalendarPicker(context, settingsProvider),
                            text: displayText,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDurationDialog(
      BuildContext context, SettingsProvider settingsProvider) async {
    int durationInterval = settingsProvider.durationInterval;
    final controller = TextEditingController(text: durationInterval.toString());
    final newDuration = await showCupertinoDialog<int>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Duration Interval'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            placeholder: 'Minutes',
            maxLength: 4,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Save'),
            onPressed: () {
              final input = controller.text;
              if (input.isNotEmpty && int.tryParse(input) != null) {
                final value = int.parse(input);
                if (value > 0) Navigator.pop(context, value);
              }
            },
          ),
        ],
      ),
    );
    if (newDuration != null) settingsProvider.setDurationInterval(newDuration);
  }

  Future<void> _showCurrencyDialog(
      BuildContext context, SettingsProvider settingsProvider) async {
    String currency = settingsProvider.currency;
    final controller = TextEditingController(text: currency);
    final newCurrency = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Currency Code'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: '3-letter code (e.g. PLN)',
            maxLength: 3,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Save'),
            onPressed: () {
              final input = controller.text.trim();
              if (input.length <= 3) {
                Navigator.pop(context, input.toUpperCase());
              }
            },
          ),
        ],
      ),
    );
    if (newCurrency != null) settingsProvider.setCurrency(newCurrency);
  }

  Future<void> _showCalendarPicker(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final cm = CalendarManager();
    final calendars = await cm.getCalendars();

    if (calendars == null || calendars.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('No Calendars'),
          content: const Text('No writable calendars found on your device.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    int selectedIndex = 0;
    if (settingsProvider.calendarId != null) {
      selectedIndex = calendars.indexWhere(
        (cal) => cal.id == settingsProvider.calendarId,
      );
      if (selectedIndex == -1) selectedIndex = 0;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            CupertinoButton(
              child: const Text('Select'),
              onPressed: () async {
                final selectedCalendar = calendars[selectedIndex];
                await settingsProvider.setCalendar(selectedCalendar.id!);
                print('Selected Calendar${selectedCalendar.id!}');
                print('Settings calendar${settingsProvider.calendarId}');
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 200,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: selectedIndex),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: calendars.map((calendar) {
                  return Center(
                    child: Text(
                      calendar.name ?? 'Unnamed Calendar',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
