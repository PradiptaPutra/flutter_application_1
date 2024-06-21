import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'database_helper.dart';
import 'category_selection_screen.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;

  HistoryScreen({required this.userId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DatabaseHelper dbHelper;
  List<Map<String, dynamic>> kegiatanList = [];
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _fetchAndSortKegiatan();
  }

  Future<void> _fetchAndSortKegiatan() async {
    var fetchedList = await dbHelper.getKegiatanForUser(widget.userId);
    setState(() {
      kegiatanList = fetchedList;
      _sortList();
    });
  }

  void _sortList() {
    kegiatanList.sort((a, b) {
      DateTime? dateA = _parseDate(a['tanggal_kegiatan']);
      DateTime? dateB = _parseDate(b['tanggal_kegiatan']);
      if (dateA == null || dateB == null) return 0;
      return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }
    DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // Try parsing with different formats
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        return DateFormat('dd-MM-yyyy').parse(dateString);
      } catch (_) {
        try {
          return DateFormat('MM/dd/yyyy').parse(dateString);
        } catch (_) {
          print("Unable to parse date: $dateString");
          return null;
        }
      }
    }
  }

  Future<void> _deleteKegiatan(int kegiatanId, String namaPuskesmas) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus"),
          content: Text("Apakah Anda yakin ingin menghapus data untuk $namaPuskesmas?"),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Hapus"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await dbHelper.deleteKegiatan(kegiatanId);
      await dbHelper.deleteDataEntriesForKegiatan(kegiatanId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data untuk $namaPuskesmas telah dihapus")),
      );
      _fetchAndSortKegiatan();
    }
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
            onPressed: () {
              setState(() {
                isAscending = !isAscending;
                _sortList();
              });
            },
          )
        ],
      ),
      body: ListView.separated(
        itemCount: kegiatanList.length,
        itemBuilder: (context, index) {
          var kegiatan = kegiatanList[index];
          return Dismissible(
            key: Key(kegiatan['kegiatan_id'].toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteKegiatan(kegiatan['kegiatan_id'], kegiatan['nama_puskesmas']);
            },
            child: Column(
              children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFFF7043),
                      child: Icon(Icons.local_hospital, color: Colors.white),
                    ),
                    title: Text(kegiatan['nama_puskesmas'] ?? 'Unknown'),
                    subtitle: Text("${_formatDate(kegiatan['tanggal_kegiatan'])} - ${kegiatan['dropdown_option']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        ),
                        GestureDetector(
                          onTap: () {
                            _deleteKegiatan(kegiatan['kegiatan_id'], kegiatan['nama_puskesmas']);
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
                  ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown Date';
    DateTime? date = _parseDate(dateString);
    if (date == null) return dateString; // Return original string if parsing fails
    return DateFormat('dd MMM yyyy').format(date);
  }
}