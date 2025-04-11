 # TutMam
 TutMan is a flutter app created primarily for iOS decives (Adndroid also supported). The app was designed to help with Tutoring Management.

## Functionalities 
### Student Management:
- Add, edit, and store student details
- Track payment rates (e.g., per hour)
- Quick access to student profiles

### Meeting Scheduling & Tracking:
- Schedule tutoring sessions with date/time selection
- Set meeting duration with adjustable intervals
- View upcoming and past meetings in a structured list
- Uses dynamic data fetching to check if the date is a Polish Holiday 

### Calendar Integration
- Automatically add meetings to the device's calendar
- Sync with iOS Calendar & Google Calendar (Android)

### Payment Tracking
- Mark meetings as paid/unpaid
- Calculate session costs based on hourly rates
- Support for multiple currencies (transfer rates functionalities not included)

### Search & Filtering
- Search meetings by student name or description
- Filter by:
  - Today's meetings
  - Upcoming sessions
  - Paid/Unpaid status
 
## Platform Support
- Optimized for iOS (Cupertino design language)
- Fully functional on Android (Material design adaptations)

## Technical Details
- Built with Flutter (Dart)
- Uses SQLite (sqflite) for local storage
- Device Calendar API for event synchronization
- Provider for state management
- Cupertino Widgets for iOS-native UI

# Running TutMan
It is higly recommended to use MacOS to run the app on a Simulator.
## Prerequisites
To run app on iOS/Android simulator.
- Flutter SDK installed (latest stable version) - to install Flutter follow the instructions: [Flutter Installation](https://docs.flutter.dev/get-started/install)
- Xcode (for iOS) - only available on macOS in AppStore
  - iOS Simulaotr - [Tutorial](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components)
- Android Studio (for Android) - [Android Studio](https://developer.android.com/studio)
  - Android Simulator

To open app on simulator run:
```bash
git clone https://github.com/Haltie13/tut_man
cd tutman
flutter pub get
flutter run
```
Follow Flutter instructions.

Example meetings will appear after adding one custom one.

## Example screenshots

<p align="center">
  <img src="Assets/Screenshot1.png" width="30%" />
  <img src="Assets/Screenshot2.png" width="30%" />
  <img src="Assets/Screenshot3.png" width="30%" />
</p>

<p align="center">
  <img src="Assets/Screenshot4.png" width="30%" />
  <img src="Assets/Screenshot5.png" width="30%" />
  <img src="Assets/Screenshot6.png" width="30%" />
</p>



  
