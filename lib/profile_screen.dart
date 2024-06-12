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

  Future<Map<String, dynamic>> _loadUserData() async {
    final data = await _dbHelper.getUserData(widget.userId);
    final count = await _dbHelper.getPuskesmasSurveyedCount(widget.userId);

    // Create a modifiable copy of the data map
    final Map<String, dynamic> mutableData = Map<String, dynamic>.from(data ?? {});
    mutableData['puskesmasCount'] = count;

    return mutableData;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacementNamed(context, '/logreg');
  }

  void _navigateToEditProfile(Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: widget.userId, userData: userData),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {}); // Refresh the screen when returning
      }
    });
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available.'));
          }

          final userData = snapshot.data!;
          final puskesmasCount = userData['puskesmasCount'];

          return SingleChildScrollView(
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
                        userData['name'] ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userData['email'] ?? '',
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
                  _buildMenuItem(Icons.person_outline, 'Profile', () => _navigateToEditProfile(userData)),
                  _buildMenuItem(Icons.exit_to_app, 'Logout', _logout),
                ]),
              ],
            ),
          );
        },
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
