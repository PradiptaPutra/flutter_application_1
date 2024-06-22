import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'export_alkes_screen.dart';

class PenilaianAlkesScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;

  PenilaianAlkesScreen({this.kegiatanId, required this.id_category, required this.userId, this.entryId});

  @override
  _PenilaianAlkesScreenState createState() => _PenilaianAlkesScreenState();
}

class _PenilaianAlkesScreenState extends State<PenilaianAlkesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<TextEditingController> sebelumControllers = [];
  final List<TextEditingController> sesudahControllers = [];
  final List<TextEditingController> sebelum2Controllers = [];
  final List<TextEditingController> sesudah2Controllers = [];
  final List<TextEditingController> keteranganControllers = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> existingEntries = [];
  double totalSkorIndikator1Sebelum = 0;
  double totalSkorIndikator1Sesudah = 0;
  double totalSkorIndikator2Sebelum = 0;
  double totalSkorIndikator2Sesudah = 0;
  double totalSkorAkhir = 0;
  String interpretasiIndikator1Sebelum = "";
  String interpretasiIndikator1Sesudah = "";
  String interpretasiIndikator2Sebelum = "";
  String interpretasiIndikator2Sesudah = "";
  String interpretasiAkhir = "";
  String puskesmas = "";
  String kegiatanId = "";
  bool showInterpretations = true;
  bool isDataSaved = false;  // New boolean state to track if data is saved

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    if (widget.kegiatanId != null) {
      _loadDataEntriesByKegiatan(widget.kegiatanId!);
    }
  }

  Future<void> _loadExcelData() async {
    List<Map<String, dynamic>> excelData = await _dbHelper.loadExcelDataDirectly('assets/form_penilaian_alkes.xlsx');
    setState(() {
      data = excelData;
      for (var i = 0; i < data.length; i++) {
        sebelumControllers.add(TextEditingController());
        sesudahControllers.add(TextEditingController());
        sebelum2Controllers.add(TextEditingController());
        sesudah2Controllers.add(TextEditingController());
        keteranganControllers.add(TextEditingController());
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
              sebelum2Controllers[i].text = entry['sebelum2'] ?? '';
              sesudah2Controllers[i].text = entry['sesudah2'] ?? '';
              keteranganControllers[i].text = entry['keterangan'] ?? '';
              data[i]['entry_id'] = entry['entry_id'].toString();  // Ensure entry_id is stored as String
            }
          }
        }
        _calculateTotalScore(); // Hitung total skor saat data entry dimuat
      });
    }
  }

  void _calculateTotalScore() {
    double totalIndikator1Sebelum = 0;
    double totalIndikator1Sesudah = 0;
    double totalIndikator2Sebelum = 0;
    double totalIndikator2Sesudah = 0;

    for (var i = 0; i < sebelumControllers.length; i++) {
      totalIndikator1Sebelum += double.tryParse(sebelumControllers[i].text) ?? 0;
      totalIndikator1Sesudah += double.tryParse(sesudahControllers[i].text) ?? 0;
      totalIndikator2Sebelum += double.tryParse(sebelum2Controllers[i].text) ?? 0;
      totalIndikator2Sesudah += double.tryParse(sesudah2Controllers[i].text) ?? 0;
    }

    setState(() {
      totalSkorIndikator1Sebelum = totalIndikator1Sebelum * 4.35 / 2;
      interpretasiIndikator1Sebelum = _setInterpretasi(totalSkorIndikator1Sebelum);

      totalSkorIndikator1Sesudah = totalIndikator1Sesudah * 4.35 / 2;
      interpretasiIndikator1Sesudah = _setInterpretasi(totalSkorIndikator1Sesudah);

      totalSkorIndikator2Sebelum = totalIndikator2Sebelum * 5.9 / 2;
      interpretasiIndikator2Sebelum = _setInterpretasi(totalSkorIndikator2Sebelum);

      totalSkorIndikator2Sesudah = totalIndikator2Sesudah * 5.9 / 2;
      interpretasiIndikator2Sesudah = _setInterpretasi(totalSkorIndikator2Sesudah);

      totalSkorAkhir = (totalSkorIndikator1Sesudah * 0.5) + (totalSkorIndikator2Sesudah * 0.5);
      interpretasiAkhir = _setInterpretasi(totalSkorAkhir);
    });
  }

  String _setInterpretasi(double skor) {
    if (skor > 65) {
      return "Tinggi/Baik";
    } else if (skor >= 36 && skor <= 65) {
      return "Sedang/Cukup";
    } else {
      return "Rendah/Kurang";
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
    puskesmas = kegiatan.isNotEmpty ? kegiatan['nama_puskesmas'] : '';

    for (var i = 0; i < data.length; i++) {
      Map<String, dynamic> entry = {
        'user_id': widget.userId,
        'kegiatan_id': widget.kegiatanId,
        'id_category': widget.id_category,
        'puskesmas': puskesmas,
        'indikator': data[i]['nama_indikator'],
        'sub_indikator': data[i]['sub_indikator'],
        'sebelum': sebelumControllers[i].text,
        'sesudah': sesudahControllers[i].text,
        'sebelum2': sebelum2Controllers[i].text,
        'sesudah2': sesudah2Controllers[i].text,
        'keterangan': keteranganControllers[i].text,
      };

      if (data[i].containsKey('entry_id')) {
        entry['entry_id'] = int.parse(data[i]['entry_id']);
      }

      await _dbHelper.saveDataEntry(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
   setState(() {
      isDataSaved = true;  // Set the state to true after data is saved
    });
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PenilaianAlkesScreen(
        kegiatanId: widget.kegiatanId,
        id_category: widget.id_category,
        userId: widget.userId,
        entryId: widget.entryId,
      ),
    ),
  );
}
  

  Future<void> _exportData() async {
    // Dapatkan daftar kegiatan untuk user
    List<Map<String, dynamic>> kegiatanList = await _dbHelper.getKegiatanForUser(widget.userId);

    // Temukan kegiatan yang sesuai dengan kegiatanId yang diberikan
    Map<String, dynamic> kegiatan = kegiatanList.firstWhere(
      (kegiatan) => kegiatan['kegiatan_id'] == widget.kegiatanId,
      orElse: () => <String, dynamic>{},
    );

    // Ambil nilai nama_puskesmas dari kegiatan
    String puskesmas = kegiatan.isNotEmpty ? kegiatan['nama_puskesmas'] : '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportAlkesScreen(
          puskesmas: puskesmas,
          sebelumIndikator1: totalSkorIndikator1Sebelum,
          sesudahIndikator1: totalSkorIndikator1Sesudah,
          sebelumIndikator2: totalSkorIndikator2Sebelum,
          sesudahIndikator2: totalSkorIndikator2Sesudah,
          interpretasiIndikator1Sebelum: interpretasiIndikator1Sebelum,
          interpretasiIndikator1Sesudah: interpretasiIndikator1Sesudah,
          interpretasiIndikator2Sebelum: interpretasiIndikator2Sebelum,
          interpretasiIndikator2Sesudah: interpretasiIndikator2Sesudah,
          interpretasiAkhir: interpretasiAkhir,
          userId: widget.userId,
          kegiatanId: widget.kegiatanId, // Tambahkan kegiatanId di sini
        ),
      ),
    );
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
    for (var controller in sebelum2Controllers) {
      controller.dispose();
    }
    for (var controller in sesudah2Controllers) {
      controller.dispose();
    }
    for (var controller in keteranganControllers) {
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
          : Column(
              children: [
                if (totalSkorAkhir > 0) ...[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Card(
                          color: interpretasiAkhir == "Tinggi/Baik" ? Colors.green :
                                  interpretasiAkhir == "Sedang/Cukup" ? Colors.yellow :
                                  Colors.red,
                          child: ListTile(
                            title: Text(
                              'Interpretasi Akhir: $interpretasiAkhir',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (showInterpretations) ...[
                          Card(
                            color: interpretasiIndikator1Sebelum == "Tinggi/Baik" ? Colors.green :
                                    interpretasiIndikator1Sebelum == "Sedang/Cukup" ? Colors.yellow :
                                    Colors.red,
                            child: ListTile(
                              title: Text(
                                'Interpretasi Indikator 1 Sebelum: $interpretasiIndikator1Sebelum',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Card(
                            color: interpretasiIndikator1Sesudah == "Tinggi/Baik" ? Colors.green :
                                    interpretasiIndikator1Sesudah == "Sedang/Cukup" ? Colors.yellow :
                                    Colors.red,
                            child: ListTile(
                              title: Text(
                                'Interpretasi Indikator 1 Sesudah: $interpretasiIndikator1Sesudah',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Card(
                            color: interpretasiIndikator2Sebelum == "Tinggi/Baik" ? Colors.green :
                                    interpretasiIndikator2Sebelum == "Sedang/Cukup" ? Colors.yellow :
                                    Colors.red,
                            child: ListTile(
                              title: Text(
                                'Interpretasi Indikator 2 Sebelum: $interpretasiIndikator2Sebelum',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Card(
                            color: interpretasiIndikator2Sesudah == "Tinggi/Baik" ? Colors.green :
                                    interpretasiIndikator2Sesudah == "Sedang/Cukup" ? Colors.yellow :
                                    Colors.red,
                            child: ListTile(
                              title: Text(
                                'Interpretasi Indikator 2 Sesudah: $interpretasiIndikator2Sesudah',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showInterpretations = !showInterpretations;
                            });
                          },
                          child: Text(showInterpretations ? 'Hide Interpretations' : 'Show Interpretations'),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
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
                                              _showPopup(context, data[index]["kriteria"] ?? '');
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.help_outline,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () async {
                                              _showPopup(context, data[index]["keterangan"] ?? '');
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
                                        labelText: 'Indikator 1 Sebelum',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onChanged: (value) => _calculateTotalScore(),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: sesudahControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Indikator 1 Sesudah',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onChanged: (value) => _calculateTotalScore(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: sebelum2Controllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Indikator 2 Sebelum',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: sesudah2Controllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Indikator 2 Sesudah',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
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
                ),
              ],
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: _saveDataEntry,
            label: Text('Save'),
            icon: Icon(Icons.save),
            backgroundColor: Colors.blue,
          ),
          SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: _exportData,
            label: Text('Export'),
            icon: Icon(Icons.import_export),
            backgroundColor: Colors.green,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
