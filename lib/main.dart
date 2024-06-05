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
import 'indikator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DatabaseHelper dbHelper = DatabaseHelper();
  // await dbHelper.loadExcelData('assets/form_penilaian.xlsx');
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
        } else if (settings.name == '/indikator') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => IndikatorScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_indikator: args['id_indikator'],
              entryIds: args['entryIds'], // Add entryIds as nullable
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
