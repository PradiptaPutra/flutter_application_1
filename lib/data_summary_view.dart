import 'package:flutter/material.dart';

class DataSummaryView extends StatefulWidget {
  final List<Map<String, dynamic>> entries;

  DataSummaryView({required this.entries});

  @override
  _DataSummaryViewState createState() => _DataSummaryViewState();
}

class _DataSummaryViewState extends State<DataSummaryView> {
  List<Map<String, dynamic>> filteredEntries = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredEntries = widget.entries;
    searchController.addListener(_filterEntries);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterEntries() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredEntries = widget.entries.where((entry) {
        return entry.values.any((value) =>
          value != null && value.toString().toLowerCase().contains(query));
      }).toList();
    });
  }

  int _calculateTotalScore() {
    int totalScore = 0;
    for (var entry in filteredEntries) {
      if (entry['sebelum'] != null && entry['sesudah'] != null) {
        totalScore += int.tryParse(entry['sebelum']) ?? 0;
        totalScore += int.tryParse(entry['sesudah']) ?? 0;
      }
    }
    return totalScore;
  }

  @override
  Widget build(BuildContext context) {
    int totalScore = _calculateTotalScore();

    return Scaffold(
      appBar: AppBar(
        title: Text('View Data'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: [
                  DataColumn(label: Text('Puskesmas')),
                  DataColumn(label: Text('Indikator')),
                  DataColumn(label: Text('Sub Indikator')),
                  DataColumn(label: Text('Kriteria')),
                  DataColumn(label: Text('Sebelum')),
                  DataColumn(label: Text('Sesudah')),
                  DataColumn(label: Text('Keterangan')),
                ],
                rows: filteredEntries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Container(width: 200, child: Text(entry['puskesmas'] ?? ''))),
                    DataCell(Container(width: 200, child: Text(entry['indikator'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Container(width: 200, child: Text(entry['sub_indikator'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Container(width: 400, child: Text(entry['kriteria'] ?? '', maxLines: 5, overflow: TextOverflow.ellipsis))),
                    DataCell(Container(width: 100, child: Text(entry['sebelum'] ?? ''))),
                    DataCell(Container(width: 100, child: Text(entry['sesudah'] ?? ''))),
                    DataCell(Container(width: 200, child: Text(entry['keterangan'] ?? ''))),
                  ]);
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Skor: $totalScore", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("(Total Skor x 4.15)", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Interpretasi Akhir Indikator Bangunan Fasyankes Memasuki Masa Pemulihan"),
                Text("Tinggi / Aman: >65"),
                Text("Sedang / Kurang Aman: 20 - 65"),
                Text("Rendah / Tidak Aman: <20"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
