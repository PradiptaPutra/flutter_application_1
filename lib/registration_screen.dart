import 'package:flutter/material.dart';
import 'database_helper.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _register() async {
    Map<String, dynamic> userData = {
      'username': _usernameController.text,
      'password_hash': _passwordController.text, // Consider hashing the password
      'email': _emailController.text,
    };

    try {
      await _dbHelper.insertPengguna(userData);
      Navigator.pop(context); // Go back to the login screen or clear the form
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration successful'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(title: Text("Registration")),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding), // Adjust the padding to ensure visibility
        child: Padding(
          padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
               margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
               
            child: TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                ),
              filled: true,
              fillColor: Colors.white,
              ),
            ),
            ),
            Container(
               margin: EdgeInsets.only(bottom: 10.0),
            child :TextFormField(
              controller: _emailController,
             decoration: InputDecoration(
                labelText: 'Email',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                ),
              filled: true,
              fillColor: Colors.white,
              ),
            ),
            ),
            Container(
               margin: EdgeInsets.fromLTRB(0, 0, 0, 280),
            child :TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                ),
              filled: true,
              fillColor: Colors.white,
              ),
            ),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(380, 50),
                ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
