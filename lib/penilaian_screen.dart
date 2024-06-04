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
  final List<Map<String, dynamic>> data = [
    {
      "title": "1.1 Tangga",
      "subtitle": "Dokter • 9 Tahun",
      "image": 'assets/images/logors.jpg',
      "hintTextSebelum": "Sebelum",
      "hintTextSesudah": "Sesudah"
    },
    {
      "title": "2.2 Sistem Sanitasi",
      "subtitle": "Sanitasi • 5 Tahun",
      "image": 'assets/images/logors.jpg',
      "hintTextSebelum": "Sebelum",
      "hintTextSesudah": "Sesudah"
    }
  ];

  @override
  void initState() {
    super.initState();
    print('Entry ID in PenilaianScreen: ${widget.entryId}'); // Print entryId to the console
    for (var i = 0; i < data.length; i++) {
      sebelumControllers.add(TextEditingController());
      sesudahControllers.add(TextEditingController());
    }
    if (widget.entryId != null) {
      _loadDataEntry(widget.entryId!);
    }
  }

  Future<void> _loadDataEntry(int entryId) async {
    List<Map<String, dynamic>> entries = await _dbHelper.getEntriesByEntryId(entryId);
    if (entries.isNotEmpty) {
      // Assuming the entry has 'sebelum' and 'sesudah' columns for each sub-indikator
      setState(() {
        for (var entry in entries) {
          for (var i = 0; i < data.length; i++) {
            if (entry['sub_indikator'] == data[i]['title']) {
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
        'sub_indikator': data[i]['title'],
        'kriteria': data[i]['subtitle'],
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
      body: Stack(
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
                            backgroundImage: AssetImage(data[index]["image"]!),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index]["title"]!,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(data[index]["subtitle"]!),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.help_outline),
                            onPressed: () {
                              // Handle help
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () {
                              // Handle view
                            },
                          ),
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
                                    hintText: data[index]["hintTextSebelum"]!,
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
                                    hintText: data[index]["hintTextSesudah"]!,
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
