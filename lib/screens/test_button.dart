import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TestButtonScreen extends StatefulWidget {
  const TestButtonScreen({Key? key}) : super(key: key);

  @override
  State<TestButtonScreen> createState() => _TestButtonScreenState();
}

class _TestButtonScreenState extends State<TestButtonScreen> {
  List<DateTime> _holidays = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final formater = DateFormat('EEE, MMM d yyyy');

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final year = DateTime.now().year;
      final response = await http.get(
        Uri.parse('https://date.nager.at/api/v3/PublicHolidays/$year/PL'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _holidays = data.map((e) => DateTime.parse(e['date'])).toList();
        });
      } else {
        throw Exception('Failed to load holidays: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isHoliday(DateTime date) {
    return _holidays.any((h) =>
    h.year == date.year &&
        h.month == date.month &&
        h.day == date.day
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Polish Holidays'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoButton(
              onPressed: _loadHolidays,
              child: const Text('Refresh Holidays'),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CupertinoActivityIndicator(),
              ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: CupertinoColors.systemRed),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _holidays.length,
                itemBuilder: (context, index) {
                  final holiday = _holidays[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('EEE, MMM d yyyy').format(holiday),
                          ),
                        ),
                        if (_isHoliday(DateTime.now()))
                          const Icon(
                            CupertinoIcons.checkmark_alt_circle_fill,
                            color: CupertinoColors.systemGreen,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

