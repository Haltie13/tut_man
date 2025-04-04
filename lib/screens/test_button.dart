import 'package:flutter/cupertino.dart';

import '../utils/calendar_manager.dart';

class TestButtonScreen extends StatelessWidget {
  final cm = CalendarManager();
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
          child: CupertinoButton(child: Text('Add calendar'),
              onPressed: () => cm.createCalendar()
          ),
        )
    );
  }

}