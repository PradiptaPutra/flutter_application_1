import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatelessWidget {
  final int userId;

  CategorySelectionScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/facility_selection', arguments: {'userId': userId});
              },
              child: Text('Fasilitas Pelayanan Kesehatan'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to another screen
              },
              child: Text('SDM Kesehatan'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to another screen
              },
              child: Text('Program Kesehatan'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to another screen
              },
              child: Text('Pembiayaan Kesehatan'),
            ),
          ],
        ),
      ),
    );
  }
}
