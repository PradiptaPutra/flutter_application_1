import 'package:flutter/material.dart';

class LogregScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200], // Warna latar belakang yang lebih lembut
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logokemenkes.png',
                    width: 250, // lebar gambar
                    height: 250, // tinggi gambar
                    fit: BoxFit.contain, // memastikan keseluruhan gambar terlihat
                  ),
                  SizedBox(height: 40), // Spacing between image and button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');  // Navigate to the login route
                    },
                    child: Text(
                      'Masuk',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 10), // Spacing between buttons
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // Navigate to the register route
                    },
                    child: Text(
                      'Daftar',
                      style: TextStyle(color: Colors.orange),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange, width: 2), // Border color and width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(380, 50), // Size of button
                      backgroundColor: Colors.white,
                      elevation: 5,
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
}
