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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final data = await _dbHelper.getUserData(widget.userId);
    setState(() {
      userData = data;
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
        title: Text('Profile'),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('User Profile', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  Text('Name: ${userData!['name'] ?? ''}', style: TextStyle(fontSize: 18)),
                  Text('Position: ${userData!['position'] ?? ''}', style: TextStyle(fontSize: 18)),
                  Text('Phone: ${userData!['phone'] ?? ''}', style: TextStyle(fontSize: 18)),
                  Text('Username: ${userData!['username'] ?? ''}', style: TextStyle(fontSize: 18)),
                  Text('Email: ${userData!['email'] ?? ''}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    child: Text('Edit Profile'),
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
