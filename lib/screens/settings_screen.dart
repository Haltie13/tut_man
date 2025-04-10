import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutoring_management/utils/settings_provider.dart';
import '../custom_widgets/custom_text_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () => _showDurationDialog(context, settingsProvider),
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
                        onPressed: () => _showCurrencyDialog(context, settingsProvider),
                        text: settingsProvider.currency,
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

  Future<void> _showDurationDialog(BuildContext context, SettingsProvider settingsProvider) async {
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

  Future<void> _showCurrencyDialog(BuildContext context, SettingsProvider settingsProvider) async {
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
}
