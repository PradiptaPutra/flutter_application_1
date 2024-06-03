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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _positionController = TextEditingController(text: widget.userData['position']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _usernameController = TextEditingController(text: widget.userData['username']);
  }

  void _updateProfile() async {
    Map<String, dynamic> updatedData = {
      'name': _nameController.text,
      'position': _positionController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'username': _usernameController.text,
    };

    try {
      await _dbHelper.updateUserProfile(widget.userId, updatedData);
      Navigator.pop(context, true); // Return true to indicate profile was updated
    } catch (e) {
      print('Update profile error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Update profile failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
