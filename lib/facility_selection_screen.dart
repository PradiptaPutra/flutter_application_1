import 'package:flutter/material.dart';

class FacilitySelectionScreen extends StatelessWidget {
  final int userId;

  FacilitySelectionScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Facility'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/data_entry', arguments: {'userId': userId});
              },
              child: Text('Bangunan'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to another screen
              },
              child: Text('Alat Kesehatan'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to another screen
              },
              child: Text('Kendaraan'),
            ),
          ],
        ),
      ),
    );
  }
}
