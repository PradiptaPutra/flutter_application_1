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
import 'penilaian_screen.dart';
import 'penilaian_alkes_screen.dart';
import 'penilaian_kendaraan_screen.dart';
import 'penilaian_pembiayaan_screen.dart';
import 'penilaian_program_screen.dart';
import 'penilaian_isiansdm_screen.dart';
import 'penilaian_kehadiransdm_screen.dart';
import 'calender_screen.dart';
import 'export_screen.dart';
import 'export_isiansdm_screen.dart';
import 'export_kehadiransdm_screen.dart';
import 'export_alkes_screen.dart';
import 'export_kendaraan_screen.dart';
import 'export_pembiayaan_screen.dart';
import 'export_sdm_screen.dart';
import 'export_program_screen.dart';
import 'penilaian_sdm_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'fade_animation.dart'; // Import FadeAnimation

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
        '/splash': (context) => FadeAnimation(child: SplashScreen()),
        '/logreg': (context) => FadeAnimation(child: LogregScreen()),
        '/login': (context) => FadeAnimation(child: LoginScreen()),
        '/register': (context) => FadeAnimation(child: RegistrationScreen()),
        '/profile': (context) => FadeAnimation(child: ProfileScreen(userId: ModalRoute.of(context)!.settings.arguments as int)),
        '/dashboard': (context) => FadeAnimation(child: DashboardScreen(userId: ModalRoute.of(context)!.settings.arguments as int)),
        '/data_entry': (context) => FadeAnimation(child: DataEntryForm(userId: ModalRoute.of(context)!.settings.arguments as int)),
        '/export': (context) => FadeAnimation(child: ExportScreen(
          puskesmas: "",
          sebelum: 0,
          sesudah: 0,
          interpretasiSebelum: "",
          interpretasiSesudah: "",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_isiansdm': (context) => FadeAnimation(child: ExportIsiansdmScreen(
          puskesmas: "",
          sebelum: 0,
          sesudah: 0,
          interpretasiSebelum: "",
          interpretasiSesudah: "",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_kehadiransdm': (context) => FadeAnimation(child: ExportKehadiransdmScreen(
          puskesmas: "",
          sebelum: 0,
          sesudah: 0,
          interpretasiSebelum: "",
          interpretasiSesudah: "",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_pembiayaan': (context) => FadeAnimation(child: ExportPembiayaanScreen(
          puskesmas: "",
          sebelum: 0,
          sesudah: 0,
          interpretasiSebelum: "",
          interpretasiSesudah: "",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_alkes': (context) => FadeAnimation(child: ExportAlkesScreen(
          puskesmas: "",
          sebelumIndikator1: 0,
          sesudahIndikator1: 0,
          sebelumIndikator2: 0,
          sesudahIndikator2: 0,
          interpretasiIndikator1Sebelum: "",
          interpretasiIndikator1Sesudah: "",
          interpretasiIndikator2Sebelum: "",
          interpretasiIndikator2Sesudah: "",
          interpretasiAkhir: "",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_sdm': (context) => FadeAnimation(child: ExportSdmScreen(
          id_category: 0,
          puskesmas: "",
          totalSPM: 0,
          totalSBL: 0,
          totalSDH: 0,
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_kendaraan': (context) => FadeAnimation(child: ExportKendaraanScreen(
          puskesmas: "",
          sebelumIndikator: 0,
          sesudahIndikator: 0,
          interpretasiSebelum: "",
          interpretasiSesudah: "",
          interpretasiAkhir: "",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
        '/export_program': (context) => FadeAnimation(child: ExportProgramScreen(
          puskesmas: "",
          totalIndikator1: 0,
          totalIndikator2: 0,
          totalIndikator3: 0,
          totalIndikator4: 0,
          totalOverall: 0,
          interpretasiIndikator1:"",
          interpretasiIndikator2:"",
          interpretasiIndikator3:"",
          interpretasiIndikator4:"",
          interpretasiOverall:"",
          userId: ModalRoute.of(context)!.settings.arguments as int,
        )),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/category_selection') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: CategorySelectionScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              entryIds: args['entryIds'],
            )),
          );
        } else if (settings.name == '/penilaian') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
            )),
          );
        } else if (settings.name == '/penilaian_isiansdm') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianIsiansdmScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
            )),
          );
        } else if (settings.name == '/penilaian_kehadiransdm') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianKehadiransdmScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
            )),
          );
        } else if (settings.name == '/penilaian_alkes') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianAlkesScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
            )),
          );
        } else if (settings.name == '/penilaian_kendaraan') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianKendaraanScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
            )),
          );
        } else if (settings.name == '/penilaian_program') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianProgramScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
              puskesmas: "",
            )),
          );
        } else if (settings.name == '/penilaian_pembiayaan') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianPembiayaanScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
            )),
          );
        } else if (settings.name == '/calendar') {
          return MaterialPageRoute(builder: (context) => FadeAnimation(child: CalendarScreen()));
        } else if (settings.name == '/penilaian_sdm') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FadeAnimation(child: PenilaianSdmScreen(
              userId: args['userId'],
              kegiatanId: args['kegiatanId'],
              id_category: args['id_category'],
              entryId: args['entryId'],
              dropdownOption: 'Non Rawat Inap', // Pass the required parameter
            )),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => FadeAnimation(child: LogregScreen()));
      },
    );
  }
}
