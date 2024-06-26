import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'category_selection_screen.dart';
import 'dart:io';

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
  Map<int, String> tanggalKegiatanMap = {};
  Map<int, List<int>> missingCategoriesMap = {};

  List<int> requiredCategories = [11, 12, 13, 21, 22, 23, 3, 4];

  for (var puskesmas in puskesmasData) {
  double progress = await _dbHelper.getProgressForKegiatan(puskesmas['kegiatan_id']) ?? 0.0;
  progressMap[puskesmas['kegiatan_id']] = progress;

  String tanggalKegiatan = await _dbHelper.getTanggalKegiatan(puskesmas['kegiatan_id']) ?? 'Tidak ada tanggal';
  tanggalKegiatanMap[puskesmas['kegiatan_id']] = tanggalKegiatan;

   List<int> completedCategories = await _dbHelper.getCompletedCategoriesForKegiatan(puskesmas['kegiatan_id'], requiredCategories) ?? [];
      List<int> missingCategories = requiredCategories.where((category) => !completedCategories.contains(category)).toList();
      missingCategoriesMap[puskesmas['kegiatan_id']] = missingCategories;

  // Debug print to see completedCategories
  print('Completed Categories for Puskesmas ${puskesmas['nama_puskesmas']}: $completedCategories');

  // Debug print to see missingCategories
  print('Missing Categories for Puskesmas ${puskesmas['nama_puskesmas']}: $missingCategories');
}
  
  List<Map<String, dynamic>> modifiablePuskesmasData = puskesmasData.map((puskesmas) {
    return Map<String, dynamic>.from(puskesmas);
    
  }).toList();

  for (var puskesmas in modifiablePuskesmasData) {
    
    puskesmas['progress'] = progressMap[puskesmas['kegiatan_id']] ?? 0.0;
    puskesmas['tanggal_kegiatan'] = tanggalKegiatanMap[puskesmas['kegiatan_id']] ?? 'Tidak ada tanggal';
    puskesmas['missing_categories'] = missingCategoriesMap[puskesmas['kegiatan_id']] ?? [];
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
              'Belum ada puskesmas yang diinput. Buat Survei baru!',
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: _puskesmasList.map((puskesmas) {
                    double progress = puskesmas['progress'];
                    String tanggalKegiatan = puskesmas['tanggal_kegiatan'];
                    List<int> missingCategories = puskesmas['missing_categories'];
                    String fotoPath = puskesmas['foto'] != null && puskesmas['foto'].isNotEmpty
                        ? '/storage/emulated/0/Download/fotopuskesmas/${puskesmas['foto']}'
                        : 'assets/images/logors.jpg';
                  // Debug print to see missingCategories map
                  
                  print('Missing Categories for Puskesmas ${puskesmas['nama_puskesmas']}: $missingCategories');
                  print('FOTO ${puskesmas['nama_puskesmas']}: $fotoPath');

                  bool allSurveysCompleted = missingCategories.isEmpty;

                  return Container(
                    width: 310,
                    height: 440,
                    margin: EdgeInsets.only(right: 10.0),
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
                                child: fotoPath.startsWith('assets')
                                    ? Image.asset(
                                        fotoPath,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(fotoPath),
                                        height: 120,
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
                                  Text(
                                    'Tanggal Survei: $tanggalKegiatan',
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
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        allSurveysCompleted
                                            ? 'Status: \n Sudah Menyelesaikan Semua Survei'
                                            : 'Status: \n Belum Menyelesaikan Semua Survei',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: allSurveysCompleted ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      if (!allSurveysCompleted)
                                        IconButton(
                                          icon: Icon(Icons.help_outline, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Survei Belum Selesai'),
                                                  content: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: missingCategories.map((category) {
                                                        String categoryName;
                                                        switch (category) {
                                                          case 11:
                                                            categoryName = 'FPK_Bangunan';
                                                            break;
                                                          case 12:
                                                            categoryName = 'FPK_Alat Kesehatan';
                                                            break;
                                                          case 13:
                                                            categoryName = 'FPK_Kendaraan';
                                                            break;
                                                          case 21:
                                                            categoryName = 'SDM_Jumlah Sumber daya manusia';
                                                            break;
                                                          case 22:
                                                            categoryName = 'SDM_Jumlah Ketenagaan';
                                                            break;
                                                          case 23:
                                                            categoryName = 'SDM_Dara Kehadiran Tenaga Kesehatan';
                                                            break;
                                                          case 3:
                                                            categoryName = 'Program Kesehatan';
                                                            break;
                                                          case 4:
                                                            categoryName = 'Pembiayaan Kesehatan';
                                                            break;
                                                          default:
                                                            categoryName = 'Kategori tidak diketahui';
                                                        }
                                                        return ListTile(
                                                          title: Text(categoryName),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child: Text('Tutup'),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                    ],
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
