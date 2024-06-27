import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; // Pastikan ini sesuai dengan path file DatabaseHelper
import 'export_program_screen.dart';

class PenilaianProgramScreen extends StatefulWidget {
  final int? kegiatanId;
  final int id_category;
  final int userId;
  final int? entryId;
  final String puskesmas;

  PenilaianProgramScreen({
    this.kegiatanId,
    required this.id_category,
    required this.userId,
    this.entryId,
    required this.puskesmas,
  });

  @override
  _PenilaianProgramScreenState createState() => _PenilaianProgramScreenState();
}

class _PenilaianProgramScreenState extends State<PenilaianProgramScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String puskesmas = "";
  double totalIndikator1 = 0.0;
  double totalIndikator2 = 0.0;
  double totalIndikator3 = 0.0;
  double totalIndikator4 = 0.0;
  double totalOverall = 0.0;
  String interpretasiIndikator1 = "";
  String interpretasiIndikator2 = "";
  String interpretasiIndikator3 = "";
  String interpretasiIndikator4 = "";
  String interpretasiOverall = "";
  bool showInterpretations = false;
  bool _shouldDisableIndikator2(String subIndikator) {
  List<String> subIndikatorList = [
    '2.1 Puskesmas pembantu',
    '2.2 Puskesmas keliling',
    '2.3 Posyandu',
    '3.1 Rawat Jalan',
    '3.2 Pelayanan gawat darurat',
    '3.3 Rawat inap',
    '4.1 Manajemen puskesmas',
    '4.2 Pelayanan Kefarmasian',
    '4.3 Pelayanan Laboratorium',
  ];
  return subIndikatorList.contains(subIndikator);
}


  final List<Map<String, dynamic>> data = [
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.1 Pelayanan promosi kesehatan',
      'kriteria': [
        'Penyuluhan',
        'PHBS',
        'Pemberdayaan masyarakat',
        'UKS',
      ],
      'selected_kriteria': '',
      'input_data': <String, Map<String, String>>{},
      'panduan_pertanyaan': '1. Adakah pemegang programnya?\n2. Bagaimana capaian program-program promosi kesehatan sebelum dan sesudah bencana?\n3. Bagaimana keberlanjutan program pada situasi bencana?\n4. Apakah ada perencanaan dan penganggaran program?',
      'indikator1help': 'Pemegang program  \n - Ada = 2 \n - Tidak ada tetapi \n ada pengganti = 1 \n - Tidak ada dan tidak ada pengganti = 0',
      'indikator2help': 'Capaian program sebelum dan sesudah bencana \n - peningkatan = 2 \n - Jika sama = 1 \n - penurunan = 0',
      'indikator3help': 'Situasi program pascabencana \n - Terus berjalan = 2 \n - Sedikit tehambat tetapi terus diupayakan berjalan = 1 \n - tidak berjalan =0',
      'indikator4help': 'Rencana program \n - Rencana jelas, terukur, dan terencana di anggaran = 2 \n  - Rencana program yang kurang jelas, belum terukur, dan hanya terencana sebagian = 1 \n - Tidak memiliki rencana, tidak terukur dan tidak terencana dianggaran = 0'
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.2 Pelayanan kesehatan lingkungan',
      'kriteria': [
        'Konseling/Penyuluhan',
        'STBm',
        'Surveilans faktor risiko',
        'Penyehatan lingkungan',
      ],
      'selected_kriteria': '',
      'input_data': <String, Map<String, String>>{},
       'panduan_pertanyaan': '1. Adakah pemegang programnya?\n2. Bagaimana capaian program-program promosi kesehatan sebelum dan sesudah bencana?\n3. Bagaimana keberlanjutan program pada situasi bencana?\n4. Apakah ada perencanaan dan penganggaran program?'
    },
    // Tambahkan data lainnya di sini
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.3 Pelayanan kesehatan ibu, anak, dan keluarga berencana',
      'kriteria': [
        'ANC',
        'Persalinan',
        'PONED',
        'cakupan KB',
        'Kesehatan reproduksi kelompok rentan',
        'Posyandu',
        'ODHA',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '1. Adakah pemegang programnya?\n2. Bagaimana capaian program-program promosi kesehatan sebelum dan sesudah bencana?\n3. Bagaimana keberlanjutan program pada situasi bencana?\n4. Apakah ada perencanaan dan penganggaran program?'
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.4 Pelayanan gizi',
      'kriteria': [
        'Penilaian status gizi kelompok rentan',
        'PMT',
        'PMBA',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '1. Adakah pemegang programnya?\n2. Bagaimana capaian program-program promosi kesehatan sebelum dan sesudah bencana?\n3. Bagaimana keberlanjutan program pada situasi bencana?\n4. Apakah ada perencanaan dan penganggaran program?'
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.5 Pelaporan pencegahan dan pengendalian penyakit',
      'kriteria': [
        'SKdR target kelengkapan, ketepatan, dan respon alert',
        'Laporan KLB <24 jam',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '1. Bagaimana situasi program pengendalian dan pencegahan penyakit sebelum dan sesudah bencana? \n2. Jelaskan mengenai cakupan kelengkapan, ketepatan dan respon alert SKDR? *tuliskan di keterangan \nLihat             keberadaan penanggung          jawab, berhubungan       dengan surveilans faktor risiko di bidang   lain   (kesehatan lingkungan)?   Ada   atau tidaknya          pemegang program?,   apa   rencana untuk masa pemulihan? *perhatikan kepada program-program yang menjadi capaian nasional, berikut juga ciri khas daerah. Penekanan lebih pada penyakit menular, tetapi juga bagii penyakit tidak menular lainnya. Yang tidak tercakup dalam list ini, tuliskan di keterangan'
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.6 Penyakit menular',
      'kriteria': [
        'HIV/AIDS',
        'Frambusia',
        'Tuberculosis',
        'Malaria',
        'Demam Berdarah',
        'Influenza',
        'Flu burung',
        'Kusta',
        'Filariasis',
        'Leptopirosis',
        'Polio',
        'Campak',
        'Difteri',
        'Pertusis',
        'Hepatitis B',
        'Tetanus',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '1. Bagaimana situasi program pengendalian dan pencegahan penyakit sebelum dan sesudah bencana? \n2. Jelaskan mengenai cakupan kelengkapan, ketepatan dan respon alert SKDR? *tuliskan di keterangan \nLihat             keberadaan penanggung          jawab, berhubungan       dengan surveilans faktor risiko di bidang   lain   (kesehatan lingkungan)?   Ada   atau tidaknya          pemegang program?,   apa   rencana untuk masa pemulihan? *perhatikan kepada program-program yang menjadi capaian nasional, berikut juga ciri khas daerah. Penekanan lebih pada penyakit menular, tetapi juga bagii penyakit tidak menular lainnya. Yang tidak tercakup dalam list ini, tuliskan di keterangan'
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.7 Penyakit tidak menular',
      'kriteria': [
        'Hipertensi',
        'Diabetes Melitus',
        'Penyakit Paru obstruksi Kronik (PPOK)',
        'Perokok',
        'Kesehatan Jiwa',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '1. Bagaimana situasi program pengendalian dan pencegahan penyakit sebelum dan sesudah bencana? \n2. Jelaskan mengenai cakupan kelengkapan, ketepatan dan respon alert SKDR? *tuliskan di keterangan \nLihat             keberadaan penanggung          jawab, berhubungan       dengan surveilans faktor risiko di bidang   lain   (kesehatan lingkungan)?   Ada   atau tidaknya          pemegang program?,   apa   rencana untuk masa pemulihan? *perhatikan kepada program-program yang menjadi capaian nasional, berikut juga ciri khas daerah. Penekanan lebih pada penyakit menular, tetapi juga bagii penyakit tidak menular lainnya. Yang tidak tercakup dalam list ini, tuliskan di keterangan'
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.8 Penyakit Endemis Imunisasi',
      'kriteria': [
        'Penyakit endemis imunisasi',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '1. Bagaimana situasi program pengendalian dan pencegahan penyakit sebelum dan sesudah bencana? \n2. Jelaskan mengenai cakupan kelengkapan, ketepatan dan respon alert SKDR? *tuliskan di keterangan \nLihat             keberadaan penanggung          jawab, berhubungan       dengan surveilans faktor risiko di bidang   lain   (kesehatan lingkungan)?   Ada   atau tidaknya          pemegang program?,   apa   rencana untuk masa pemulihan? *perhatikan kepada program-program yang menjadi capaian nasional, berikut juga ciri khas daerah. Penekanan lebih pada penyakit menular, tetapi juga bagii penyakit tidak menular lainnya. Yang tidak tercakup dalam list ini, tuliskan di keterangan'
    },
     {
      'nama_indikator': '2. Program Jejaring',
      'sub_indikator': '2.1 Puskesmas pembantu',
      'kriteria': [
        'Puskesmas pembantu',
      ],
      'selected_kriteria': '',
      'input_data': {},
      'panduan_pertanyaan': '*tuliskan di keterangan *Berapa jumlah puskesmas pembantu yang dimiliki puskesmas? Termasuk rumah bidan, dan poskesdes polindes.'
    },
     {
      'nama_indikator': '2. Program Jejaring',
      'sub_indikator': '2.2 Puskesmas keliling',
      'kriteria': [
        'Puskesmas keliling',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
     {
      'nama_indikator': '2. Program Jejaring',
      'sub_indikator': '2.3 Posyandu',
      'kriteria': [
        'Posyandu',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
    {
      'nama_indikator': '3. Program Upaya Kesehatan Perorangan',
      'sub_indikator': '3.1 Rawat Jalan',
      'kriteria': [
        'Rawat Jalan',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
    {
      'nama_indikator': '3. Program Upaya Kesehatan Perorangan',
      'sub_indikator': '3.2 Pelayanan gawat darurat',
      'kriteria': [
        'Pelayanan gawat darurat',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
    {
      'nama_indikator': '3. Program Upaya Kesehatan Perorangan',
      'sub_indikator': '3.3 Rawat inap',
      'kriteria': [
        'Rawat inap',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
     {
      'nama_indikator': '4. Program penyelenggaraan kegiatan puskesmas',
      'sub_indikator': '4.1 Manajemen puskesmas',
      'kriteria': [
        'Manajemen puskesmas',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
     {
      'nama_indikator': '4. Program penyelenggaraan kegiatan puskesmas',
      'sub_indikator': '4.2 Pelayanan Kefarmasian',
      'kriteria': [
        'Pelayanan kefarmasian',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
     {
      'nama_indikator': '4. Program penyelenggaraan kegiatan puskesmas',
      'sub_indikator': '4.3 Pelayanan Laboratorium',
      'kriteria': [
        'Pelayanan Laboratorium',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadDataFromDB().then((_) {
      _updateAllScores();
    });
  }

  Future<void> _loadDataFromDB() async {
  for (int i = 0; i < data.length; i++) {
    for (String kriteria in data[i]['kriteria']) {
      List<Map<String, dynamic>> savedData = await _dbHelper.getEntriesByKegiatanIdAndKriteria(
        widget.kegiatanId!,
        kriteria,
        data[i]['nama_indikator'],
      );

      if (savedData.isNotEmpty) {
        for (var entry in savedData) {
          setState(() {
            if (_shouldDisableIndikator2(data[i]['sub_indikator'])) {
              data[i]['input_data'][kriteria] = {
                'indikator1': entry['indikator1']?.toString() ?? '',
                'indikator3': entry['indikator3']?.toString() ?? '',
                'indikator4': entry['indikator4']?.toString() ?? '',
              };
            } else {
              data[i]['input_data'][kriteria] = {
                'indikator1': entry['indikator1']?.toString() ?? '',
                'indikator2': entry['indikator2']?.toString() ?? '',
                'indikator3': entry['indikator3']?.toString() ?? '',
                'indikator4': entry['indikator4']?.toString() ?? '',
              };
            }
          });
        }
      } else {
        setState(() {
          if (_shouldDisableIndikator2(data[i]['sub_indikator'])) {
            data[i]['input_data'][kriteria] = {
              'indikator1': '',
              'indikator3': '',
              'indikator4': '',
            };
          } else {
            data[i]['input_data'][kriteria] = {
              'indikator1': '',
              'indikator2': '',
              'indikator3': '',
              'indikator4': '',
            };
          }
        });
      }
    }
  }
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
        builder: (context) => ExportProgramScreen(
          puskesmas: puskesmas,
          totalIndikator1: totalIndikator1.toInt(),
          totalIndikator2: totalIndikator2.toInt(),
          totalIndikator3: totalIndikator3.toInt(),
          totalIndikator4: totalIndikator4.toInt(),
          totalOverall: totalOverall.toInt(),
          interpretasiIndikator1: interpretasiIndikator1,
          interpretasiIndikator2: interpretasiIndikator2,
          interpretasiIndikator3: interpretasiIndikator3,
          interpretasiIndikator4: interpretasiIndikator4,
          interpretasiOverall: interpretasiOverall,
          userId: widget.userId,
          kegiatanId: widget.kegiatanId, // Tambahkan kegiatanId di sini
        ),
      ),
    );
  }

  void _updateAllScores() {
    setState(() {
      totalIndikator1 = _calculateTotalSkorForIndikator(1);
      totalIndikator2 = _calculateTotalSkorForIndikator(2);
      totalIndikator3 = _calculateTotalSkorForIndikator(3);
      totalIndikator4 = _calculateTotalSkorForIndikator(4);
      totalOverall = totalIndikator1 * 0.2 + totalIndikator2 * 0.2 + totalIndikator3 * 0.3 + totalIndikator4 * 0.3;
      interpretasiIndikator1 = _setInterpretasi(totalIndikator1);
      interpretasiIndikator2 = _setInterpretasi(totalIndikator2);
      interpretasiIndikator3 = _setInterpretasi(totalIndikator3);
      interpretasiIndikator4 = _setInterpretasi(totalIndikator4);
      interpretasiOverall = _setInterpretasi(totalIndikator1 * 0.2 + totalIndikator2 * 0.2 + totalIndikator3 * 0.3 + totalIndikator4 * 0.3);
    });
  }

  double _calculateTotalSkorForIndikator(int indikator) {
    double totalSkor = 0;
    for (var entry in data) {
      for (String kriteria in entry['kriteria']) {
        Map<String, String> inputData = entry['input_data'][kriteria] ?? {
          'indikator1': '',
          'indikator2': '',
          'indikator3': '',
          'indikator4': '',
        };

        switch (indikator) {
          case 1:
            totalSkor += double.tryParse(inputData['indikator1'] ?? '') ?? 0;
            break;
          case 2:
            totalSkor += double.tryParse(inputData['indikator2'] ?? '') ?? 0;
            break;
          case 3:
            totalSkor += double.tryParse(inputData['indikator3'] ?? '') ?? 0;
            break;
          case 4:
            totalSkor += double.tryParse(inputData['indikator4'] ?? '') ?? 0;
            break;
        }
      }
    }
    return totalSkor;
  }

  Future<void> _saveData(int index) async {
    List<Map<String, dynamic>> kegiatanList = await _dbHelper.getKegiatanForUser(widget.userId);

    Map<String, dynamic> kegiatan = kegiatanList.firstWhere(
      (kegiatan) => kegiatan['kegiatan_id'] == widget.kegiatanId,
      orElse: () => <String, dynamic>{},
    );

    puskesmas = kegiatan.isNotEmpty ? kegiatan['nama_puskesmas'] : '';
    String selectedKriteria = data[index]['selected_kriteria'];
    if (selectedKriteria.isNotEmpty) {
      Map<String, String> inputData = data[index]['input_data'][selectedKriteria]!;

      if (inputData['indikator1']!.isNotEmpty ||
          inputData['indikator2']!.isNotEmpty ||
          inputData['indikator3']!.isNotEmpty ||
          inputData['indikator4']!.isNotEmpty) {

        Map<String, dynamic> dataEntry = {
          'user_id': widget.userId,
          'kegiatan_id': widget.kegiatanId,
          'id_category': widget.id_category,
          'puskesmas': puskesmas,
          'indikator': data[index]['nama_indikator'],
          'sub_indikator': data[index]['sub_indikator'],
          'kriteria': selectedKriteria,
          'indikator1': inputData['indikator1'],
          'indikator2': inputData['indikator2'],
          'indikator3': inputData['indikator3'],
          'indikator4': inputData['indikator4'],
        };

        bool exists = await _dbHelper.entryExists(widget.kegiatanId!, selectedKriteria);
        if (exists) {
          await _dbHelper.updateDataEntry(dataEntry);
        } else {
          await _dbHelper.saveDataEntry(dataEntry);
        }
      }
    }
    _updateAllScores(); // Update scores after saving data
  }

  Future<void> _saveAllData() async {
    for (int i = 0; i < data.length; i++) {
      await _saveData(i);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data has been saved successfully')));
  }

  void _showPanduanPertanyaan(String panduanPertanyaan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Panduan Pertanyaan'),
          content: Text(panduanPertanyaan),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showPanduanIndikator(String panduanPertanyaan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Panduan Indikator '),
          content: Text(panduanPertanyaan),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
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

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Penilaian Program'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                color: interpretasiOverall == "Tinggi/Aman"
                    ? Colors.green
                    : interpretasiOverall == "Sedang/Kurang Aman"
                        ? Colors.yellow
                        : Colors.red,
                child: ListTile(
                  title: Text(
                    'Total Skor Program: ${(totalIndikator1 * 0.2 + totalIndikator2 * 0.2 + totalIndikator3 * 0.3 + totalIndikator4 * 0.3).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    'Interpretasi Keseluruhan: $interpretasiOverall',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
              if (showInterpretations) ...[
                Card(
                  color: interpretasiIndikator1 == "Tinggi/Aman"
                      ? Colors.green
                      : interpretasiIndikator1 == "Sedang/Kurang Aman"
                          ? Colors.yellow
                          : Colors.red,
                  child: ListTile(
                    title: Text(
                      'Indikator 1: $totalIndikator1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      'Interpretasi: $interpretasiIndikator1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Card(
                  color: interpretasiIndikator2 == "Tinggi/Aman"
                      ? Colors.green
                      : interpretasiIndikator2 == "Sedang/Kurang Aman"
                          ? Colors.yellow
                          : Colors.red,
                  child: ListTile(
                    title: Text(
                      'Indikator 2: $totalIndikator2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      'Interpretasi: $interpretasiIndikator2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Card(
                  color: interpretasiIndikator3 == "Tinggi/Aman"
                      ? Colors.green
                      : interpretasiIndikator3 == "Sedang/Kurang Aman"
                          ? Colors.yellow
                          : Colors.red,
                  child: ListTile(
                    title: Text(
                      'Indikator 3: $totalIndikator3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      'Interpretasi: $interpretasiIndikator3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Card(
                  color: interpretasiIndikator4 == "Tinggi/Aman"
                      ? Colors.green
                      : interpretasiIndikator4 == "Sedang/Kurang Aman"
                          ? Colors.yellow
                          : Colors.red,
                  child: ListTile(
                    title: Text(
                      'Indikator 4: $totalIndikator4',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      'Interpretasi: $interpretasiIndikator4',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                String selectedKriteria = data[index]['selected_kriteria'];
                Map<String, String> inputData = selectedKriteria.isNotEmpty
                    ? data[index]['input_data'][selectedKriteria] ?? {
                        'indikator1': '',
                        'indikator2': '',
                        'indikator3': '',
                        'indikator4': '',
                      }
                    : {
                        'indikator1': '',
                        'indikator2': '',
                        'indikator3': '',
                        'indikator4': '',
                      };

                TextEditingController indikator1Controller = TextEditingController(text: inputData['indikator1']);
                TextEditingController indikator2Controller = TextEditingController(text: inputData['indikator2']);
                TextEditingController indikator3Controller = TextEditingController(text: inputData['indikator3']);
                TextEditingController indikator4Controller = TextEditingController(text: inputData['indikator4']);

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
                                    '${data[index]['nama_indikator']}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${data[index]['sub_indikator']}',
                                    style: TextStyle(fontSize: 14),
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
                                        Icons.help_outline,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Panduan Pertanyaan'),
                                              content: Text(data[index]['panduan_pertanyaan']),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Tutup'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
                        DropdownButtonFormField<String>(
                          value: selectedKriteria.isNotEmpty && data[index]['kriteria'].contains(selectedKriteria)
                              ? selectedKriteria
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Kriteria',
                            border: OutlineInputBorder(),
                          ),
                          items: data[index]['kriteria'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            setState(() {
                              data[index]['selected_kriteria'] = newValue ?? '';
                            });

                            if (newValue != null) {
                              List<Map<String, dynamic>> savedData = await _dbHelper.getEntriesByKegiatanIdAndKriteria(
                                widget.kegiatanId!,
                                newValue,
                                data[index]['nama_indikator'],
                              );

                              if (savedData.isNotEmpty) {
                                for (var entry in savedData) {
                                  setState(() {
                                    data[index]['input_data'][newValue] = {
                                      'indikator1': entry['indikator1']?.toString() ?? '',
                                      'indikator2': entry['indikator2']?.toString() ?? '',
                                      'indikator3': entry['indikator3']?.toString() ?? '',
                                      'indikator4': entry['indikator4']?.toString() ?? '',
                                    };
                                  });
                                }

                                indikator1Controller.text = data[index]['input_data'][newValue]['indikator1'] ?? '';
                                indikator2Controller.text = data[index]['input_data'][newValue]['indikator2'] ?? '';
                                indikator3Controller.text = data[index]['input_data'][newValue]['indikator3'] ?? '';
                                indikator4Controller.text = data[index]['input_data'][newValue]['indikator4'] ?? '';
                              } else {
                                setState(() {
                                  data[index]['input_data'][newValue] = {
                                    'indikator1': '',
                                    'indikator2': '',
                                    'indikator3': '',
                                    'indikator4': '',
                                  };
                                });

                                indikator1Controller.text = '';
                                indikator2Controller.text = '';
                                indikator3Controller.text = '';
                                indikator4Controller.text = '';
                              }
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: indikator1Controller,
                                decoration: InputDecoration(
                                  labelText: 'Indikator 1',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    data[index]['input_data'][selectedKriteria]['indikator1'] = value;
                                  });
                                  _saveData(index);
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.help_outline),
                              onPressed: () {
                                _showPanduanIndikator(data[index]['indikator1help']);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
  child: TextField(
    controller: indikator2Controller,
    decoration: InputDecoration(
      labelText: 'Indikator 2',
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    ),
    onChanged: (value) {
      setState(() {
        data[index]['input_data'][selectedKriteria]['indikator2'] = value;
      });
      _saveData(index);
    },
    enabled: !_shouldDisableIndikator2(data[index]['sub_indikator']), // Menonaktifkan input indikator 2 sesuai sub indikator
  ),
),

                            IconButton(
                              icon: Icon(Icons.help_outline),
                              onPressed: () {
                                _showPanduanIndikator(data[index]['indikator2help']);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: indikator3Controller,
                                decoration: InputDecoration(
                                  labelText: 'Indikator 3',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    data[index]['input_data'][selectedKriteria]['indikator3'] = value;
                                  });
                                  _saveData(index);
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.help_outline),
                              onPressed: () {
                                _showPanduanIndikator(data[index]['indikator3help']);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: indikator4Controller,
                                decoration: InputDecoration(
                                  labelText: 'Indikator 4',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    data[index]['input_data'][selectedKriteria]['indikator4'] = value;
                                  });
                                  _saveData(index);
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.help_outline),
                              onPressed: () {
                                _showPanduanIndikator(data[index]['indikator4help']);
                              },
                            ),
                          ],
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        FloatingActionButton(
        onPressed: () {
          _saveAllData();
        },
        child: Icon(Icons.save),
      ),
         SizedBox(width: 10),
          FloatingActionButton(
      onPressed: () {
        // Tambahkan logika untuk ekspor di sini
        _exportData();
      },
      child: Icon(Icons.next_week),
      tooltip: 'Export',
    ),
        ]
      ),
    );
  }
}