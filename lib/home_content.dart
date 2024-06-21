import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'category_selection_screen.dart';

class HomeContent extends StatefulWidget {
  final int userId;

  HomeContent({required this.userId});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> _loadPuskesmasData() async {
    List<Map<String, dynamic>> puskesmasData = await _dbHelper.getDataEntriesForUserHome(widget.userId);
    Map<int, double> progressMap = {};

    for (var puskesmas in puskesmasData) {
      double progress = await _dbHelper.getProgressForKegiatan(puskesmas['kegiatan_id']);
      progressMap[puskesmas['kegiatan_id']] = progress;
    }

    // Create a modifiable copy of puskesmasData and add progress data
    List<Map<String, dynamic>> modifiablePuskesmasData = puskesmasData.map((puskesmas) {
      return Map<String, dynamic>.from(puskesmas);
    }).toList();

    for (var puskesmas in modifiablePuskesmasData) {
      puskesmas['progress'] = progressMap[puskesmas['kegiatan_id']] ?? 0.0;
    }

    return modifiablePuskesmasData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadPuskesmasData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Belum ada puskesmas yang diinput. Slide untuk melihat info.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        List<Map<String, dynamic>> _puskesmasList = snapshot.data!;
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: _puskesmasList.map((puskesmas) {
                    double progress = puskesmas['progress'];
                    return Container(
                      width: 300,
                      margin: EdgeInsets.only(right: 16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategorySelectionScreen(
                                  userId: widget.userId,
                                  kegiatanId: puskesmas['kegiatan_id'],
                                ),
                              ),
                            ).then((value) {
                              setState(() {}); // Refresh the screen when returning
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.asset(
                                  'assets/images/logors.jpg', // Use actual path to the puskesmas image
                                  height: 150,
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
                                      puskesmas['nama_puskesmas']?.isEmpty ?? true
                                          ? 'Nama Puskesmas tidak ada'
                                          : puskesmas['nama_puskesmas'],
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Divider(),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.grey),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            puskesmas['provinsi'] ?? 'Provinsi tidak tersedia',
                                            style: TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.location_city, color: Colors.grey),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            puskesmas['kabupaten_kota'] ?? 'Kabupaten/Kota tidak tersedia',
                                            style: TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Divider(),
                                    SizedBox(height: 8),
                                    Text(
                                      puskesmas['dropdown_option'] ?? 'Tidak Tersedia Informasi',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey[200],
                                      color: Color(0xFFFF7043),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Progress Survei: ${progress.toStringAsFixed(2)}%',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
