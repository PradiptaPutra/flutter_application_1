import 'package:flutter/material.dart';
import 'database_helper.dart';

class CategorySelectionScreen extends StatefulWidget {
  final int userId;
  final int? kegiatanId;
  final List<int>? entryIds;

  CategorySelectionScreen({required this.userId, this.kegiatanId, this.entryIds});

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool _isDataKehadiranEnabled = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _checkDataKehadiran();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _checkDataKehadiran when returning to this screen
    _checkDataKehadiran();
  }

  Future<void> _checkDataKehadiran() async {
    if (widget.kegiatanId != null) {
      bool exists = await _checkEntryExists(widget.kegiatanId!, 22);
      setState(() {
        _isDataKehadiranEnabled = exists;
      });
    }
  }

  Future<bool> _checkEntryExists(int kegiatanId, int categoryId) async {
    // Simulasi pemanggilan database untuk mendapatkan entri berdasarkan kegiatanId
    List<Map<String, dynamic>> entries = await _dbHelper.getEntriesByKegiatanId(kegiatanId);
    return entries.any((entry) => entry['id_category'] == categoryId);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Informasi"),
          content: Text("Silahkan Isi penilaian Data Ketenagaaan Puskesmas terlebih dahulu!"),
          actions: [
            TextButton(
              child: Text("OK"),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            leading: Icon(Icons.local_hospital, color: Theme.of(context).primaryColor),
            title: Text('Fasilitas Pelayanan Kesehatan'),
            subtitle: Text('Klik untuk melihat lebih lanjut'),
            children: [
              ListTile(
                title: Text('Bangunan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian',
                    arguments: {
                      'userId': widget.userId,
                      'kegiatanId': widget.kegiatanId,
                      'entryIds': widget.entryIds,
                      'id_category': 11,
                    },
                  ).then((_) => _checkDataKehadiran());
                },
              ),
              ListTile(
                title: Text('Alat Kesehatan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian_alkes',
                    arguments: {
                      'userId': widget.userId,
                      'kegiatanId': widget.kegiatanId,
                      'entryIds': widget.entryIds,
                      'id_category': 12,
                    },
                  ).then((_) => _checkDataKehadiran());
                },
              ),
              ListTile(
                title: Text('Kendaraan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian_kendaraan',
                    arguments: {
                      'userId': widget.userId,
                      'kegiatanId': widget.kegiatanId,
                      'entryIds': widget.entryIds,
                      'id_category': 13,
                    },
                  ).then((_) => _checkDataKehadiran());
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: Icon(Icons.local_hospital, color: Theme.of(context).primaryColor),
            title: Text('SDM Kesehatan'),
            subtitle: Text('Klik untuk melihat lebih lanjut'),
            children: [
              ListTile(
                title: Text('Sumber Daya Manusia'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian_isiansdm',
                    arguments: {
                      'userId': widget.userId,
                      'kegiatanId': widget.kegiatanId,
                      'entryIds': widget.entryIds,
                      'id_category': 21,
                    },
                  ).then((_) => _checkDataKehadiran());
                },
              ),
              ListTile(
                title: Text('Data Ketenagaan Puskesmas'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian_sdm',
                    arguments: {
                      'userId': widget.userId,
                      'kegiatanId': widget.kegiatanId,
                      'entryIds': widget.entryIds,
                      'id_category': 22,
                    },
                  ).then((_) => _checkDataKehadiran());
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Text('Data Kehadiran Tenaga Kesehatan'),
                    if (!_isDataKehadiranEnabled)
                      IconButton(
                        icon: Icon(Icons.help_outline),
                        onPressed: () => _showInfoDialog(context),
                      ),
                  ],
                ),
                onTap: _isDataKehadiranEnabled
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/penilaian_kehadiransdm',
                          arguments: {
                            'userId': widget.userId,
                            'kegiatanId': widget.kegiatanId,
                            'entryIds': widget.entryIds,
                            'id_category': 23,
                          },
                        ).then((_) => _checkDataKehadiran());
                      }
                    : null,
                enabled: _isDataKehadiranEnabled,
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Theme.of(context).primaryColor),
            title: Text('Program Kesehatan'),
            subtitle: Text('Deskripsi singkat'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/penilaian_program',
                arguments: {
                  'userId': widget.userId,
                  'kegiatanId': widget.kegiatanId,
                  'entryIds': widget.entryIds,
                  'id_category': 3,
                },
              ).then((_) => _checkDataKehadiran());
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: Theme.of(context).primaryColor),
            title: Text('Pembiayaan Kesehatan'),
            subtitle: Text('Deskripsi singkat'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/penilaian_pembiayaan',
                arguments: {
                  'userId': widget.userId,
                  'kegiatanId': widget.kegiatanId,
                  'entryIds': widget.entryIds,
                  'id_category': 4,
                },
              ).then((_) => _checkDataKehadiran());
            },
          ),
        ],
      ),
    );
  }
}
