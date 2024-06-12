import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatelessWidget {
  final int userId;
  final int? kegiatanId;
  final List<int>? entryIds; // Make entryIds nullable

  CategorySelectionScreen({required this.userId, this.kegiatanId, this.entryIds});

  @override
  Widget build(BuildContext context) {
    print('kegiatanId: $kegiatanId');

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
                      'userId': userId,
                      'kegiatanId': kegiatanId,
                      'entryIds': entryIds, // Pass the list of entry IDs, can be null
                      'id_category': 11, // id_category for Fasilitas Pelayanan Kesehatan
                    },
                  );
                },
              ),
              ListTile(
                title: Text('Alat Kesehatan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian_alkes',
                    arguments: {
                      'userId': userId,
                      'kegiatanId': kegiatanId,
                      'entryIds': entryIds, // Pass the list of entry IDs, can be null
                      'id_category': 12, // id_category for Fasilitas Pelayanan Kesehatan
                    },
                  );
                },
              ),
              ListTile(
                title: Text('Kendaraan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/penilaian_kendaraan',
                    arguments: {
                      'userId': userId,
                      'kegiatanId': kegiatanId,
                      'entryIds': entryIds, // Pass the list of entry IDs, can be null
                      'id_category': 13, // id_category for Fasilitas Pelayanan Kesehatan
                    },
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
            title: Text('SDM Kesehatan'),
            subtitle: Text('Deskripsi singkat'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/penilaian_sdm',
                arguments: {
                  'userId': userId,
                  'kegiatanId': kegiatanId,
                  'entryIds': entryIds, // Pass the list of entry IDs, can be null
                  'id_category': 2, // id_category for SDM Kesehatan
                },
              );
            },
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
                  'userId': userId,
                  'kegiatanId': kegiatanId,
                  'entryIds': entryIds, // Pass the list of entry IDs, can be null
                  'id_category': 3, // id_category for Program Kesehatan
                },
              );
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
                  'userId': userId,
                  'kegiatanId': kegiatanId,
                  'entryIds': entryIds, // Pass the list of entry IDs, can be null
                  'id_category': 4, // id_category for Pembiayaan Kesehatan
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
