import 'package:flutter/material.dart';
import 'package:flutter_application_1/puskesmas_screen.dart';
import 'home_content.dart';
import 'profile_screen.dart'; // Import ProfileScreen
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

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    PuskesmasScreen(),
    ProfileScreen(userId: 1), // Placeholder userId, replace in build method
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
        children: [
          HomeContent(),
          PuskesmasScreen(),
          ProfileScreen(userId: widget.userId), // Pass the actual userId here
        ],
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