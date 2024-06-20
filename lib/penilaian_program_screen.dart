import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; // Pastikan ini sesuai dengan path file DatabaseHelper

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
      'panduan_pertanyaan': '1. Adakah pemegang programnya?\n2. Bagaimana capaian program-program promosi kesehatan sebelum dan sesudah bencana?\n3. Bagaimana keberlanjutan program pada situasi bencana?\n4. Apakah ada perencanaan dan penganggaran program?'
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
    },
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.8 Penyakit Endemis Imunisasi',
      'kriteria': [
        'Penyakit endemis imunisasi',
      ],
      'selected_kriteria': '',
      'input_data': {},
    },
     {
      'nama_indikator': '2. Program Jejaring',
      'sub_indikator': '2.1 Puskesmas pembantu',
      'kriteria': [
        'Puskesmas pembantu',
      ],
      'selected_kriteria': '',
      'input_data': {},
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

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadDataFromDB();
  }

  Future<void> _loadDataFromDB() async {
    for (int i = 0; i < data.length; i++) {
      for (String kriteria in data[i]['kriteria']) {
        List<Map<String, dynamic>> savedData = await _databaseHelper.getEntriesByKegiatanIdAndKriteria(
          widget.kegiatanId!,
          kriteria,
          data[i]['nama_indikator'], // Tambahkan argumen ketiga yang diperlukan
        );

        print('Kriteria: $kriteria');
        print('Saved Data: $savedData');

        if (savedData.isNotEmpty) {
          for (var entry in savedData) {
            setState(() {
              data[i]['input_data'][kriteria] = {
                'indikator1': entry['indikator1']?.toString() ?? '',
                'indikator2': entry['indikator2']?.toString() ?? '',
                'indikator3': entry['indikator3']?.toString() ?? '',
                'indikator4': entry['indikator4']?.toString() ?? '',
              };
            });
          }
        } else {
          setState(() {
            data[i]['input_data'][kriteria] = {
              'indikator1': '',
              'indikator2': '',
              'indikator3': '',
              'indikator4': '',
            };
          });
        }
      }
    }
  }

  Future<void> _saveData(int index) async {
    String selectedKriteria = data[index]['selected_kriteria'];
    if (selectedKriteria.isNotEmpty) {
      Map<String, String> inputData = data[index]['input_data'][selectedKriteria]!;

      // Simpan ke database hanya jika ada nilai
      if (inputData['indikator1']!.isNotEmpty ||
          inputData['indikator2']!.isNotEmpty ||
          inputData['indikator3']!.isNotEmpty ||
          inputData['indikator4']!.isNotEmpty) {
        Map<String, dynamic> dataEntry = {
          'user_id': widget.userId,
          'kegiatan_id': widget.kegiatanId,
          'id_category': widget.id_category,
          'puskesmas': widget.puskesmas,
          'indikator': data[index]['nama_indikator'],
          'sub_indikator': data[index]['sub_indikator'],
          'kriteria': selectedKriteria,
          'indikator1': inputData['indikator1'],
          'indikator2': inputData['indikator2'],
          'indikator3': inputData['indikator3'],
          'indikator4': inputData['indikator4'],
        };

        // Periksa apakah data dengan kegiatan_id dan kriteria sudah ada
        bool exists = await _databaseHelper.entryExists(widget.kegiatanId!, selectedKriteria);
        if (exists) {
          await _databaseHelper.updateDataEntry(dataEntry);
        } else {
          await _databaseHelper.saveDataEntry(dataEntry);
        }
      }
    }
  }

  Future<void> _saveAllData() async {
    for (int i = 0; i < data.length; i++) {
      await _saveData(i);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data has been saved successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penilaian Program'),
      ),
      body: ListView.builder(
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

          // TextEditingControllers untuk setiap field indikator
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
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // Aksi saat tombol visibility ditekan
                                },
                              ),
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
                                  // Aksi saat tombol help ditekan
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
                        : null, // Mengosongkan nilai awal jika tidak valid
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

                      // Update input data dengan data dari database
                      if (newValue != null) {
                        List<Map<String, dynamic>> savedData = await _databaseHelper.getEntriesByKegiatanIdAndKriteria(
                          widget.kegiatanId!,
                          newValue,
                          data[index]['nama_indikator'], // Tambahkan argumen ketiga yang diperlukan
                        );

                        print('New Kriteria: $newValue');
                        print('Saved Data: $savedData');

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
                          // Perbarui nilai TextEditingController
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
                          // Reset nilai TextEditingController
                          indikator1Controller.text = '';
                          indikator2Controller.text = '';
                          indikator3Controller.text = '';
                          indikator4Controller.text = '';
                        }
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
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
                  SizedBox(height: 10),
                  TextField(
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
                  ),
                  SizedBox(height: 10),
                  TextField(
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
                  SizedBox(height: 10),
                  TextField(
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
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAllData,
        child: Icon(Icons.save),
      ),
    );
  }
}