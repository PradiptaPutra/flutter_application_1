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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Tambahkan import ini
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
  final int? kegiatanId; // Tambahkan kegiatanId di sini

  ExportKendaraanScreen({
    required this.puskesmas,
    required this.sebelumIndikator,
    required this.sesudahIndikator,
    required this.interpretasiSebelum,
    required this.interpretasiSesudah,
    required this.interpretasiAkhir,
    required this.userId,
    this.kegiatanId, // Tambahkan kegiatanId di sini
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

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchEmailPenerima();
    _loadLogo();
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

  Future<void> _savePdf() async {
    if (logoData == null) {
      print('Logo not loaded');
      return;
    }

    final pdf = pw.Document();

    // Add metadata
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kop surat
              pw.Row(
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
                        ('Puskesmas: ${widget.puskesmas}'),
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
              ),
              pw.Divider(),
              // Isi surat
              pw.Header(
                level: 1,
                text: 'Data Export',
              ),
              pw.Text('Puskesmas: ${widget.puskesmas}'),
              pw.Text('Indikator Sebelum: ${widget.sebelumIndikator}'),
              pw.Text('Indikator Sesudah: ${widget.sesudahIndikator}'),
              pw.Text('Interpretasi Sebelum: ${widget.interpretasiSebelum}'),
              pw.Text('Interpretasi Sesudah: ${widget.interpretasiSesudah}'),
              pw.Text('Interpretasi Akhir: ${widget.interpretasiAkhir}'),
              pw.Text('Catatan: $catatan'),
              pw.Text('Upaya / Kegiatan: $upayaKegiatan'),
              pw.Text('Estimasi Biaya: $estimasiBiaya'),
            ],
          );
        },
      ),
    );

    try {
    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Permission not granted');
      return;
    }

    // Get the Downloads directory
    final downloadsDir = Directory('/storage/emulated/0/Download');
    String fileName = 'Kendaraan_${widget.puskesmas}.pdf'; // Default file name format

    // Update file name if id_category equals 11
    if (widget.kegiatanId != null && widget.kegiatanId == 13) {
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

  Future<void> _sendEmail(String pdfPath, String recipient) async {
    final smtpServer = gmail('mtsalikhlasberbahh@gmail.com', 'oxtm hpkh ciiq ppan'); // Use your email and password

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
    }
  }

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
                    Text('Indikator Sebelum', style: TextStyle(fontSize: 18)),
                    Text(widget.sebelumIndikator.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiSebelum,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('Indikator Sesudah', style: TextStyle(fontSize: 18)),
                    Text(widget.sesudahIndikator.toString(),
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
            Column(
              children: [
                Text('Interpretasi Akhir', style: TextStyle(fontSize: 18)),
                Text(widget.interpretasiAkhir,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
