import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'data_entry_form.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'summary_view.dart';

void main() {
  runApp(MaterialApp(
    title: 'Health Application',
    initialRoute: '/splash',
    routes: {
      '/': (context) => LoginScreen(),
      '/register': (context) => RegistrationScreen(),
      '/profile': (context) => ProfileScreen(),
      '/splash': (context) => SplashScreen(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/data_entry') {
        final args = settings.arguments as Map<String, dynamic>;
        final userId = args['userId'];
        return MaterialPageRoute(
          builder: (context) => DataEntryForm(userId: userId),
                  );
      } else if (settings.name == '/summary') {
        final args = settings.arguments as Map<String, dynamic>;
        final entries = args['entries'] as List<Map<String, dynamic>>;
        return MaterialPageRoute(
          builder: (context) => SummaryView(entries: entries),
        );
      }
      return null;
    },
  ));
}

       
