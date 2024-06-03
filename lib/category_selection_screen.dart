import 'package:flutter/material.dart';
import 'indikator_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  final int userId;
  final int? kegiatanId;  // Tambahkan tanda tanya untuk nullable

  // Sesuaikan konstruktor untuk menerima kegiatanId
  CategorySelectionScreen({required this.userId, this.kegiatanId});

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
                    '/indikator',
                    arguments: {'userId': userId, 'kegiatanId': kegiatanId},
                  );
                },
              ),
              ListTile(
                title: Text('Alat Kesehatan'),
                onTap: () {
                  // Implementasikan navigasi atau aksi lain
                },
              ),
              ListTile(
                title: Text('Kendaraan'),
                onTap: () {
                  // Implementasikan navigasi atau aksi lain
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
              // Navigasi ke layar lain
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Theme.of(context).primaryColor),
            title: Text('Program Kesehatan'),
            subtitle: Text('Deskripsi singkat'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigasi ke layar lain
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: Theme.of(context).primaryColor),
            title: Text('Pembiayaan Kesehatan'),
            subtitle: Text('Deskripsi singkat'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigasi ke layar lain
            },
          ),
        ],
      ),
    );
  }
}
