import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportScreen extends StatefulWidget {
  final String puskesmas;
  final int sebelum;
  final int sesudah;
  final String interpretasiSebelum;
  final String interpretasiSesudah;

  ExportScreen({
    required this.puskesmas,
    required this.sebelum,
    required this.sesudah,
    required this.interpretasiSebelum,
    required this.interpretasiSesudah,
  });

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String catatan = '';
  String upayaKegiatan = '';
  String estimasiBiaya = '';

  Future<void> _savePdf() async {
    final pdf = pw.Document();

    // Add metadata
    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              text: 'Data Export',
            ),
            pw.Text('Puskesmas: ${widget.puskesmas}'),
            pw.Text('Sebelum: ${widget.sebelum}'),
            pw.Text('Sesudah: ${widget.sesudah}'),
            pw.Text('Interpretasi Sebelum: ${widget.interpretasiSebelum}'),
            pw.Text('Interpretasi Sesudah: ${widget.interpretasiSesudah}'),
            pw.Text('Catatan: $catatan'),
            pw.Text('Upaya / Kegiatan: $upayaKegiatan'),
            pw.Text('Estimasi Biaya: $estimasiBiaya'),
          ],
        );
      },
    ));

    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('Error: External storage directory not available');
        return;
      }

      final pdfPath = '${directory.path}/exsport.pdf';
      final pdfFile = File(pdfPath);

      await pdfFile.writeAsBytes(await pdf.save());
      print('PDF saved to $pdfPath');

      _openPdf(pdfPath);
    } catch (e) {
      print('Error while saving PDF: $e');
    }
  }

  void _openPdf(String filePath) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        OpenFile.open(file.path);
      } else {
        print('User canceled the file picking');
      }
    } catch (e) {
      print('Error while picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/bgsplash.png'),
            ),
            SizedBox(height: 10),
            Text(
              widget.puskesmas,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Sebelum', style: TextStyle(fontSize: 18)),
                    Text(widget.sebelum.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiSebelum,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('Sesudah', style: TextStyle(fontSize: 18)),
                    Text(widget.sesudah.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiSesudah,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      title: Text('Catatan:'),
                      subtitle: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            catatan = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Upaya / Kegiatan:'),
                      subtitle: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            upayaKegiatan = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Estimasi Biaya:'),
                      subtitle: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            estimasiBiaya = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _savePdf,
              child: Text('Save as PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
