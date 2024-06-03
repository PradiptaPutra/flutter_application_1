import 'package:flutter/material.dart';

class PuskesmasScreen extends StatelessWidget {
  final int userId;

  PuskesmasScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/category_selection', arguments: {'userId': userId});
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/logopuskesmas.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('Puskesmas'),
            ],
          ),
        ),
      ),
    );
  }
}
