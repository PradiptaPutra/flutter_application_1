import 'package:flutter/material.dart';
import 'database_helper.dart';

class HomeContent extends StatefulWidget {
  final int userId;

  HomeContent({required this.userId});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _puskesmasList = [];

  @override
  void initState() {
    super.initState();
    _loadPuskesmasData();
  }

  Future<void> _loadPuskesmasData() async {
    List<Map<String, dynamic>> puskesmasData = await _dbHelper.getDataEntriesForUser(widget.userId);
    setState(() {
      _puskesmasList = puskesmasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Survei Puskesmas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Ayo Kerja!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (_puskesmasList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Belum ada puskesmas yang diinput. Slide untuk melihat info.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          if (_puskesmasList.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: _puskesmasList.map((puskesmas) {
                  return Container(
                    width: 300,
                    margin: EdgeInsets.only(right: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.asset(
                              'assets/images/logors.jpg', // Use actual path to the puskesmas image
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  puskesmas['nama_puskesmas'] ?? '',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  puskesmas['alamat'] ?? '',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.orange, size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      '4.7', // This is a placeholder rating, replace with actual data if available
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
