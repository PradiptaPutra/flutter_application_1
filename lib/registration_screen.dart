import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_helper.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final name = _nameController.text;
    final password = _passwordController.text;
    
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid email format'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!_isValidName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid name format'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (await _dbHelper.isUsernameExist(username)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Username already exists'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (await _dbHelper.isEmailExist(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email already exists'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final passwordHash = sha256.convert(utf8.encode(password)).toString();

    Map<String, dynamic> userData = {
      'username': username,
      'password_hash': passwordHash,
      'email': email,
      'name': name,
      'position': _positionController.text,
      'phone': _phoneController.text,
      'created_at': DateTime.now().toString(),
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

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  bool _isValidName(String name) {
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    return regex.hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sign up now',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please fill in the details to create an account',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Name',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _positionController,
                    hintText: 'Position',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Phone',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      obscureText: obscureText,
    );
  }
}
