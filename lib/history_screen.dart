import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'penilaian_screen.dart';

class HistoryScreen extends StatelessWidget {
  final int userId;

  HistoryScreen({required this.userId});

  Future<List<Map<String, dynamic>>> _fetchKegiatan() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.getKegiatanForUser(userId);
  }

  Future<List<int>> _fetchEntryIdsForKegiatan(int kegiatanId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final dataEntries = await dbHelper.getDataEntriesForUser(userId);
    return dataEntries
        .where((entry) => entry['kegiatan_id'] == kegiatanId)
        .map<int>((entry) => entry['entry_id'])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("History Penilaian"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Placeholder for filter logic
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchKegiatan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data found"));
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var kegiatan = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.local_hospital, color: Colors.white),
                  ),
                  title: Text(kegiatan['nama_puskesmas'] ?? 'Unknown'),
                  subtitle: Text("${kegiatan['tanggal_kegiatan']} - ${kegiatan['dropdown_option']}"),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final entryIds = await _fetchEntryIdsForKegiatan(kegiatan['kegiatan_id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PenilaianScreen(
                          userId: userId,
                          kegiatanId: kegiatan['kegiatan_id'],
                          id_indikator: 1, // Adjust this based on your logic
                          entryId: entryIds.isNotEmpty ? entryIds.first : null,
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(),
            );
          }
        },
      ),
    );
  }
}
