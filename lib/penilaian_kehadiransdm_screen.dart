import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'export_kehadiransdm_screen.dart';

class PenilaianKehadiransdmScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;

  PenilaianKehadiransdmScreen({this.kegiatanId, required this.id_category, required this.userId, this.entryId});

  @override
  _PenilaianKehadiransdmScreenState createState() => _PenilaianKehadiransdmScreenState();
}

class _PenilaianKehadiransdmScreenState extends State<PenilaianKehadiransdmScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<TextEditingController> sebelumControllers = [];
  final List<TextEditingController> sesudahControllers = [];
  final List<TextEditingController> skorControllers = []; // New controller for Skor
  final List<TextEditingController> keteranganControllers = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> existingEntries = [];
  double totalSkorSebelum = 0;
  double totalSkorSesudah = 0;
  String interpretasiSebelum = "";
  String interpretasiSesudah = "";
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
    List<Map<String, dynamic>> excelData = await _dbHelper.loadExcelDataDirectly('assets/form_penilaian_kehadiransdm.xlsx');
    setState(() {
      data = excelData;
      for (var i = 0; i < data.length; i++) {
        sebelumControllers.add(TextEditingController());
        sesudahControllers.add(TextEditingController());
        skorControllers.add(TextEditingController()); // Initialize skorControllers
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
            if (entry['indikator'] == data[i]['nama_indikator']) {
              sebelumControllers[i].text = entry['sebelum'] ?? '';
              sesudahControllers[i].text = entry['sesudah'] ?? '';
              keteranganControllers[i].text = entry['keterangan'] ?? '';
              data[i]['entry_id'] = entry['entry_id'].toString();  // Ensure entry_id is stored as String
            }
          }
        }
        _calculateTotalScore(); // Hitung total skor saat data entry dimuat
      });
    }
  }

 Future<void> _calculateTotalScore() async {
    double totalSebelum = 0;
    double totalSesudah = 0;

    for (var i = 0; i < sebelumControllers.length; i++) {
      double sebelumValue = double.tryParse(sebelumControllers[i].text) ?? 0;
      double sesudahValue = double.tryParse(sesudahControllers[i].text) ?? 0;

      // Ambil nilai SDH dari database
      double? sdhValue = await _dbHelper.getSdhValue(widget.kegiatanId, 22, data[i]['nama_indikator']);
      print("SDH Value for indikator ${data[i]['nama_indikator']}: $sdhValue");

      if (sdhValue != null && sdhValue != 0) {
        // Menghitung persentase skor
        int persentaseSkor = ((sesudahValue * 100) / sdhValue).round();
        int skorValue;

        // Tentukan nilai skor berdasarkan persentase
        if (persentaseSkor > 80) {
          skorValue = 2;
        } else if (persentaseSkor >= 50 && persentaseSkor <= 80) {
          skorValue = 1;
        } else {
          skorValue = 0;
        }

        skorControllers[i].text = skorValue.toString();
      } else {
        skorControllers[i].text = "0";
      }

      totalSebelum += sebelumValue;
      totalSesudah += sesudahValue;
    }

    setState(() {
      totalSkorSebelum = totalSebelum * 4.15;
      interpretasiSebelum = _setInterpretasi(totalSkorSebelum);

      totalSkorSesudah = totalSesudah * 4.15;
      interpretasiSesudah = _setInterpretasi(totalSkorSesudah);
    });
}




  String _setInterpretasi(double skor) {
    if (skor > 65) {
      return "Tinggi/Aman";
    } else if (skor >= 36 && skor <= 65) {
      return "Sedang/Kurang Aman";
    } else {
      return "Rendah/Tidak Aman";
    }
  }

  Future<void> _saveDataEntry() async {
    List<Map<String, dynamic>> kegiatanList = await _dbHelper.getKegiatanForUser(widget.userId);

    Map<String, dynamic> kegiatan = kegiatanList.firstWhere(
      (kegiatan) => kegiatan['kegiatan_id'] == widget.kegiatanId,
      orElse: () => <String, dynamic>{},
    );

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
        'keterangan': keteranganControllers[i].text,
      };

      // Check if the entry already exists
      List<Map<String, dynamic>> existingEntry = await _dbHelper.getEntriesByKegiatanIdAndIndikator(
        widget.kegiatanId!,
        widget.id_category,
        data[i]['nama_indikator'],
      );

      if (existingEntry.isNotEmpty) {
        // If entry exists, update it
        entry['entry_id'] = existingEntry[0]['entry_id'];
        await _dbHelper.updateDataEntry3(entry);
      } else {
        // If entry does not exist, insert a new one
        await _dbHelper.saveDataEntry(entry);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));

    setState(() {
      isDataSaved = true;  // Set the state to true after data is saved
    });
     Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PenilaianKehadiransdmScreen(
        kegiatanId: widget.kegiatanId,
        id_category: widget.id_category,
        userId: widget.userId,
        entryId: widget.entryId,
      ),
    ),
  );
}


  Future<void> _exportData() async {
    List<Map<String, dynamic>> kegiatanList = await _dbHelper.getKegiatanForUser(widget.userId);

    Map<String, dynamic> kegiatan = kegiatanList.firstWhere(
      (kegiatan) => kegiatan['kegiatan_id'] == widget.kegiatanId,
      orElse: () => <String, dynamic>{},
    );

    String puskesmas = kegiatan.isNotEmpty ? kegiatan['nama_puskesmas'] : '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportKehadiransdmScreen(
          puskesmas: puskesmas,
          sebelum: totalSkorSebelum.toInt(),
          sesudah: totalSkorSesudah.toInt(),
          interpretasiSebelum: interpretasiSebelum,
          interpretasiSesudah: interpretasiSesudah,
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
    for (var controller in skorControllers) {
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
                if (totalSkorSebelum > 0 || totalSkorSesudah > 0) ...[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        if (showInterpretations) ...[
                          if (totalSkorSebelum > 0) ...[
                            Card(
                              color: interpretasiSebelum == "Tinggi/Aman"
                                  ? Colors.green
                                  : interpretasiSebelum == "Sedang/Kurang Aman"
                                      ? Colors.yellow
                                      : Colors.red,
                              child: ListTile(
                                title: Text(
                                  'Interpretasi Sebelum: $interpretasiSebelum',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                          if (totalSkorSesudah > 0) ...[
                            Card(
                              color: interpretasiSesudah == "Tinggi/Aman"
                                  ? Colors.green
                                  : interpretasiSesudah == "Sedang/Kurang Aman"
                                      ? Colors.yellow
                                      : Colors.red,
                              child: ListTile(
                                title: Text(
                                  'Interpretasi Sesudah: $interpretasiSesudah',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[index]["nama_indikator"] ?? '',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
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
                                              _showPopup(context,
                                                  data[index]["kriteria"] ??
                                                      '');
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.help_outline,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () async {
                                              _showPopup(context,
                                                  data[index]["keterangan"] ??
                                                      '');
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
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                      ),
                                      onChanged: (value) =>
                                          _calculateTotalScore(),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: sesudahControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Sesudah',
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                      ),
                                      onChanged: (value) =>
                                          _calculateTotalScore(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: skorControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Skor',
                                        border: OutlineInputBorder(),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                      ),
                                      readOnly: true, // Set skor field to read-only
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
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
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
          if (isDataSaved)  // Show Export button only if data is saved
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
