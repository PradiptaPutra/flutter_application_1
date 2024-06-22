import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'category_selection_screen.dart'; // Import the CategorySelectionScreen

class HistoryScreen extends StatefulWidget {
  final int userId;

  HistoryScreen({required this.userId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isAscending = true;

  Future<List<Map<String, dynamic>>> _fetchKegiatan(bool ascending) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.getKegiatanForUserSorted(widget.userId, ascending);
  }

  Future<void> _deleteKegiatan(int kegiatanId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deleteKegiatan(kegiatanId);
    await dbHelper.deleteDataEntriesForKegiatan(kegiatanId);
    setState(() {
      // Trigger a rebuild to refresh the data
    });
  }

  Future<void> _confirmDelete(BuildContext context, int kegiatanId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus"),
          content: Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Tidak"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Ya"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteKegiatan(kegiatanId);
      // No need to pop the screen after deletion
      setState(() {
        // Trigger a rebuild to refresh the data
      });
    }
  }

  void _toggleSort() {
    setState(() {
      isAscending = !isAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("History Penilaian"),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _toggleSort,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchKegiatan(isAscending),
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
                    backgroundColor: Color(0xFFFF7043),
                    child: Icon(Icons.local_hospital, color: Colors.white),
                  ),
                  title: Text(kegiatan['nama_puskesmas'] ?? 'Unknown'),
                  subtitle: Text("${kegiatan['tanggal_kegiatan']} - ${kegiatan['dropdown_option']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.arrow_forward_ios),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await _confirmDelete(context, kegiatan['kegiatan_id']);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategorySelectionScreen(
                          userId: widget.userId,
                          kegiatanId: kegiatan['kegiatan_id'],
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
