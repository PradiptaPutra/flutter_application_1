import 'package:flutter/material.dart';

class LogregScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logokemenkes.png',
              width: 350, // lebar gambar
              height: 450, // tinggi gambar
              fit: BoxFit.contain, // memastikan keseluruhan gambar terlihat
            ),
            SizedBox(height: 20), // Spacing between image and button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');  // Navigate to the login route
              },
              child: Text('Masuk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(380, 50), // Size of button
              ),
            ),
            SizedBox(height: 10), // Spacing between buttons
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Navigate to the register route
              },
              child: Text('Daftar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue, // Text color
                side: BorderSide(color: Colors.blue, width: 2), // Border color and width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(380, 50), // Size of button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
