import 'package:flutter/material.dart';
import 'indikator_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  final int userId;
  final int? kegiatanId;
  final List<int>? entryIds;  // Tambahkan entryIds sebagai parameter nullable

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
                    '/indikator',
                    arguments: {
                      'userId': userId,
                      'kegiatanId': kegiatanId,
                      'entryIds': entryIds, // Pass the list of entry IDs, can be null
                      'id_indikator': 1, // id_indikator for Fasilitas Pelayanan Kesehatan
                    },
                  );
                },
              ),
              ListTile(
                title: Text('Alat Kesehatan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/indikator',
                    arguments: {
                      'userId': userId,
                      'kegiatanId': kegiatanId,
                      'entryIds': entryIds, // Pass the list of entry IDs, can be null
                      'id_indikator': 1, // id_indikator for Fasilitas Pelayanan Kesehatan
                    },
                  );
                },
              ),
              ListTile(
                title: Text('Kendaraan'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/indikator',
                    arguments: {
                      'userId': userId,
                      'kegiatanId': kegiatanId,
                      'entryIds': entryIds, // Pass the list of entry IDs, can be null
                      'id_indikator': 1, // id_indikator for Fasilitas Pelayanan Kesehatan
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
                '/indikator',
                arguments: {
                  'userId': userId,
                  'kegiatanId': kegiatanId,
                  'entryIds': entryIds, // Pass the list of entry IDs, can be null
                  'id_indikator': 2, // id_indikator for SDM Kesehatan
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
                '/indikator',
                arguments: {
                  'userId': userId,
                  'kegiatanId': kegiatanId,
                  'entryIds': entryIds, // Pass the list of entry IDs, can be null
                  'id_indikator': 3, // id_indikator for Program Kesehatan
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
                '/indikator',
                arguments: {
                  'userId': userId,
                  'kegiatanId': kegiatanId,
                  'entryIds': entryIds, // Pass the list of entry IDs, can be null
                  'id_indikator': 4, // id_indikator for Pembiayaan Kesehatan
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
