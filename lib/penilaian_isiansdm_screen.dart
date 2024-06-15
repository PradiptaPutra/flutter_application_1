import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'export_isiansdm_screen.dart';

class PenilaianIsiansdmScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;

  PenilaianIsiansdmScreen({this.kegiatanId, required this.id_category, required this.userId, this.entryId});

  @override
  _PenilaianIsiansdmScreenState createState() => _PenilaianIsiansdmScreenState();
}

class _PenilaianIsiansdmScreenState extends State<PenilaianIsiansdmScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<TextEditingController> sebelumControllers = [];
  final List<TextEditingController> sesudahControllers = [];
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
    List<Map<String, dynamic>> excelData = await _dbHelper.loadExcelDataDirectly('assets/form_penilaian_isiansdm.xlsx');
    setState(() {
      data = excelData;
      for (var i = 0; i < data.length; i++) {
        sebelumControllers.add(TextEditingController());
        sesudahControllers.add(TextEditingController());
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

  void _calculateTotalScore() {
    double totalSebelum = 0;
    double totalSesudah = 0;

    for (var i = 0; i < sebelumControllers.length; i++) {
      totalSebelum += double.tryParse(sebelumControllers[i].text) ?? 0;
      totalSesudah += double.tryParse(sesudahControllers[i].text) ?? 0;
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
        'keterangan': keteranganControllers[i].text, // Tambahkan keterangan
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
        builder: (context) => ExportIsiansdmScreen(
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
