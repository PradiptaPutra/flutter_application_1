import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/puskesmas_screen.dart';
import 'home_content.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'data_entry_form.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'data_summary_view.dart';
import 'logreg_screen.dart';
import 'dashboard_screen.dart';
import 'category_selection_screen.dart';
import 'facility_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');

  runApp(MyApp(userId: userId));
}

class MyApp extends StatelessWidget {
  final int? userId;

  MyApp({this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Application',
      initialRoute: userId == null ? '/logreg' : '/dashboard',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/logreg': (context) => LogregScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/profile': (context) => ProfileScreen(userId: userId ?? 1),
        '/dashboard': (context) => DashboardScreen(userId: userId ?? 1),
        '/data_entry': (context) => DataEntryForm(userId: userId ?? 1),
        '/data_summary': (context) => DataSummaryView(entries: []),
        '/category_selection': (context) => CategorySelectionScreen(userId: userId ?? 1),
        '/facility_selection': (context) => FacilitySelectionScreen(userId: userId ?? 1),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => LogregScreen());
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/data_entry') {
          final args = settings.arguments as Map<String, dynamic>;
          final userId = args['userId'];
          return MaterialPageRoute(
            builder: (context) => DataEntryForm(userId: userId),
          );
        } else if (settings.name == '/data_summary') {
          final args = settings.arguments as Map<String, dynamic>;
          final entries = args['entries'];
          return MaterialPageRoute(
            builder: (context) => DataSummaryView(entries: entries),
          );
        } else if (settings.name == '/category_selection') {
          final args = settings.arguments as Map<String, dynamic>;
          final userId = args['userId'];
          return MaterialPageRoute(
            builder: (context) => CategorySelectionScreen(userId: userId),
          );
        } else if (settings.name == '/facility_selection') {
          final args = settings.arguments as Map<String, dynamic>;
          final userId = args['userId'];
          return MaterialPageRoute(
            builder: (context) => FacilitySelectionScreen(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
