import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'database_helper.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late AnimationController _controller;
  late Animation<double> _animation;
  late String _verificationCode; // Kode verifikasi yang digenerate
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _generateVerificationCode(); // Panggil fungsi untuk generate kode verifikasi
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

  void _generateVerificationCode() {
    var random = Random();
    _verificationCode = (100000 + random.nextInt(900000)).toString(); // Generate 6-digit random code
  }

  void _sendVerificationEmail(String recipientEmail, String verificationCode, Map<String, dynamic> userData) async {
    _showLoadingDialog(); // Tampilkan loading overlay

    final smtpServer = gmail('mtsalikhlasberbahh@gmail.com', 'oxtm hpkh ciiq ppan');

    final message = Message()
      ..from = Address('anapanca@gmail.com', 'ANAPANCA VERIFICATION BOT')
      ..recipients.addAll(['alberdr19@gmail.com', 'andisubandi@unja.ac.id'])
      ..subject = 'Verification Code for Registration'
      ..text = '''
        Hello, Admin! .
        Someone signed up! let's do the verification
        Their verification code is: $verificationCode\n
        Here are their registration details:
        Username: ${userData['username']}
        Name: ${userData['name']}
        Email: ${userData['email']}
        Position: ${userData['position']}
        Phone: ${userData['phone']}
        Password: ${_passwordController.text}\n\n
        Thank you!
      ''';

    if (!_isValidEmail(recipientEmail)) {
      _hideLoadingDialog(); // Sembunyikan loading overlay
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid email format'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!_isValidName(userData['name'])) {
      _hideLoadingDialog(); // Sembunyikan loading overlay
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid name format'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (await _dbHelper.isUsernameExist(userData['username'])) {
      _hideLoadingDialog(); // Sembunyikan loading overlay
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Username already exists'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (await _dbHelper.isEmailExist(userData['email'])) {
      _hideLoadingDialog(); // Sembunyikan loading overlay
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email already exists'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        final sendReport = await send(message, smtpServer);
        print('Email sent successfully!');
        _register(userData); // Panggil fungsi _register setelah email terkirim
      } else {
        throw 'No internet connection';
      }
    } catch (e) {
      print('Error sending email: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send verification email. Check your internet connection.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      _hideLoadingDialog(); // Sembunyikan loading overlay
    }
  }

  void _register(Map<String, dynamic> userData) async {
    _showLoadingDialog(); // Tampilkan loading overlay
    final username = userData['username'];
    final email = userData['email'];
    final name = userData['name'];
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

    userData['password_hash'] = passwordHash;

    try {
      await _dbHelper.insertPengguna(userData);
      Navigator.pop(context);
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
    } finally {
      _hideLoadingDialog(); // Sembunyikan loading overlay setelah selesai
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

  void _showLoadingDialog() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingDialog() {
    setState(() {
      _loading = false;
    });
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
                    onPressed: () {
                      final username = _usernameController.text;
                      final email = _emailController.text;
                      final name = _nameController.text;
                      final position = _positionController.text;
                      final phone = _phoneController.text;

                      Map<String, dynamic> userData = {
                        'username': username,
                        'email': email,
                        'name': name,
                        'position': position,
                        'phone': phone,
                        'created_at': DateTime.now().toString(),
                        'kodeverif': _verificationCode,
                      };

                      _sendVerificationEmail(email, _verificationCode, userData);
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color.fromARGB(255, 49, 75, 243),
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
                            style: TextStyle(color: Color.fromARGB(255, 49, 75, 243)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_loading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
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
