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
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  Future<List<Map<String, dynamic>>> _fetchKegiatan(bool ascending, String query) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.getKegiatanForUserSortedAndFiltered(widget.userId, ascending, query);
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

  void _searchKegiatan(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: const Color.fromARGB(137, 206, 203, 203)),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama Puskesmas disini...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    hintStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
                  ),
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  onChanged: (query) {
                    _searchKegiatan(query);
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _searchKegiatan(searchController.text);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _toggleSort,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchKegiatan(isAscending, searchQuery),
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
