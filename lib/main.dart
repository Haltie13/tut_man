import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tutoring_management/model/meeting_provider.dart';
import 'package:tutoring_management/model/student_provider.dart';
import 'package:tutoring_management/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tutoring_management/utils/get_device_tz_location.dart';
import 'package:tutoring_management/utils/settings_provider.dart';

void main() async {
  await initializeAppTimezones();
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final meetingProvider = MeetingProvider();
  await meetingProvider.loadMeetings();

  final studentProvider = StudentProvider();
  await studentProvider.loadStudents();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<StudentProvider>(
        create: (_) => studentProvider,
      ),
      ChangeNotifierProvider<MeetingProvider>(
        create: (_) => meetingProvider,
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => settingsProvider,
      )
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
