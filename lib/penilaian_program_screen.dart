import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'export_alkes_screen.dart';

class PenilaianProgramScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;

  PenilaianProgramScreen({this.kegiatanId, required this.id_category, required this.userId, this.entryId});

  @override
  _PenilaianProgramScreenState createState() => _PenilaianProgramScreenState();
}

class _PenilaianProgramScreenState extends State<PenilaianProgramScreen> {
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
  bool showInterpretations = true;
  bool isDataSaved = false;

  final List<String> mainIndicators = [
    "1. Bidang Keselamatan Pasien",
    "2. Bidang Kefarmasian dan Penggunaan Obat",
    "3. Bidang Manajemen Rumah Sakit",
    "4. Program Nasional"
  ];

  final Map<String, int> mainIndicatorSubCounts = {
    "1. Bidang Keselamatan Pasien": 3,
    "2. Bidang Kefarmasian dan Penggunaan Obat": 3,
    "3. Bidang Manajemen Rumah Sakit": 3,
    "4. Program Nasional": 3,
  };

  @override
  void initState() {
    super.initState();
    _loadExcelData();
    if (widget.kegiatanId != null) {
      _loadDataEntriesByKegiatan(widget.kegiatanId!);
    }
  }

  Future<void> _loadExcelData() async {
    List<Map<String, dynamic>> excelData = await _dbHelper.loadExcelDataDirectly('assets/form_penilaian_program.xlsx');
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
              data[i]['entry_id'] = entry['entry_id'].toString();
            }
          }
        }
        _calculateTotalScore();
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
        'kriteria': data[i]['kriteria'],
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
      isDataSaved = true;
    });
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
          kegiatanId: widget.kegiatanId,
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
          : ListView(
              children: [
                if (totalSkorAkhir > 0)
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
                        if (showInterpretations)
                          Column(
                            children: [
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
                          ),
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
                ..._buildIndicatorCards(),
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
          if (isDataSaved)
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

  List<Widget> _buildIndicatorCards() {
    List<Widget> cards = [];
    int mainIndicatorIndex = 0;
    int subIndicatorIndex = 1;

    for (int i = 0; i < data.length; i++) {
      // Check if a new main indicator should be displayed
      if (subIndicatorIndex == 1) {
        cards.add(
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              mainIndicators[mainIndicatorIndex],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      // Add the sub-indicator card
      cards.add(
        Card(
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
                        'assets/images/logors.jpg',
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
                            '${mainIndicatorIndex + 1}.$subIndicatorIndex ${data[i]["nama_indikator"] ?? ''}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                _showPopup(context, data[i]["kriteria"] ?? '');
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.help_outline,
                                color: Colors.orange,
                              ),
                              onPressed: () async {
                                _showPopup(context, data[i]["sub_indikator"] ?? '');
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
                        controller: sebelumControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Indikator ${mainIndicatorIndex + 1}.1 Sebelum',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        onChanged: (value) => _calculateTotalScore(),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: sesudahControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Indikator ${mainIndicatorIndex + 1}.2 Sesudah',
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
                        controller: sebelum2Controllers[i],
                        decoration: InputDecoration(
                          labelText: 'Indikator ${mainIndicatorIndex + 1}.3 Sebelum',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: sesudah2Controllers[i],
                        decoration: InputDecoration(
                          labelText: 'Indikator ${mainIndicatorIndex + 1}.4 Sesudah',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10,                           vertical: 5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: keteranganControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Increment the sub-indicator index
      subIndicatorIndex++;

      // If we have reached the end of the sub-indicators for a main indicator, reset the sub-indicator index and move to the next main indicator
       if (subIndicatorIndex > (mainIndicatorSubCounts[mainIndicators[mainIndicatorIndex]] ?? 0)) {
        subIndicatorIndex = 1;
        mainIndicatorIndex++;

        // Ensure we don't exceed the main indicators
        if (mainIndicatorIndex >= mainIndicators.length) {
          break;
        }
      }
    }

    return cards;
  }
}


