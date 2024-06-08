import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'splash_screen.dart';
import 'logreg_screen.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';
import 'data_entry_form.dart';
import 'category_selection_screen.dart';
import 'penilaian_screen.dart'; // Import for penilaian_screen
import 'penilaian_alkes_screen.dart'; // Import for penilaian_alkes_screen
import 'calender_screen.dart'; // Import for calendar_screen
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'export_screen.dart'; // Add this import


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

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
        '/export': (context) => ExportScreen(puskesmas: "", sebelum: 0, sesudah: 0, interpretasiSebelum: "", interpretasiSesudah: ""), // Tambahkan rute ini
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/category_selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CategorySelectionScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              entryIds: args['entryIds'], // Add entryIds as nullable
            ),
          );
        } else if (settings.name == '/penilaian') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PenilaianScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'], // Add entryId as nullable
            ),
          );
        } else if (settings.name == '/penilaian_alkes') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PenilaianAlkesScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'], // Add entryId as nullable
            ),
          );
        } else if (settings.name == '/calendar') {
          return MaterialPageRoute(builder: (context) => CalendarScreen());
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => LogregScreen());
      },
    );
  }
}
