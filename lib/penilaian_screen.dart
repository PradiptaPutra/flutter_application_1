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
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> existingEntries = [];

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    if (widget.kegiatanId != null) {
      _loadDataEntriesByKegiatan(widget.kegiatanId!);
    }
  }

  Future<void> _loadExcelData() async {
    List<Map<String, dynamic>> excelData = await _dbHelper.loadExcelDataDirectly('assets/form_penilaian.xlsx');
    setState(() {
      data = excelData;
      for (var i = 0; i < data.length; i++) {
        sebelumControllers.add(TextEditingController());
        sesudahControllers.add(TextEditingController());
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
              data[i]['entry_id'] = entry['entry_id'].toString();  // Ensure entry_id is stored as String
            }
          }
        }
      });
    }
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
        'id_category': widget.id_category, // Include id_category here
        'puskesmas': puskesmas, // Gunakan puskesmas yang didapat dari database
        'indikator': data[i]['nama_indikator'],
        'sub_indikator': data[i]['sub_indikator'],
        'kriteria': '', // Set according to your logic
        'sebelum': sebelumControllers[i].text,
        'sesudah': sesudahControllers[i].text,
        'keterangan': '', // Set according to your logic
      };

      if (data[i].containsKey('entry_id')) {
        entry['entry_id'] = int.parse(data[i]['entry_id']);  // Convert entry_id back to int
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penilaian'),
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
                                    data[index]["sub_indikator"] ?? '',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data[index]["nama_indikator"] ?? '',
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
                                        String rowData = await _dbHelper.loadRowData(3);
                                        _showPopup(context, rowData);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.help_outline,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () async {
                                        String rowData = await _dbHelper.loadRowData(4);
                                        _showPopup(context, rowData);
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
