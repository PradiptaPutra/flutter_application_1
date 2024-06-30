import 'package:flutter/material.dart';

class LogregScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color.fromARGB(255, 255, 255, 255)], // Warna latar belakang yang lebih lembut
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
                    'assets/images/logoanapanca.png',
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
                      backgroundColor: Color.fromARGB(255, 49, 75, 243),
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
                      style: TextStyle(color: Color.fromARGB(255, 49, 75, 243)), // Mengganti warna teks menjadi oranye
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color.fromARGB(255, 49, 75, 243), width: 2), // Border color and width
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
