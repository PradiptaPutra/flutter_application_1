import 'package:flutter/material.dart';
import 'database_helper.dart';

class PenilaianScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;

  PenilaianScreen({this.kegiatanId, required this.id_category, required this.userId, this.entryId});

  @override
  _PenilaianScreenState createState() => _PenilaianScreenState();
}

class _PenilaianScreenState extends State<PenilaianScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<TextEditingController> sebelumControllers = [];
  final List<TextEditingController> sesudahControllers = [];
  final List<TextEditingController> keteranganControllers = []; // Tambahkan controller untuk keterangan
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> existingEntries = [];
  double totalSkor = 0;

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    if (widget.kegiatanId != null) {
      _loadDataEntriesByKegiatan(widget.kegiatanId!);
    }
  }

  Future<void> _loadExcelData() async {
    List<Map<String, dynamic>> excelData = await _dbHelper.loadExcelDataDirectly('assets/form_penilaian_bangunan.xlsx');
    setState(() {
      data = excelData;
      for (var i = 0; i < data.length; i++) {
        sebelumControllers.add(TextEditingController());
        sesudahControllers.add(TextEditingController());
        keteranganControllers.add(TextEditingController()); // Tambahkan controller untuk setiap item
      }
    });
  }

  Future<void> _loadDataEntriesByKegiatan(int kegiatanId) async {
    List<Map<String, dynamic>> entries = await _dbHelper.getEntriesByKegiatanId(kegiatanId);
    if (entries.isNotEmpty) {
      setState(() {
        existingEntries = entries;
        for (var entry in entries) {
          for (var i = 0; i < data.length; i++) {
            if (entry['sub_indikator'] == data[i]['sub_indikator']) {
              sebelumControllers[i].text = entry['sebelum'] ?? '';
              sesudahControllers[i].text = entry['sesudah'] ?? '';
              keteranganControllers[i].text = entry['keterangan'] ?? ''; // Set text untuk keterangan
              data[i]['entry_id'] = entry['entry_id'].toString();  // Ensure entry_id is stored as String
            }
          }
        }
        _calculateTotalScore(); // Hitung total skor saat data entry dimuat
      });
    }
  }

  void _calculateTotalScore() {
    bool allSesudahFilled = true;
    double total = 0;
    for (var controller in sesudahControllers) {
      if (controller.text.isEmpty) {
        allSesudahFilled = false;
        break;
      } else {
        total += double.tryParse(controller.text) ?? 0;
      }
    }
    setState(() {
      if (allSesudahFilled) {
        totalSkor = total * 4.15;
      } else {
        totalSkor = 0;
      }
    });
  }

  Future<void> _saveDataEntry() async {
    // Dapatkan daftar kegiatan untuk user
    List<Map<String, dynamic>> kegiatanList = await _dbHelper.getKegiatanForUser(widget.userId);

    // Temukan kegiatan yang sesuai dengan kegiatanId yang diberikan
    Map<String, dynamic> kegiatan = kegiatanList.firstWhere(
      (kegiatan) => kegiatan['kegiatan_id'] == widget.kegiatanId,
      orElse: () => <String, dynamic>{},
    );

    // Ambil nilai nama_puskesmas dari kegiatan
    String puskesmas = kegiatan.isNotEmpty ? kegiatan['nama_puskesmas'] : '';

    for (var i = 0; i < data.length; i++) {
      Map<String, dynamic> entry = {
        'user_id': widget.userId,
        'kegiatan_id': widget.kegiatanId,
        'id_category': widget.id_category,
        'puskesmas': puskesmas,
        'indikator': data[i]['nama_indikator'],
        'sub_indikator': data[i]['sub_indikator'],
        'kriteria': '',
        'sebelum': sebelumControllers[i].text,
        'sesudah': sesudahControllers[i].text,
        'keterangan': keteranganControllers[i].text, // Simpan keterangan
      };

      if (data[i].containsKey('entry_id')) {
        entry['entry_id'] = int.parse(data[i]['entry_id']);
      }

      await _dbHelper.saveDataEntry(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
    Navigator.pop(context);
  }

  void _showPopup(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Informasi"),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in sebelumControllers) {
      controller.dispose();
    }
    for (var controller in sesudahControllers) {
      controller.dispose();
    }
    for (var controller in keteranganControllers) { // Dispose keterangan controllers
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Penilaian'),
            SizedBox(width: 10),
            if (totalSkor > 0) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 11, vertical: 5), // Sesuaikan padding
                margin: EdgeInsets.fromLTRB(70, 0, 0, 0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 144, 190, 228),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Score: ${totalSkor.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14), // Sesuaikan fontSize
                ),
              ),
            ],
          ],
        ),
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/logors.jpg', // Ganti dengan path gambar Anda
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data[index]["nama_indikator"] ?? '',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data[index]["sub_indikator"] ?? '',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.visibility,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        _showPopup(context, data[index]["keterangan"] ?? '');
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.help_outline,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () async {
                                        _showPopup(context, data[index]["kriteria"] ?? '');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sebelumControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Sebelum',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: sesudahControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Sesudah',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10), // Tambahkan spacing
                        TextField(
                          controller: keteranganControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Keterangan',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveDataEntry,
        child: Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
