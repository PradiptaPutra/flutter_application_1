import 'package:flutter/material.dart';
import 'penilaian_screen.dart'; // Pastikan Anda telah mengimport screen yang dituju

class IndikatorScreen extends StatelessWidget {
  final int userId;
  final int? kegiatanId;
  final int id_indikator;
  final List<int>? entryIds;  // Tambahkan entryIds sebagai parameter nullable

  IndikatorScreen({required this.userId, this.kegiatanId, required this.id_indikator, this.entryIds});

  @override
  Widget build(BuildContext context) {
     print('kegiatanId: $kegiatanId');
    return Scaffold(
      appBar: AppBar(
        title: Text("Indikator Penilaian"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter logic
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari Indikator",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 6, // Number of items
              itemBuilder: (context, index) {
                // Replace with your actual data
                var indikatorData = [
                  {"name": "Sistem Vertikal Bangunan Lebih dari Satu Lantai"},
                  {"name": "Sistem Sanitasi"},
                  {"name": "Sistem Kelistrikan"},
                  {"name": "Sistem Komunikasi"},
                  {"name": "Sistem Gas Medik"},
                  {"name": "Sistem K3 Fasyankes"},
                ];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue, // Customize as needed
                    child: Icon(Icons.local_hospital, color: Colors.white),
                  ),
                  title: Text(indikatorData[index]["name"]!),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PenilaianScreen(
                          kegiatanId: kegiatanId,
                          id_indikator: id_indikator,
                          userId: userId,
                          entryId: entryIds != null && entryIds!.isNotEmpty ? entryIds![index] : null, // Pass entryId if available
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ],
      ),
    );
  }
}
