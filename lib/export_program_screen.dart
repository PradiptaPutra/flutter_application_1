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

class ExportProgramScreen extends StatefulWidget {
  final String puskesmas;
  final int totalIndikator1;
  final int totalIndikator2;
  final int totalIndikator3; 
  final int totalIndikator4;
  final int totalOverall;
  final String interpretasiIndikator1;
  final String interpretasiIndikator2;
  final String interpretasiIndikator3;
  final String interpretasiIndikator4;
  final String interpretasiOverall;
  final int userId;
  final int? kegiatanId;

  ExportProgramScreen({
    required this.puskesmas,
    required this.totalIndikator1,
    required this.totalIndikator2,
    required this.totalIndikator3,
    required this.totalIndikator4,
    required this.totalOverall,
    required this.interpretasiIndikator1,
    required this.interpretasiIndikator2,
    required this.interpretasiIndikator3,
    required this.interpretasiIndikator4,
    required this.interpretasiOverall,
    required this.userId,
    this.kegiatanId,
  });

  @override
  _ExportProgramScreenState createState() => _ExportProgramScreenState();
}

class _ExportProgramScreenState extends State<ExportProgramScreen> {
  String catatan = '';
  String upayaKegiatan = '';
  String estimasiBiaya = '';
  bool isConnected = false;
  String? emailPenerima;
  Uint8List? logoData;
  List<Map<String, dynamic>> detailedData = [];
   File? backgroundImageFile;
List<Map<String, dynamic>> penggunaList = [];
   List<Map<String, dynamic>> kegiatanList = [];
   String lokasiKegiatan = '';
       bool _isEmailFieldVisible = false;
  TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchEmailPenerima();
    _loadLogo();
    _fetchDetailedData();
     _initializeBackgroundImage();
      _fetchLokasiKegiatan();
    _fetchAllPengguna();
    _fetchAllKegiatan();
  }

