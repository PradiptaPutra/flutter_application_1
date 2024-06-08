import 'package:flutter/material.dart';
import 'home_content.dart';
import 'package:flutter_application_1/puskesmas_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'calender_screen.dart';
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

  List<Widget> _widgetOptions(int userId) => <Widget>[
    HomeContent(userId: userId),
    PuskesmasScreen(userId: userId),
    CalendarScreen(),
    HistoryScreen(userId: userId),
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'Halo, ',
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
            ),
            Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                // Handle notification icon press
              },
            ),
            SizedBox(width: 10),
            CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage('assets/images/logors.jpg'), // Use the actual path to the profile image
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions(widget.userId),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 10.0,
        child: Container(
          height: 70.0,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(0, -5),
              ),
            ],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildTabItem(
                index: 0,
                icon: Icons.home,
                label: 'Home',
              ),
              buildTabItem(
                index: 2,
                icon: Icons.calendar_today,
                label: 'Calendar',
              ),
              SizedBox(width: 48.0), // The dummy child for the floating button in the middle
              buildTabItem(
                index: 3,
                icon: Icons.history,
                label: 'History',
              ),
              buildTabItem(
                index: 4,
                icon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Container(
          width: 70.0,
          height: 70.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Assuming the note function is the second in the IndexedStack
                  });
                },
                child: Icon(Icons.add_task, color: Colors.white),
                backgroundColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
