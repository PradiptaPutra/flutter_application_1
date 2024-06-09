import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'category_selection_screen.dart'; // Make sure this import matches the location of your screen

class HomeContent extends StatefulWidget {
  final int userId;

  HomeContent({required this.userId});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _puskesmasList = [];
  Map<int, double> _progressMap = {};

  @override
  void initState() {
    super.initState();
    _loadPuskesmasData();
  }

  Future<void> _loadPuskesmasData() async {
    List<Map<String, dynamic>> puskesmasData = await _dbHelper.getDataEntriesForUserHome(widget.userId);
    for (var puskesmas in puskesmasData) {
      double progress = await _dbHelper.getProgressForKegiatan(puskesmas['kegiatan_id']);
      _progressMap[puskesmas['kegiatan_id']] = progress;
    }
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
                  double progress = _progressMap[puskesmas['kegiatan_id']] ?? 0.0;
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
                          );
                        },
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
                                    puskesmas['nama_puskesmas']?.isEmpty ?? true
                                        ? 'Nama Puskesmas tidak ada'
                                        : puskesmas['nama_puskesmas'],
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    puskesmas['dropdown_option'] ?? 'Tidak Tersedia Informasi',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  SizedBox(height: 5),
                                  LinearProgressIndicator(
                                    value: progress / 100,
                                    backgroundColor: Colors.grey[200],
                                    color: Color(0xFFFF7043),
                                  ),
                                  SizedBox(height: 5),
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
  }
}
