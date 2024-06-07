import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database_helper.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TextEditingController _timeController = TextEditingController();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<String> _puskesmasNames = [];
  String? _selectedPuskesmas;
  TimeOfDay? _selectedTime;
  List<Map<String, dynamic>> _scheduledSurveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPuskesmasNames();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadPuskesmasNames() async {
    final dbHelper = DatabaseHelper();
    final names = await dbHelper.getUniquePuskesmasNames();
    setState(() {
      _puskesmasNames = names;
      _isLoading = false;
    });
  }

  Future<void> _loadScheduledSurveys(String puskesmasName) async {
    setState(() {
      _isLoading = true;
    });
    final dbHelper = DatabaseHelper();
    final surveys = await dbHelper.getScheduledSurveys();
    setState(() {
      _scheduledSurveys = surveys.where((survey) => survey['nama_puskesmas'] == puskesmasName).toList();
      _isLoading = false;
    });
  }

  Future<void> _scheduleNotification(DateTime scheduledDate) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your_channel_id', // id
            'your_channel_name', // name
            channelDescription: 'your_channel_description', // description
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Scheduled Survey',
        'You have a survey scheduled for ${scheduledDate.toLocal()}',
        scheduledDate,
        platformChannelSpecifics);
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
        return AlertDialog(
          title: Text('Enter Survey Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPuskesmas,
                items: _puskesmasNames.map((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPuskesmas = newValue;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Select Puskesmas",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedPuskesmas != null && _selectedTime != null) {
                  DateTime scheduledDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );
                  final dbHelper = DatabaseHelper();
                  await dbHelper.insertKegiatan({
                    'nama_puskesmas': _selectedPuskesmas,
                    'tanggal_kegiatan': scheduledDate.toIso8601String(),
                  });
                  await _scheduleNotification(scheduledDate);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Survey for $_selectedPuskesmas scheduled for $scheduledDate'),
                    ),
                  );
                  _timeController.clear();
                  _loadScheduledSurveys(_selectedPuskesmas!); // Reload the scheduled surveys
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select both Puskesmas and time.'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onPuskesmasSelected(String? puskesmasName) {
    if (puskesmasName != null) {
      _loadScheduledSurveys(puskesmasName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text("Select Puskesmas"),
                  value: _selectedPuskesmas,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPuskesmas = newValue;
                    });
                    _onPuskesmasSelected(newValue);
                  },
                  items: _puskesmasNames.map((String name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  isExpanded: true,
                ),
              ),
            ),
            SizedBox(height: 16),
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
                          child: ListTile(
                            title: Text(survey['nama_puskesmas']),
                            subtitle: Text(survey['tanggal_kegiatan']),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }
}
