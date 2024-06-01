import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'data_entry_form.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'data_summary_view.dart';

void main() {
  runApp(MaterialApp(
    title: 'Health Application',
    initialRoute: '/splash',
    routes: {
      '/': (context) => LoginScreen(),
      '/register': (context) => RegistrationScreen(),
      '/profile': (context) => ProfileScreen(),
      '/splash': (context) => SplashScreen(),
      '/data_summary': (context) => DataSummaryView(entries: []), // Default route for the DataSummaryView
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
  ));
}
