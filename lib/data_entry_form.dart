import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'questions.dart';
import 'data_list_view.dart';
import 'summary_view.dart';

class DataEntryForm extends StatefulWidget {
  final int userId;

  DataEntryForm({required this.userId});

  @override
  _DataEntryFormState createState() => _DataEntryFormState();
}

class _DataEntryFormState extends State<DataEntryForm> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _puskesmasController = TextEditingController();
  final Map<String, TextEditingController> _sebelumControllers = {};
  final Map<String, TextEditingController> _sesudahControllers = {};
  final Map<String, TextEditingController> _keteranganControllers = {};

  @override
  void initState() {
    super.initState();
    for (var question in questions) {
      _sebelumControllers[question.no] = TextEditingController();
      _sesudahControllers[question.no] = TextEditingController();
      _keteranganControllers[question.no] = TextEditingController();
    }
  }

  Future<void> _submitData() async {
    for (var question in questions) {
      Map<String, dynamic> data = {
        'user_id': widget.userId,
        'puskesmas': _puskesmasController.text,
        'indikator': question.indikator,
        'sub_indikator': question.subIndikator,
        'kriteria': question.kriteria,
        'sebelum': _sebelumControllers[question.no]?.text ?? '',
        'sesudah': _sesudahControllers[question.no]?.text ?? '',
        'keterangan': _keteranganControllers[question.no]?.text ?? '',
      };
      await _dbHelper.insertDataEntry(data);
      print('Inserted entry: $data');
    }
    print('All data submitted');
    _clearFormFields();
  }

  void _clearFormFields() {
    _puskesmasController.clear();
    for (var controller in _sebelumControllers.values) {
      controller.clear();
    }
    for (var controller in _sesudahControllers.values) {
      controller.clear();
    }
    for (var controller in _keteranganControllers.values) {
      controller.clear();
    }
  }

  void _viewData() async {
    List<Map<String, dynamic>> entries = await _dbHelper.getDataEntriesForUser(widget.userId);
    print('Entries retrieved: $entries');  // Debug statement to print entries
    Navigator.push(context, MaterialPageRoute(builder: (context) => DataListView(entries: entries)));
  }

  void _viewSummary() async {
    List<Map<String, dynamic>> entries = await _dbHelper.getDataEntriesForUser(widget.userId);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryView(entries: entries)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Entry Form"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.assessment),
            onPressed: _viewSummary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _puskesmasController,
              decoration: InputDecoration(labelText: 'Puskesmas'),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Indikator')),
                  DataColumn(label: Text('Sub Indikator')),
                  DataColumn(label: Text('Kriteria')),
                  DataColumn(label: Text('Sebelum')),
                  DataColumn(label: Text('Sesudah')),
                  DataColumn(label: Text('Keterangan')),
                ],
                rows: questions.map((question) {
                  return DataRow(cells: [
                    DataCell(Text(question.no)),
                    DataCell(Text(question.indikator)),
                    DataCell(Text(question.subIndikator)),
                    DataCell(Text(question.kriteria)),
                    DataCell(TextFormField(controller: _sebelumControllers[question.no], decoration: InputDecoration())),
                    DataCell(TextFormField(controller: _sesudahControllers[question.no], decoration: InputDecoration())),
                    DataCell(TextFormField(controller: _keteranganControllers[question.no], decoration: InputDecoration())),
                  ]);
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Submit'),
            ),
            ElevatedButton(
              onPressed: _viewData,
              child: Text('View Saved Data'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _puskesmasController.dispose();
    for (var controller in _sebelumControllers.values) {
      controller.dispose();
    }
    for (var controller in _sesudahControllers.values) {
      controller.dispose();
    }
    for (var controller in _keteranganControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
