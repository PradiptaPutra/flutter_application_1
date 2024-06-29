// import 'package:flutter/material.dart';

// class DataListView extends StatefulWidget {
//   final List<Map<String, dynamic>> entries;

//   DataListView({required this.entries});

//   @override
//   _DataListViewState createState() => _DataListViewState();
// }

// class _DataListViewState extends State<DataListView> {
//   List<Map<String, dynamic>> filteredEntries = [];
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     filteredEntries = widget.entries;
//     searchController.addListener(_filterEntries);
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   void _filterEntries() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredEntries = widget.entries.where((entry) {
//         return entry.values.any((value) =>
//           value != null && value.toString().toLowerCase().contains(query));
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('View Data'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.search),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.all(8.0),
//               itemCount: filteredEntries.length,
//               itemBuilder: (context, index) {
//                 final entry = filteredEntries[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(vertical: 10.0),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Puskesmas: ${entry['puskesmas'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
//                         SizedBox(height: 8),
//                         Text('Indikator: ${entry['indikator'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
//                         SizedBox(height: 8),
//                         Text('Sub Indikator: ${entry['sub_indikator'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
//                         SizedBox(height: 8),
//                         Text('Kriteria: ${entry['kriteria'] ?? ''}'),
//                         SizedBox(height: 8),
//                         Text('Skor: ${entry['skor'] ?? ''}'),
//                         SizedBox(height: 8),
//                         Text('Sebelum: ${entry['sebelum'] ?? ''}'),
//                         SizedBox(height: 8),
//                         Text('Sesudah: ${entry['sesudah'] ?? ''}'),
//                         SizedBox(height: 8),
//                         Text('Keterangan: ${entry['keterangan'] ?? ''}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
