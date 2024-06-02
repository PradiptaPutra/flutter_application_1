import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'data_entry_form.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'data_summary_view.dart';
import 'logreg_screen.dart';
import 'dashboard_screen.dart';
import 'puskesmas_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Application',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/logreg': (context) => LogregScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/profile': (context) => ProfileScreen(),
        '/dashboard': (context) => DashboardScreen(userId: ModalRoute.of(context)!.settings.arguments as int),
        '/puskesmas': (context) => PuskesmasScreen(),
        '/data_summary': (context) => DataSummaryView(entries: []), // Default route for the DataSummaryView
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
        }
        return null;
      },
    );
  }
}
