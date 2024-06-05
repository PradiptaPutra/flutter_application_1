import 'package:flutter/material.dart';
import 'database_helper.dart';

class PenilaianScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_indikator;
  final int userId;
  final int? entryId; // Tambahkan entryId sebagai parameter nullable

  PenilaianScreen({this.kegiatanId, required this.id_indikator, required this.userId, this.entryId});

  @override
  _PenilaianScreenState createState() => _PenilaianScreenState();
}

class _PenilaianScreenState extends State<PenilaianScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<TextEditingController> sebelumControllers = [];
  final List<TextEditingController> sesudahControllers = [];
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    print('Entry ID in PenilaianScreen: ${widget.entryId}'); // Print entryId to the console
    _loadExcelData();
    if (widget.entryId != null) {
      _loadDataEntry(widget.entryId!);
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

  Future<void> _loadDataEntry(int entryId) async {
    List<Map<String, dynamic>> entries = await _dbHelper.getEntriesByEntryId(entryId);
    if (entries.isNotEmpty) {
      setState(() {
        for (var entry in entries) {
          for (var i = 0; i < data.length; i++) {
            if (entry['sub_indikator'] == data[i]['sub_indikator']) {
              sebelumControllers[i].text = entry['sebelum'] ?? '';
              sesudahControllers[i].text = entry['sesudah'] ?? '';
            }
          }
        }
      });
    }
  }

  Future<void> _saveDataEntry() async {
    // Get nama_puskesmas from Kegiatan table
    List<Map<String, dynamic>> kegiatanResult = await _dbHelper.getKegiatanForUser(widget.userId);

    String namaPuskesmas = '';
    if (kegiatanResult.isNotEmpty) {
      var kegiatan = kegiatanResult.firstWhere((k) => k['kegiatan_id'] == widget.kegiatanId, orElse: () => {});
      if (kegiatan.isNotEmpty) {
        namaPuskesmas = kegiatan['nama_puskesmas'] ?? '';
      }
    }

    // Get nama_indikator from Indikator table
    List<Map<String, dynamic>> indikatorResult = await _dbHelper.getIndikators();
    String namaIndikator = '';
    if (indikatorResult.isNotEmpty) {
      var indikator = indikatorResult.firstWhere((i) => i['id_indikator'] == widget.id_indikator, orElse: () => {});
      if (indikator.isNotEmpty) {
        namaIndikator = indikator['nama_indikator'] ?? '';
      }
    }

    for (var i = 0; i < data.length; i++) {
      Map<String, dynamic> entry = {
        'user_id': widget.userId,
        'kegiatan_id': widget.kegiatanId,
        'puskesmas': namaPuskesmas,
        'indikator': namaIndikator,
        'sub_indikator': data[i]['sub_indikator'],
        'kriteria': '',
        'sebelum': sebelumControllers[i].text,
        'sesudah': sesudahControllers[i].text,
        'keterangan': '',
      };

      if (widget.entryId != null) {
        // Update existing entry
        entry['entry_id'] = widget.entryId;
      }
      
      await _dbHelper.saveDataEntry(entry);
    }

    // Show confirmation and navigate back
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
    Navigator.pop(context);
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
          : Stack(
              children: [
                ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(10),
                      color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/images/logors.jpg'),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data[index]["nama_indikator"] ?? '',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(data[index]["sub_indikator"] ?? ''),
                                  ],
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: sebelumControllers[index],
                                        decoration: InputDecoration(
                                          hintText: 'Sebelum',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: sesudahControllers[index],
                                        decoration: InputDecoration(
                                          hintText: 'Sesudah',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        ),
                                      ),
                                    ],
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
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _saveDataEntry,
                    child: Text('SIMPAN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(380, 50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
