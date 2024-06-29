// import 'package:flutter/material.dart';
// import 'database_helper.dart';
// import 'questions.dart';  // Import the questions list
// import 'data_list_view.dart';
// import 'summary_view.dart';

// class DataEntryForm extends StatefulWidget {
//   final int userId;

//   DataEntryForm({required this.userId});

//   @override
//   _DataEntryFormState createState() => _DataEntryFormState();
// }

// class _DataEntryFormState extends State<DataEntryForm> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _puskesmasController = TextEditingController();
//   final Map<String, TextEditingController> _sebelumControllers = {};
//   final Map<String, TextEditingController> _sesudahControllers = {};
//   final Map<String, TextEditingController> _keteranganControllers = {};
//   List<Question> questions = [];
//   bool _isLoading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadQuestions();
//   }

//   Future<void> _loadQuestions() async {
//     try {
//       List<Question> loadedQuestions = await loadQuestionsFromExcel();
//       setState(() {
//         questions = loadedQuestions;
//         for (var question in questions) {
//           _sebelumControllers[question.no] = TextEditingController();
//           _sesudahControllers[question.no] = TextEditingController();
//           _keteranganControllers[question.no] = TextEditingController();
//         }
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _submitData() async {
//     for (var question in questions) {
//       Map<String, dynamic> data = {
//         'user_id': widget.userId,
//         'puskesmas': _puskesmasController.text,
//         'indikator': question.indikator,
//         'sub_indikator': question.subIndikator,
//         'kriteria': question.kriteria,
//         'sebelum': _sebelumControllers[question.no]?.text ?? '',
//         'sesudah': _sesudahControllers[question.no]?.text ?? '',
//         'keterangan': _keteranganControllers[question.no]?.text ?? '',
//       };
//       await _dbHelper.insertDataEntry(data);
//     }
//     _clearFormFields();
//   }

//   void _clearFormFields() {
//     _puskesmasController.clear();
//     for (var controller in _sebelumControllers.values) {
//       controller.clear();
//     }
//     for (var controller in _sesudahControllers.values) {
//       controller.clear();
//     }
//     for (var controller in _keteranganControllers.values) {
//       controller.clear();
//     }
//   }

//   void _viewData() async {
//     List<Map<String, dynamic>> entries = await _dbHelper.getDataEntriesForUser(widget.userId);
//     Navigator.push(context, MaterialPageRoute(builder: (context) => DataListView(entries: entries)));
//   }

//   void _viewSummary() async {
//     List<Map<String, dynamic>> entries = await _dbHelper.getDataEntriesForUser(widget.userId);
//     Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryView(entries: entries)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Data Entry Form"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () {
//               Navigator.pushNamed(context, '/profile');
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.assessment),
//             onPressed: _viewSummary,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : _error != null
//                 ? Center(child: Text('Error: $_error'))
//                 : Column(
//                     children: [
//                       TextFormField(
//                         controller: _puskesmasController,
//                         decoration: InputDecoration(labelText: 'Puskesmas'),
//                       ),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: DataTable(
//                             columnSpacing: 20,
//                             columns: [
//                               DataColumn(label: Text('No')),
//                               DataColumn(label: Text('Indikator')),
//                               DataColumn(label: Text('Sub Indikator')),
//                               DataColumn(label: Text('Kriteria')),
//                               DataColumn(label: Text('Sebelum')),
//                               DataColumn(label: Text('Sesudah')),
//                               DataColumn(label: Text('Keterangan')),
//                             ],
//                             rows: questions.map((question) {
//                               return DataRow(cells: [
//                                 DataCell(Container(width: 30, child: Text(question.no))),
//                                 DataCell(Container(width: 150, child: Text(question.indikator))),
//                                 DataCell(Container(width: 150, child: Text(question.subIndikator))),
//                                 DataCell(Container(width: 300, child: Text(question.kriteria, overflow: TextOverflow.ellipsis))),
//                                 DataCell(Container(width: 60, child: TextFormField(controller: _sebelumControllers[question.no]))),
//                                 DataCell(Container(width: 60, child: TextFormField(controller: _sesudahControllers[question.no]))),
//                                 DataCell(Container(width: 100, child: TextFormField(controller: _keteranganControllers[question.no]))),
//                               ]);
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: _submitData,
//                             child: Text('Submit'),
//                           ),
//                           ElevatedButton(
//                             onPressed: _viewData,
//                             child: Text('View Saved Data'),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         "Total Skor",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         "(Total Skor x 4.15)",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text("Interpretasi Akhir Indikator Bangunan Fasyankes Memasuki Masa Pemulihan"),
//                       Text("Tinggi / Aman: >65"),
//                       Text("Sedang / Kurang Aman: 20 - 65"),
//                       Text("Rendah / Tidak Aman: <20"),
//                     ],
//                   ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _puskesmasController.dispose();
//     for (var controller in _sebelumControllers.values) {
//       controller.dispose();
//     }
//     for (var controller in _sesudahControllers.values) {
//       controller.dispose();
//     }
//     for (var controller in _keteranganControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
