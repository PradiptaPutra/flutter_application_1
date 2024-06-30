import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CalendarScreen extends StatefulWidget {
  final int userId;
  CalendarScreen({required this.userId});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TextEditingController _timeController = TextEditingController();
  TextEditingController namaPuskesmasController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  TextEditingController kelurahanController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  DateTime? selectedDate;
  File? _selectedImage;
  bool _isImageLoading = false;
  String dropdownValue = 'Rawat Inap';
  String? selectedProvinsi = 'Jambi';
  String? selectedKabupaten;
  List<String> provinsiList = ['Jambi'];
  Map<String, List<String>> kabupatenList = {
    'Jambi': [
      'Kota Jambi',
      'Kabupaten Bungo',
      'Kabupaten Kerinci',
      'Kabupaten Muaro Jambi',
      'Kabupaten Sarolangun',
      'Kabupaten Tanjung Jabung Barat',
      'Kabupaten Tanjung Jabung Timur',
      'Kabupaten Tebo'
    ]
  };
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<String> _puskesmasNames = [];
  String? _selectedPuskesmas;
  TimeOfDay? _selectedTime;
  List<Map<String, dynamic>> _scheduledSurveys = [];
  bool _isLoading = true;
  int _notificationIdCounter = 0;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _setLocalTimezone();
    _initializeNotifications();
    _loadPuskesmasNames();
    _loadScheduledSurveys();
    requestExactAlarmPermission();
  }

  Future<void> _setLocalTimezone() async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return;
    }

    PermissionStatus status = await Permission.scheduleExactAlarm.request();
    if (status.isGranted) {
      print("Exact alarm permission granted.");
    } else {
      print("Exact alarm permission denied.");
    }
  }

    Future<void> _loadPuskesmasNames() async {
    setState(() {
      _isLoading = true;
    });
    final dbHelper = DatabaseHelper();
    final names = await dbHelper.getUniquePuskesmasNames(widget.userId);
    print("Puskesmas Names: $names");
    setState(() {
      _puskesmasNames = names;
      _isLoading = false;
    });
  }

  Future<void> _loadScheduledSurveys([String? puskesmasName]) async {
    setState(() {
      _isLoading = true;
    });
    final dbHelper = DatabaseHelper();
    final surveys = await dbHelper.getScheduledSurveys(widget.userId);
    print("Scheduled Surveys: $surveys");
    setState(() {
      _scheduledSurveys = puskesmasName != null
          ? surveys
              .where((survey) => survey['nama_puskesmas'] == puskesmasName)
              .toList()
          : surveys;
      _isLoading = false;
    });
  }

  Future<void> _scheduleNotification(
      DateTime scheduledDate, String puskesmasName) async {
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);
    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      throw ArgumentError(
          "scheduledDate must be in the future: $tzScheduledDate");
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'survey_channel_id',
      'Survey Notifications',
      channelDescription: 'Notifications for scheduled surveys',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    _notificationIdCounter++;
    int notificationId = _notificationIdCounter % 2147483647;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Scheduled Survey',
        'You have a survey scheduled for $puskesmasName at ${tzScheduledDate.toLocal()}',
        tzScheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print(
          'Notification scheduled for $tzScheduledDate with ID: $notificationId');
    } catch (e) {
      print('Error scheduling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _showPuskesmasDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Puskesmas Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaPuskesmasController,
                      decoration: InputDecoration(
                        labelText: 'Nama Puskesmas',
                      ),
                    ),
                    TextField(
                      controller: lokasiController,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedProvinsi,
                      hint: Text('Pilih Provinsi'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProvinsi = newValue;
                          selectedKabupaten = null;
                        });
                      },
                      items: provinsiList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    if (selectedProvinsi != null) ...[
                      DropdownButtonFormField<String>(
                        value: selectedKabupaten,
                        hint: Text('Pilih Kabupaten/Kota'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedKabupaten = newValue;
                          });
                        },
                        items: kabupatenList[selectedProvinsi!]!
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      TextField(
                        controller: kecamatanController,
                        decoration: InputDecoration(
                          labelText: 'Kecamatan',
                        ),
                      ),
                      TextField(
                        controller: kelurahanController,
                        decoration: InputDecoration(
                          labelText: 'Kelurahan',
                        ),
                      ),
                    ],
                    DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: InputDecoration(labelText: 'Jenis Layanan'),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>['Rawat Inap', 'Non Rawat Inap']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _pickImage(ImageSource.gallery, setState),
                      icon: Icon(Icons.photo_library),
                      label: Text('Ambil dari Galeri'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera, setState),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Ambil Foto'),
                    ),
                    if (_isImageLoading)
                      CircularProgressIndicator()
                    else if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.file(
                          _selectedImage!,
                          height: 200,
                        ),
                      ),
                    TextField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Select Time",
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime scheduledDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                    if (scheduledDate.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Scheduled date must be in the future.'),
                        ),
                      );
                      return;
                    }

                    final String imagePath =
                        _selectedImage != null ? _selectedImage!.path : '';

                    final dbHelper = DatabaseHelper();
                    Map<String, dynamic>? userData = await DatabaseHelper
                        .instance
                        .getUserData(widget.userId);
                    if (userData != null) {
                      String nama = userData['name'];
                      String jabatan = userData['position'];
                      String notelp = userData['phone'];

                      // Menyimpan gambar ke penyimpanan lokal
                      String namaFileFoto = '';
                      if (_selectedImage != null) {
                        final downloadsDir =
                            await getExternalStorageDirectory();
                        final directoryPath =
                            '${downloadsDir!.path}/fotopuskesmas';

                        // Create the directory if it doesn't exist
                        final directory = Directory(directoryPath);
                        if (!await directory.exists()) {
                          await directory.create(recursive: true);
                        }
                        if (downloadsDir != null) {
                          if (!await downloadsDir.exists()) {
                            await downloadsDir.create(
                                recursive:
                                    true); // Membuat folder fotopuskesmas jika belum ada
                          }
                          namaFileFoto =
                              'foto_${namaPuskesmasController.text.replaceAll(' ', '_').toLowerCase()}.jpg';
                          String filePath = path.join(
                              downloadsDir.path, 'fotopuskesmas', namaFileFoto);
                          try {
                            if (_selectedImage != null) {
                              if (downloadsDir != null) {
                                final fotopuskesmasDir = Directory(
                                    '${downloadsDir.path}/fotopuskesmas');
                                if (!await fotopuskesmasDir.exists()) {
                                  await fotopuskesmasDir.create(
                                      recursive: true);
                                }
                                String namaFileFoto =
                                    'foto_${namaPuskesmasController.text.replaceAll(' ', '_').toLowerCase()}.jpg';
                                String filePath =
                                    '${fotopuskesmasDir.path}/$namaFileFoto';
                                await _selectedImage!.copy(filePath);
                                print('Berhasil menyimpan foto ke: $filePath');
                              } else {
                                print('Gagal mendapatkan direktori eksternal');
                              }
                            }
                          } catch (e) {
                            print('Gagal menyimpan foto: $e');
                          }
                        } else {
                          print(
                              "Error: Tidak dapat mengakses direktori penyimpanan.");
                        }
                      }

                      final puskesmasId = await dbHelper.insertPuskesmas({
                        'user_id': widget.userId,
                        'nama': nama,
                        'jabatan': jabatan,
                        'notelepon': notelp,
                        'nama_puskesmas': namaPuskesmasController.text,
                        'lokasi': lokasiController.text,
                        'kelurahan': kelurahanController.text,
                        'kecamatan': kecamatanController.text,
                        'provinsi': selectedProvinsi,
                        'kabupaten_kota': selectedKabupaten,
                        'dropdown_option': dropdownValue,
                        'foto': _selectedImage != null
                            ? await _saveImage(_selectedImage!)
                            : null,
                        'tanggal_kegiatan': scheduledDate.toIso8601String(),
                      });
                    }

                    await _scheduleNotification(
                        scheduledDate, namaPuskesmasController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Survey for ${namaPuskesmasController.text} scheduled for $scheduledDate'),
                      ),
                    );

                    _clearForm();
                    Navigator.of(context).pop();
                    _loadScheduledSurveys();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _saveImage(File image) async {
    String namaFileFoto =
        'foto_${namaPuskesmasController.text.replaceAll(' ', '_').toLowerCase()}.jpg';
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = path.join(directory.path, namaFileFoto);
    final savedImage = await image.copy(imagePath);
    return namaFileFoto;
  }

  void _clearForm() {
    namaPuskesmasController.clear();
    lokasiController.clear();
    kelurahanController.clear();
    kecamatanController.clear();
    setState(() {
      selectedDate = null;
      selectedProvinsi = 'Jambi';
      selectedKabupaten = null;
      _selectedImage = null;
      _isImageLoading = false;
      _timeController.clear();
      _selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
      appBar: AppBar(
        automaticallyImplyLeading: false, // Add this line
        title: Text('Calendar'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _loadPuskesmasNames();
              _loadScheduledSurveys();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPuskesmasNames();
          await _loadScheduledSurveys();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showPuskesmasDialog(selectedDay);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 49, 75, 243),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 49, 75, 243),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.black),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.black),
                ),
              ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _scheduledSurveys.length,
                        itemBuilder: (context, index) {
                          final survey = _scheduledSurveys[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            child: ListTile(
                              tileColor: Colors.white, // warna latar belakang putih
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  'assets/images/logors.jpg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                survey['nama_puskesmas'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${survey['tanggal_kegiatan']}\n${survey['alamat'] ?? ''}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              isThreeLine: true,
                              trailing: Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _pickImage(ImageSource source, StateSetter setState) async {
    setState(() {
      _isImageLoading = true;
    });
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      File compressedFile = await _compressImage(File(image.path));
      setState(() {
        _selectedImage = compressedFile;
        _isImageLoading = false;
      });
    } else {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return File(result!.path);
  }
  @override
  void dispose() {
    _timeController.dispose();
    namaPuskesmasController.dispose();
    lokasiController.dispose();
    kelurahanController.dispose();
    kecamatanController.dispose();
    super.dispose();
  }
}
