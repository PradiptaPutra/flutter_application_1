import 'package:flutter/material.dart';
import 'package:flutter_application_1/puskesmas_screen.dart';
import 'home_content.dart';
import 'profile_screen.dart';
import 'database_helper.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  DashboardScreen({required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getUserData(widget.userId);
    setState(() {
      userName = data?['name'] ?? "User";
    });
  }

  static List<Widget> _widgetOptions(int userId) => <Widget>[
    HomeContent(),
    PuskesmasScreen(userId: userId),
    ProfileScreen(userId: userId),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: false, // Menambahkan baris ini
        title: Row(
          children: [
            Text(
              'Halo, ',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Icon(Icons.notifications),
            SizedBox(width: 10),
            Icon(Icons.person),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions(widget.userId),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Lakukan Penilaian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
