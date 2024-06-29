// import 'package:flutter/material.dart';

// class DataSummaryView extends StatelessWidget {
//   final List<Map<String, dynamic>> entries;

//   DataSummaryView({required this.entries});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Data Summary'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columns: [
//                   DataColumn(label: Text('Puskesmas')),
//                   DataColumn(label: Text('Indikator')),
//                   DataColumn(label: Text('Sub Indikator')),
//                   DataColumn(label: Text('Kriteria')),
//                   DataColumn(label: Text('Sebelum')),
//                   DataColumn(label: Text('Sesudah')),
//                   DataColumn(label: Text('Keterangan')),
//                 ],
//                 rows: entries.map((entry) {
//                   return DataRow(cells: [
//                     DataCell(Text(entry['puskesmas'] ?? '')),
//                     DataCell(Text(entry['indikator'] ?? '')),
//                     DataCell(Text(entry['sub_indikator'] ?? '')),
//                     DataCell(Text(entry['kriteria'] ?? '')),
//                     DataCell(Text(entry['sebelum'] ?? '')),
//                     DataCell(Text(entry['sesudah'] ?? '')),
//                     DataCell(Text(entry['keterangan'] ?? '')),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
