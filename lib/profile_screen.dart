import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? userData;
  int puskesmasCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPuskesmasCount();
  }

  void _loadUserData() async {
    final data = await _dbHelper.getUserData(widget.userId);
    setState(() {
      userData = data;
    });
  }

  void _loadPuskesmasCount() async {
    final count = await _dbHelper.getPuskesmasSurveyedCount(widget.userId);
    print('Puskesmas surveyed count: $count');
    setState(() {
      puskesmasCount = count;
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: widget.userId, userData: userData!),
      ),
    ).then((value) {
      if (value == true) {
        _loadUserData();
        _loadPuskesmasCount(); // Reload count after profile update
      }
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacementNamed(context, '/logreg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile'),
        backgroundColor: Color(0xFFF9D5A7), // Light peach color
        elevation: 0, // No shadow for the AppBar
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Color(0xFFF9D5A7), // Light peach color
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/logors.jpg'), // Replace with the actual image
                        ),
                        SizedBox(height: 10),
                        Text(
                          userData!['name'] ?? '',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userData!['email'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoCard('Jumlah Puskesmas Di Survei', puskesmasCount.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildMenuSection('Profile', [
                    _buildMenuItem(Icons.person_outline, 'Profile', _navigateToEditProfile),
                    _buildMenuItem(Icons.exit_to_app, 'Logout', _logout),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF7043),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
