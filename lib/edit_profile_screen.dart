import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userId, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'] ?? '';
    _positionController.text = widget.userData['position'] ?? '';
    _phoneController.text = widget.userData['phone'] ?? '';
    _usernameController.text = widget.userData['username'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
  }

  void _saveProfile() async {
    Map<String, dynamic> updatedData = {
      'user_id': widget.userId,
      'name': _nameController.text,
      'position': _positionController.text,
      'phone': _phoneController.text,
      'username': _usernameController.text,
      'email': _emailController.text,
    };

    await _dbHelper.updateUserData(updatedData);
    Navigator.pop(context, true); // Return true to indicate successful update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(380, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
