import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'export_sdm_screen.dart';

class PenilaianSdmScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;
  final String dropdownOption;

  PenilaianSdmScreen({
    this.kegiatanId,
    required this.id_category,
    required this.userId,
    this.entryId,
    required this.dropdownOption,
  });

  @override
  _PenilaianSdmScreenState createState() => _PenilaianSdmScreenState();
}

class _PenilaianSdmScreenState extends State<PenilaianSdmScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<TextEditingController> spmControllers = [];
  final List<TextEditingController> sblControllers = [];
  final List<TextEditingController> sdhControllers = [];
  final List<TextEditingController> keteranganControllers = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> existingEntries = [];
  double totalSPM = 0;
  double totalSBL = 0;
  double totalSDH = 0;
  double totalSkorAkhir = 0;
  String interpretasiAkhir = "";
  String puskesmas = "";
  bool showInterpretations = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptionAndLoadExcelData();
    if (widget.kegiatanId != null) {
      _loadDataEntriesByKegiatan(widget.kegiatanId!);
    }
  }

  Future<void> _fetchDropdownOptionAndLoadExcelData() async {
    String dropdownOption = await _fetchDropdownOption(widget.kegiatanId);
    await _loadExcelData(dropdownOption);
  }

  Future<String> _fetchDropdownOption(int? kegiatanId) async {
    String dropdownOption = await _dbHelper.fetchDropdownOption(kegiatanId ?? 0); // Handle null case
    return dropdownOption;
  }

  Future<void> _loadExcelData(String dropdownOption) async {
    List<Map<String, dynamic>> excelData =
        await _dbHelper.loadExcelDataDirectly('assets/form_penilaian_sumberdaya_manusia.xlsx');
    print('Excel Data: $excelData'); // Check what data is loaded

    setState(() {
      data = excelData;
      for (var i = 0; i < data.length; i++) {
        spmControllers.add(TextEditingController());
        sblControllers.add(TextEditingController());
                sdhControllers.add(TextEditingController());
        keteranganControllers.add(TextEditingController());

        // Adjust SPM values based on dropdownOption
        if (dropdownOption == 'Non Rawat Inap') {
          spmControllers[i].text = data[i]['sub_indikator'] ?? '';
        } else {
          spmControllers[i].text = data[i]['keterangan'] ?? '';
        }
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
              if (widget.dropdownOption == 'Non Rawat Inap') {
                spmControllers[i].text = data[i]['sub_indikator'] ?? '';
              } else {
                spmControllers[i].text = data[i]['keterangan'] ?? '';
              }
              sblControllers[i].text = entry['SBL'] ?? '';
              sdhControllers[i].text = entry['SDH'] ?? '';
              keteranganControllers[i].text = entry['keterangan'] ?? '';
              data[i]['entry_id'] = entry['entry_id'].toString(); // Ensure entry_id is stored as String
            }
          }
        }
        _calculateTotalScore(); // Calculate total score when data is loaded
      });
    }
  }

  void _calculateTotalScore() {
    double totalSPMScore = 0;
    double totalSBLScore = 0;
    double totalSDHScore = 0;

    for (var i = 0; i < spmControllers.length; i++) {
      totalSPMScore += double.tryParse(spmControllers[i].text) ?? 0;
      totalSBLScore += double.tryParse(sblControllers[i].text) ?? 0;
      totalSDHScore += double.tryParse(sdhControllers[i].text) ?? 0;
    }

    setState(() {
      totalSPM = totalSPMScore;
      totalSBL = totalSBLScore;
      totalSDH = totalSDHScore;

      totalSkorAkhir = (totalSBL * 0.5) + (totalSDH * 0.5);
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
        'SPM': spmControllers[i].text,
        'SBL': sblControllers[i].text,
        'SDH': sdhControllers[i].text,
        'keterangan': keteranganControllers[i].text,
      };

      if (data[i].containsKey('entry_id')) {
        entry['entry_id'] = int.parse(data[i]['entry_id']);
      }

      await _dbHelper.saveDataEntry(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
    Navigator.pop(context);
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
        builder: (context) => ExportSdmScreen(
          puskesmas: puskesmas,
          sebelumIndikator1: totalSPM,
          sesudahIndikator1: totalSBL,
          sebelumIndikator2: totalSDH,
          sesudahIndikator2: totalSDH,
          interpretasiIndikator1Sebelum: interpretasiAkhir,
          interpretasiIndikator1Sesudah: interpretasiAkhir,
          interpretasiIndikator2Sebelum: interpretasiAkhir,
          interpretasiIndikator2Sesudah: interpretasiAkhir,
          interpretasiAkhir: interpretasiAkhir,
          userId: widget.userId,
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
    for (var controller in spmControllers) {
      controller.dispose();
    }
    for (var controller in sblControllers) {
      controller.dispose();
    }
    for (var controller in sdhControllers) {
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
                                          data[index]["nama_indikator"] ?? '',
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
                                      controller: spmControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'SPM',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      readOnly: true, // Prevent user from editing this field
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: sblControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'SBL',
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
                                      controller: sdhControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'SDH',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onChanged: (value) => _calculateTotalScore(),
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
