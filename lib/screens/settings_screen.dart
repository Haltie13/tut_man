import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_widgets/custom_text_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenPage createState() => _SettingsScreenPage();
}

class _SettingsScreenPage extends State<SettingsScreen> {
  int durationInterval = 15;
  String currency = 'PLN';

  final int defaultDurationInterval = 15;
  final String defaultCurrency = 'PLN';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      durationInterval = prefs.getInt('durationInterval') ?? defaultDurationInterval;
      currency = prefs.getString('currency') ?? defaultCurrency;
    });
  }

  Future<void> _updateSettings(String name, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == 'durationInterval' && value is int) {
      await prefs.setInt('durationInterval', value);
      setState(() => durationInterval = value);
    } else if (name == 'currency' && value is String) {
      await prefs.setString('currency', value);
      setState(() => currency = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: () => _showDurationDialog(context),
                    text: '$durationInterval min',
                  ),
                ),
                CupertinoFormRow(
                  prefix: Text(
                    'Currency',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  child: CustomTextButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: () => _showCurrencyDialog(context),
                    text: currency,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDurationDialog(BuildContext context) async {
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
    if (newDuration != null) _updateSettings('durationInterval', newDuration);
  }

  Future<void> _showCurrencyDialog(BuildContext context) async {
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
    if (newCurrency != null) _updateSettings('currency', newCurrency);
  }
}