import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PenilaianProgramScreen extends StatefulWidget {
  @override
  _PenilaianProgramScreenState createState() => _PenilaianProgramScreenState();
}

class _PenilaianProgramScreenState extends State<PenilaianProgramScreen> {
  final List<Map<String, dynamic>> data = [
    {
      'nama_indikator': '1. Program Upaya Kesehatan Masyarakat Esensial',
      'sub_indikator': '1.1 Pelayanan promosi kesehatan',
      'kriteria': [
        'Penyuluhan PHBS',
        'PHBS',
        'Pemberdayaan masyarakat',
        'UKS',
      ],
      'selected_kriteria': '',
      'input_data': {},
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
      'input_data': {},
    },
    // Tambahkan data lainnya di sini
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < data.length; i++) {
      String? selectedKriteria = prefs.getString('selected_kriteria_$i');
      setState(() {
        data[i]['selected_kriteria'] = selectedKriteria ?? '';
      });
      if (selectedKriteria != null && selectedKriteria.isNotEmpty) {
        setState(() {
          data[i]['input_data'][selectedKriteria] = {
            'indikator1': prefs.getString('indikator1_${i}_$selectedKriteria') ?? '',
            'indikator2': prefs.getString('indikator2_${i}_$selectedKriteria') ?? '',
            'indikator3': prefs.getString('indikator3_${i}_$selectedKriteria') ?? '',
            'indikator4': prefs.getString('indikator4_${i}_$selectedKriteria') ?? '',
          };
        });
      }
    }
  }

  Future<void> _saveData(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedKriteria = data[index]['selected_kriteria'];
    await prefs.setString('selected_kriteria_$index', selectedKriteria);
    if (selectedKriteria.isNotEmpty) {
      await prefs.setString('indikator1_${index}_$selectedKriteria', data[index]['input_data'][selectedKriteria]['indikator1']);
      await prefs.setString('indikator2_${index}_$selectedKriteria', data[index]['input_data'][selectedKriteria]['indikator2']);
      await prefs.setString('indikator3_${index}_$selectedKriteria', data[index]['input_data'][selectedKriteria]['indikator3']);
      await prefs.setString('indikator4_${index}_$selectedKriteria', data[index]['input_data'][selectedKriteria]['indikator4']);
    }
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
                    onChanged: (String? newValue) {
                      setState(() {
                        data[index]['selected_kriteria'] = newValue ?? '';
                        if (!data[index]['input_data'].containsKey(newValue)) {
                          data[index]['input_data'][newValue] = {
                            'indikator1': '',
                            'indikator2': '',
                            'indikator3': '',
                            'indikator4': '',
                          };
                        }
                        _saveData(index);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: inputData['indikator1']),
                    decoration: InputDecoration(
                      labelText: 'Indikator 1',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    onChanged: (value) {
                      setState(() {
                        data[index]['input_data'][selectedKriteria]['indikator1'] = value;
                        _saveData(index);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: inputData['indikator2']),
                    decoration: InputDecoration(
                      labelText: 'Indikator 2',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    onChanged: (value) {
                      setState(() {
                        data[index]['input_data'][selectedKriteria]['indikator2'] = value;
                        _saveData(index);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: inputData['indikator3']),
                    decoration: InputDecoration(
                      labelText: 'Indikator 3',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    onChanged: (value) {
                      setState(() {
                        data[index]['input_data'][selectedKriteria]['indikator3'] = value;
                        _saveData(index);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: inputData['indikator4']),
                    decoration: InputDecoration(
                      labelText: 'Indikator 4',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    onChanged: (value) {
                      setState(() {
                        data[index]['input_data'][selectedKriteria]['indikator4'] = value;
                        _saveData(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PenilaianProgramScreen(),
  ));
}
