import 'package:flutter/material.dart';
import 'package:flutter_application_1/puskesmas_screen.dart';
import 'home_content.dart';
import 'profile_screen.dart';
import 'history_screen.dart';  // Import the history screen
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
    HistoryScreen(userId: userId),  // Assuming you have a HistoryScreen
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
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Handle notification icon press
              },
            ),
            SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: AssetImage('assets/profile_image.png'), // Use the actual path to the profile image
              radius: 15,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions(widget.userId),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildTabItem(
                index: 0,
                icon: Icons.home,
                label: 'Home',
              ),
              buildTabItem(
                index: 8,
                icon: Icons.calendar_today,
                label: 'Calendar',
              ),
              SizedBox(width: 48.0), // The dummy child for the floating button in the middle
              buildTabItem(
                index: 2,
                icon: Icons.message,
                label: 'History',
              ),
              buildTabItem(
                index: 3,
                icon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 40.0), 
        child: Container(// Adjust this value to lower the position
        width: 70.0, // Adjust the width as needed
          height: 70.0, // Adjust the height as needed
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 1; // Assuming the note function is the third in the IndexedStack
            });
          },
          child: Icon(Icons.note_add_outlined),
          backgroundColor: Colors.blue,
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
            color: _selectedIndex == index ? Colors.blue : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
