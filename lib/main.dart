import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'puskesmas_screen.dart';
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
import 'indikator_screen.dart';
import 'penilaian_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        '/profile': (context) => ProfileScreen(userId: ModalRoute.of(context)!.settings.arguments as int),
        '/dashboard': (context) => DashboardScreen(userId: ModalRoute.of(context)!.settings.arguments as int),
        '/data_entry': (context) => DataEntryForm(userId: ModalRoute.of(context)!.settings.arguments as int),
        '/data_summary': (context) => DataSummaryView(entries: []),
        '/facility_selection': (context) => FacilitySelectionScreen(userId: ModalRoute.of(context)!.settings.arguments as int),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/category_selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CategorySelectionScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'] ?? null,
            ),
          );
        } else if (settings.name == '/indikator') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => IndikatorScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'] ?? null,
            ),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => LogregScreen());
      },
    );
  }
}
