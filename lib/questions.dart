import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'dart:typed_data';

class Question {
  final String no;
  final String indikator;
  final String subIndikator;
  final String kriteria;

  Question({
    required this.no,
    required this.indikator,
    required this.subIndikator,
    required this.kriteria,
  });
}

Future<List<Question>> loadQuestionsFromExcel() async {
  final ByteData data = await rootBundle.load('assets/Form Penilaian.xlsx');
  final Uint8List bytes = data.buffer.asUint8List();
  
  var excel = Excel.decodeBytes(bytes);

  List<Question> questions = [];

  for (var table in excel.tables.keys) {
    if (excel.tables[table] != null) {
      for (var row in excel.tables[table]!.rows.skip(1)) { // Skip header row
        questions.add(Question(
          no: row[0]?.value.toString() ?? '',
          indikator: row[1]?.value.toString() ?? '',
          subIndikator: row[2]?.value.toString() ?? '',
          kriteria: row[3]?.value.toString() ?? '',
        ));
      }
    }
  }

  return questions;
}
