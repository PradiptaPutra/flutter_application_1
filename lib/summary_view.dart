import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SummaryView extends StatelessWidget {
  final List<Map<String, dynamic>> entries;

  SummaryView({required this.entries});

  int _calculateTotalScore(List<Map<String, dynamic>> entries) {
    int totalScore = 0;
    for (var entry in entries) {
      final score = entry['sebelum'];
      if (score != null && score is String && int.tryParse(score) != null) {
        totalScore += int.parse(score);
      }
    }
    return totalScore;
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> entries) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    
    sheet.getRangeByName('A1').setText('Puskesmas');
    sheet.getRangeByName('B1').setText('Indikator');
    sheet.getRangeByName('C1').setText('Sub Indikator');
    sheet.getRangeByName('D1').setText('Kriteria');
    sheet.getRangeByName('E1').setText('Sebelum');
    sheet.getRangeByName('F1').setText('Sesudah');
    sheet.getRangeByName('G1').setText('Keterangan');

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      sheet.getRangeByIndex(i + 2, 1).setText(entry['puskesmas'] ?? '');
      sheet.getRangeByIndex(i + 2, 2).setText(entry['indikator'] ?? '');
      sheet.getRangeByIndex(i + 2, 3).setText(entry['sub_indikator'] ?? '');
      sheet.getRangeByIndex(i + 2, 4).setText(entry['kriteria'] ?? '');
      sheet.getRangeByIndex(i + 2, 5).setText(entry['sebelum'] ?? '');
      sheet.getRangeByIndex(i + 2, 6).setText(entry['sesudah'] ?? '');
      sheet.getRangeByIndex(i + 2, 7).setText(entry['keterangan'] ?? '');
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/summary.xlsx');
    file.writeAsBytesSync(workbook.saveAsStream());
    workbook.dispose();

    print('Excel file saved at $path/summary.xlsx');
  }

  @override
  Widget build(BuildContext context) {
    final int totalScore = _calculateTotalScore(entries);

    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportToExcel(entries),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Score: $totalScore', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Puskesmas')),
                    DataColumn(label: Text('Indikator')),
                    DataColumn(label: Text('Sub Indikator')),
                    DataColumn(label: Text('Kriteria')),
                    DataColumn(label: Text('Sebelum')),
                    DataColumn(label: Text('Sesudah')),
                    DataColumn(label: Text('Keterangan')),
                  ],
                  rows: entries.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry['puskesmas'] ?? '')),
                      DataCell(Text(entry['indikator'] ?? '')),
                      DataCell(Text(entry['sub_indikator'] ?? '')),
                      DataCell(Text(entry['kriteria'] ?? '')),
                      DataCell(Text(entry['sebelum'] ?? '')),
                      DataCell(Text(entry['sesudah'] ?? '')),
                      DataCell(Text(entry['keterangan'] ?? '')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
