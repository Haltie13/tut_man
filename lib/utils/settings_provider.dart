import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_manager.dart';

class SettingsProvider with ChangeNotifier {
  String _currency = 'PLN';
  int _durationInterval = 30;
  String? _calendarId;

  String defaultCurrency = 'PLN';
  int defaultDurationInterval = 30;


  String get currency => _currency;
  int get durationInterval => _durationInterval;
  String? get calendarId => _calendarId;


  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? defaultCurrency;
    _durationInterval = prefs.getInt('durationInterval') ?? defaultDurationInterval;

    CalendarManager cm = CalendarManager();
    final defaultCalendar = await cm.getDefaultCalendar();
    _calendarId = prefs.getString('calendarId') ?? defaultCalendar?.id;

    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
    _currency = newCurrency;
    print('Currency changed to $newCurrency, notifying listeners');
    notifyListeners();
  }

  Future<void> setDurationInterval(int newDurationInterval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('durationInterval', newDurationInterval);
    _durationInterval = newDurationInterval;
    notifyListeners();();
  }

  Future<void> setCalendar(String newCalendarId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendarId', newCalendarId);
    _calendarId = newCalendarId;
    notifyListeners();
  }

}