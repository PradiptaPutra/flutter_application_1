import 'package:flutter/services.dart';
import 'package:excel/excel.dart';

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
  final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  final Excel excel = Excel.decodeBytes(bytes);
  
  final List<Question> questions = [];
  final Sheet? sheet = excel.tables[excel.tables.keys.first];
  if (sheet != null) {
    for (int row = 1; row < sheet.maxRows; row++) {
      final List<Data?> rowData = sheet.row(row);
      final String no = rowData[0]?.value.toString() ?? '';
      final String indikator = rowData[1]?.value.toString() ?? '';
      final String subIndikator = rowData[2]?.value.toString() ?? '';
      final String kriteria = rowData[3]?.value.toString() ?? '';

      questions.add(Question(
        no: no,
        indikator: indikator,
        subIndikator: subIndikator,
        kriteria: kriteria,
      ));
    }
  }
  return questions;
}
