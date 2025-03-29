import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tutoring_management/model/student_provider.dart';
import 'package:tutoring_management/screens/add_meeting_screen.dart';
import 'package:tutoring_management/screens/home_screen.dart';
import 'add_event_example.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await addExampleStudents();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<StudentProvider>(
        create: (_) => StudentProvider(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
      ],
      home: HomeScreen(),
      theme: CupertinoThemeData(primaryColor: CupertinoColors.systemBlue),
    );
  }
}