Future<void> _fetchAllPengguna() async {
  List<Map<String, dynamic>> pengguna = await DatabaseHelper().getAllPengguna(widget.userId);
  setState(() {
    penggunaList = pengguna;
  });

  // Print pengguna ke konsol debug
  print('Pengguna: $pengguna');
}
Future<void> _fetchAllKegiatan() async {
  List<Map<String, dynamic>> kegiatan = await DatabaseHelper().getAllKegiatan(widget.userId,widget.kegiatanId!); // Menyertakan kondisi kategori dan userId
  setState(() {
    kegiatanList = kegiatan;
  });

  // Print pengguna ke konsol debug
  print('Kegiatan: $kegiatan');
}


  Future<void> _fetchLokasiKegiatan() async {
    String lokasi = await DatabaseHelper().getLokasiKegiatan(widget.kegiatanId!);
    setState(() {
      lokasiKegiatan = lokasi;
    });
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

  Future<void> _initializeBackgroundImage() async {
  final imageFile = await _loadBackgroundImage();
  setState(() {
    backgroundImageFile = imageFile;
  });
}
 Future<File?> _loadBackgroundImage() async {
  if (widget.kegiatanId != null) {
    final dbHelper = DatabaseHelper();
    final imageFile = await dbHelper.getImageFileByKegiatanId(widget.kegiatanId!);
    if (imageFile != null) {
      return imageFile;
    }
  }
  return null;
}

  Future<void> _fetchEmailPenerima() async {
    final email = await DatabaseHelper().getEmailByUserId(widget.userId);
    setState(() {
      emailPenerima = email;
    });
  }

   Future<void> _loadLogo() async {
  if (widget.kegiatanId != null) {
    final dbHelper = DatabaseHelper();
    final imageData = await dbHelper.getImageByKegiatanId(widget.kegiatanId!);
    if (imageData != null) {
      setState(() {
        logoData = imageData;
      });
      return;
    }
  }
  final logo = await rootBundle.load('assets/images/logors.jpg');
  setState(() {
    logoData = logo.buffer.asUint8List();
  });
}

  Future<void> _fetchDetailedData() async {
    if (widget.kegiatanId != null) {
      final dbHelper = DatabaseHelper();
      final data = await dbHelper.getEntriesByKegiatanIdAndCategoryAndUser(widget.kegiatanId!, 3, widget.userId); // Menyertakan kondisi kategori dan userId
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
    setState(() {
      _isLoading = true;
      _statusMessage = 'Sending email...';
    });

    final smtpServer = gmail('mtsalikhlasberbahh@gmail.com', 'oxtm hpkh ciiq ppan');

    final message = Message()
      ..from = Address('anapanca@gmail.com', 'ANAPANCA admin ')
      ..recipients.add(recipient)
      ..subject = 'Lampiran PDF'
      ..text = 'Silakan temukan lampiran PDF.'
      ..attachments.add(FileAttachment(File(pdfPath)));

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
      setState(() {
        _statusMessage = 'Email successfully sent';
      });
      Fluttertoast.showToast(msg: 'Email successfully sent');
    } catch (e) {
      print('Error while sending email: $e');
      setState(() {
        _statusMessage = 'Failed to send email. Error: $e';
      });
      Fluttertoast.showToast(msg: 'Failed to send email. Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<String> _generatePdf() async {
  if (logoData == null) {
    print('Logo not loaded');
    return '';
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
    // Request storage permissions
    if (await Permission.storage.request().isGranted || await Permission.storage.request().isDenied) {
      final directoryPath = '/storage/emulated/0/Download';

      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String fileName = 'Program_${widget.puskesmas}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final pdfPath = '$directoryPath/$fileName';
      final pdfFile = File(pdfPath);

      if (await pdfFile.exists()) {
        await pdfFile.delete();
        print('Old PDF file deleted.');
      }

      await pdfFile.writeAsBytes(await pdf.save());
      print('PDF saved to $pdfPath');

      return pdfPath;
    } else {
      print('Permission denied');
      Fluttertoast.showToast(msg: 'Permission denied to access storage.');
      return '';
    }
  } catch (e) {
    print('Error while generating PDF: $e');
    Fluttertoast.showToast(msg: 'Failed to generate PDF. Please try again.');
    return '';
  }
}

  Future<void> _savePdf() async {
    final pdfPath = await _generatePdf();
    if (pdfPath.isNotEmpty) {
      Fluttertoast.showToast(msg: 'PDF saved to $pdfPath');
      
      await Future.delayed(Duration(seconds: 2));
_openPdf(pdfPath);
    }
  }

  Future<void> _sendPdfByEmail() async {
    if (_emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a recipient email address');
      return;
    }

    final pdfPath = await _generatePdf();
    if (pdfPath.isNotEmpty) {
       await _sendEmail(pdfPath, _emailController.text.trim()); // Trim spasi di awal dan akhir email
    }
  }

  pw.Widget _buildHeader() {
  if (penggunaList.isEmpty) {
    // Handle case when penggunaList is empty
    return pw.Text('Data Pengguna Kosong');
  }

  Map<String, dynamic> pengguna = penggunaList.first;
  Map<String, dynamic> kegiatan = kegiatanList.first;
  

  return pw.Row(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Image(
        pw.MemoryImage(logoData!),
        width: 250,
        height: 150,
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
            'Alamat Puskesmas: $lokasiKegiatan',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Non/Rawat inap : ${kegiatan['dropdown_option'] ?? 'Belum Tersedia'}\nProvinsi : ${kegiatan['provinsi'] ?? 'Belum Tersedia'}\nKabupaten / Kota : ${kegiatan['kabupaten_kota'] ?? 'Belum Tersedia'}\nTanggal Survei : ${kegiatan['tanggal_kegiatan'] ?? 'Belum Tersedia'}',
            style: pw.TextStyle(fontSize: 12),
          ),
           pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8.0), // Margin antara garis dengan teks
      height: 2.0,
      width: 350.0,
      color: PdfColors.black, // Warna garis
    ),
          pw.Text(
            'Nama Surveyor : ${pengguna['name'] ?? 'Belum Tersedia'}\nJabatan Pengguna : ${pengguna['position'] ?? 'Belum Tersedia'}\nNo Telepon Pengguna : ${pengguna['phone'] ?? 'Belum Tersedia'}\nEmail Pengguna : ${pengguna['email'] ?? 'Belum Tersedia'}',
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
        pw.Text('Total Indikator 1: ${widget.totalIndikator1}'),
        pw.Text('Total Indikator 2: ${widget.totalIndikator2}'),
        pw.Text('Total Indikator 3: ${widget.totalIndikator3}'),
        pw.Text('Total Indikator 4: ${widget.totalIndikator4}'),
        pw.Text('Total Keseluruhan: ${widget.totalOverall}'),
        pw.Text('Interpretasi Indikator 1: ${widget.interpretasiIndikator1 ?? ''}'),
        pw.Text('Interpretasi Indikator 2: ${widget.interpretasiIndikator2 ?? ''}'),
        pw.Text('Interpretasi Indikator 3: ${widget.interpretasiIndikator3 ?? ''}'),
        pw.Text('Interpretasi Indikator 4: ${widget.interpretasiIndikator4 ?? ''}'),
        pw.Text('Interpretasi Keseluruhan: ${widget.interpretasiOverall ?? ''}'),
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
            _buildTableCell('Sub Indikator', isHeader: true),
            _buildTableCell('Kriteria', isHeader: true),
            _buildTableCell('Indikator 1', isHeader: true),
            _buildTableCell('Indikator 2', isHeader: true),
            _buildTableCell('Indikator 3', isHeader: true),
            _buildTableCell('Indikator 4', isHeader: true),
            _buildTableCell('Keterangan', isHeader: true),
          ],
        ),
        ...detailedData.map((entry) => pw.TableRow(
          children: [
            _buildTableCell(entry['indikator']?? ''),
            _buildTableCell(entry['sub_indikator']?? ''),
            _buildTableCell(entry['kriteria']?? ''),
            _buildTableCell(entry['indikator1']?? ''),
            _buildTableCell(entry['indikator2']?? ''),
            _buildTableCell(entry['indikator3']?? ''),
            _buildTableCell(entry['indikator4']?? ''),
            _buildTableCell(entry['keterangan']?? ''),
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
          backgroundImageFile != null
              ? CircleAvatar(
                  radius: 40,
                  backgroundImage: FileImage(backgroundImageFile!),
                )
              : CircleAvatar(
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
                    Text('Total Indikator 1', style: TextStyle(fontSize: 18)),
                    Text(widget.totalIndikator1.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 1', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator1,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Total Indikator 2', style: TextStyle(fontSize: 18)),
                    Text(widget.totalIndikator2.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 2', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator2,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Total Indikator 3', style: TextStyle(fontSize: 18)),
                    Text(widget.totalIndikator3.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 3', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator3,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         Text('Total Indikator 4', style: TextStyle(fontSize: 18)),
                    Text(widget.totalIndikator4.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 4', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator4,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Total Keseluruhan ', style: TextStyle(fontSize: 18)),
                    Text(widget.totalOverall.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Keseluruhan', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiOverall,
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
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEmailFieldVisible = !_isEmailFieldVisible;
                });
              },
              child: Text('Send to Email'),
            ),
            if (_isEmailFieldVisible)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter recipient email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            if (_isEmailFieldVisible)
              ElevatedButton(
                onPressed: _sendPdfByEmail,
                child: Text('Send'),
              ),
            if (_isLoading)
              CircularProgressIndicator(),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(color: _statusMessage.contains('Failed') ? Colors.red : Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
