import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class ExportKendaraanScreen extends StatefulWidget {
  final String puskesmas;
  final double sebelumIndikator;
  final double sesudahIndikator;
  final String interpretasiSebelum;
  final String interpretasiSesudah;
  final String interpretasiAkhir;
  final int userId;
  final int? kegiatanId;
  final int totalKendaraan; // Add this line


  ExportKendaraanScreen({
    required this.puskesmas,
    required this.sebelumIndikator,
    required this.sesudahIndikator,
    required this.interpretasiSebelum,
    required this.interpretasiSesudah,
    required this.interpretasiAkhir,
    required this.userId,
    this.kegiatanId,
    required this.totalKendaraan, // Add this line

  });

  @override
  _ExportKendaraanScreenState createState() => _ExportKendaraanScreenState();
}

class _ExportKendaraanScreenState extends State<ExportKendaraanScreen> {
  String catatan = '';
  String upayaKegiatan = '';
  String estimasiBiaya = '';
  bool isConnected = false;
  String? emailPenerima;
  Uint8List? logoData;
  List<Map<String, dynamic>> detailedData = [];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchEmailPenerima();
    _loadLogo();
    _fetchDetailedData();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      setState(() {
        isConnected = true;
      });
    } else {
      setState(() {
        isConnected = false;
      });
    }
  }

  Future<void> _fetchEmailPenerima() async {
    final email = await DatabaseHelper().getEmailByUserId(widget.userId);
    setState(() {
      emailPenerima = email;
    });
  }

  Future<void> _loadLogo() async {
    final logo = await rootBundle.load('assets/images/logors.jpg');
    setState(() {
      logoData = logo.buffer.asUint8List();
    });
  }

  Future<void> _fetchDetailedData() async {
    if (widget.kegiatanId != null) {
      final dbHelper = DatabaseHelper();
      final data = await dbHelper.getEntriesByKegiatanIdAndCategoryAndUser(widget.kegiatanId!, 13, widget.userId); // Menyertakan kondisi kategori dan userId
      setState(() {
        detailedData = data;
      });
    }
  }

    Future<void> _openPdf(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error while opening PDF: $e');
      Fluttertoast.showToast(msg: 'Unable to open PDF. Please check if you have a PDF viewer installed.');
    }
  }

  Future<void> _sendEmail(String pdfPath, String recipient) async {
    final smtpServer = gmail('mtsalikhlasberbahh@gmail.com', 'oxtm hpkh ciiq ppan');

    final message = Message()
      ..from = Address('mtsalikhlasberbahh@gmail.com', 'Your Name')
      ..recipients.add(recipient)
      ..subject = 'Lampiran PDF'
      ..text = 'Silakan temukan lampiran PDF.'
      ..attachments.add(FileAttachment(File(pdfPath)));

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error while sending email: $e');
      Fluttertoast.showToast(msg: 'Failed to send email. Please try again later.');
    }
  }


  Future<void> _savePdf() async {
    if (logoData == null) {
      print('Logo not loaded');
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildSummary(),
          pw.SizedBox(height: 20),
          _buildDetailedTable(),
          pw.SizedBox(height: 20),
          _buildAdditionalInfo(),
        ],
      ),
    );

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Permission not granted');
        return;
      }

      final downloadsDir = Directory('/storage/emulated/0/Download');
      String fileName = 'Kendaraan_${widget.puskesmas}.pdf';

      if (widget.kegiatanId != null && widget.kegiatanId == 11) {
        fileName = 'Kendaraan_${widget.puskesmas}.pdf';
      }

      final pdfPath = path.join(downloadsDir.path, fileName);
      final pdfFile = File(pdfPath);

      await pdfFile.writeAsBytes(await pdf.save());
      print('PDF saved to $pdfPath');

      Fluttertoast.showToast(msg: 'PDF saved to $pdfPath');

      _openPdf(pdfPath);

      if (isConnected && emailPenerima != null) {
        await _sendEmail(pdfPath, emailPenerima!);
        Fluttertoast.showToast(msg: 'Email successfully sent');
      } else {
        print('Device is offline or email recipient not found. Email will be sent when online.');
      }
    } catch (e) {
      print('Error while saving PDF: $e');
    }
  }

  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Image(
          pw.MemoryImage(logoData!),
          width: 100,
          height: 100,
        ),
        pw.SizedBox(width: 20),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Puskesmas: ${widget.puskesmas}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Jl. Puskesmas No.123, Bangun Jaya, Kec. Bangun',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Telp: (021) 12345678 | Email: info@puskesmasbangunjaya.id',
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummary() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('Total Skor Sebelum: ${widget.sebelumIndikator}'),
        pw.Text('Total Skor Sesudah: ${widget.sesudahIndikator}'),
        pw.Text('Interpretasi Sebelum: ${widget.interpretasiSebelum ?? ''}'),
        pw.Text('Interpretasi Sesudah: ${widget.interpretasiSesudah ?? ''}'),
      ],
    );
  }

pw.Widget _buildDetailedTable() {
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      pw.TableRow(
        children: [
          _buildTableCell('Indikator', isHeader: true),
          _buildTableCell('Jumlah Kendaraan', isHeader: true),
          _buildTableCell('Sebelum', isHeader: true),
          _buildTableCell('Sesudah', isHeader: true),
          _buildTableCell('Keterangan', isHeader: true),
        ],
      ),
      ...detailedData.map((entry) => pw.TableRow(
        children: [
          _buildTableCell(entry['indikator'] ?? ''),
          _buildTableCell(entry['jumlah_kendaraan'] ?? ''),
          _buildTableCell(entry['sebelum'] ?? ''),
          _buildTableCell(entry['sesudah'] ?? ''),
          _buildTableCell(entry['keterangan'] ?? ''),
        ],
      )),
    ],
  );
}

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildAdditionalInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Additional Information', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('Catatan: $catatan'),
        pw.Text('Upaya / Kegiatan: $upayaKegiatan'),
        pw.Text('Estimasi Biaya: $estimasiBiaya'),
      ],
    );
  }

  // ... (rest of the methods remain the same)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export'),
      ),
      body: SingleChildScrollView(
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
                    Text('Total Skor Sebelum', style: TextStyle(fontSize: 18)),
                    Text(widget.sebelumIndikator.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Sebelum', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiSebelum,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Total Skor Sesudah', style: TextStyle(fontSize: 18)),
                    Text(widget.sesudahIndikator.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Sesudah', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiSesudah,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         SizedBox(height: 5),
                    Text('Interpretasi Akhir', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiAkhir,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePdf,
              child: Text('Save PDF'),
            ),
          ],
        ),
      ),
    );
  }
}