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
import 'dart:typed_data';

class ExportAlkesScreen extends StatefulWidget {
  final String puskesmas;
  final double sebelumIndikator1;
  final double sebelumIndikator2;
  final double sesudahIndikator1;
  final double sesudahIndikator2;
  final String interpretasiIndikator1Sebelum;
  final String interpretasiIndikator2Sebelum;
  final String interpretasiIndikator1Sesudah;
  final String interpretasiIndikator2Sesudah;
  final String interpretasiAkhir;
  final int userId;
  final int? kegiatanId;

  ExportAlkesScreen({
    required this.puskesmas,
    required this.sebelumIndikator1,
    required this.sebelumIndikator2,
    required this.sesudahIndikator1,
    required this.sesudahIndikator2,
    required this.interpretasiIndikator1Sebelum,
    required this.interpretasiIndikator2Sebelum,
    required this.interpretasiIndikator1Sesudah,
    required this.interpretasiIndikator2Sesudah,
    required this.interpretasiAkhir,
    required this.userId,
    this.kegiatanId,
  });

  @override
  _ExportAlkesScreenState createState() => _ExportAlkesScreenState();
}

class _ExportAlkesScreenState extends State<ExportAlkesScreen> {
  String catatan = '';
  String upayaKegiatan = '';
  String estimasiBiaya = '';
  bool isConnected = false;
  String? emailPenerima;
  Uint8List? logoData;
  List<Map<String, dynamic>> detailedData = [];
  File? backgroundImageFile;
   String lokasiKegiatan = '';
   List<Map<String, dynamic>> penggunaList = [];
   List<Map<String, dynamic>> kegiatanList = [];
  

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
    } else {
      final ByteData assetByteData = await rootBundle.load('assets/images/logors.jpg');
      final Uint8List uint8list = assetByteData.buffer.asUint8List();
      setState(() {
        logoData = uint8list;
      });
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
      final data = await dbHelper.getEntriesByKegiatanIdAndCategoryAndUser(widget.kegiatanId!, 12, widget.userId); // Menyertakan kondisi kategori dan userId
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
      

      final downloadsDir = await getExternalStorageDirectory();
      String fileName = 'Alkes_${widget.puskesmas}.pdf';

     if (widget.kegiatanId != null) {
        final dbHelper = DatabaseHelper();
        final tanggalKegiatan = await dbHelper.getTanggalKegiatan(widget.kegiatanId!);
        if (tanggalKegiatan != null) {
          fileName = 'Alkes_${widget.puskesmas}_$tanggalKegiatan.pdf';
        }
      }

       final pdfPath = '${downloadsDir!.path}/fotopuskesmas/$fileName';
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
        pw.Text('Sebelum Indikator 1: ${widget.sebelumIndikator1}'),
        pw.Text('Sebelum Indikator 2: ${widget.sebelumIndikator2}'),
        pw.Text('Sesudah Indikator 1: ${widget.sesudahIndikator1}'),
        pw.Text('Sesudah Indikator 2: ${widget.sesudahIndikator2}'),
        pw.Text('Interpretasi Sebelum Indikator 1: ${widget.interpretasiIndikator1Sebelum ?? ''}'),
        pw.Text('Interpretasi Sebelum Indikator 2: ${widget.interpretasiIndikator2Sebelum ?? ''}'),
        pw.Text('Interpretasi Sesudah Indikator 1: ${widget.interpretasiIndikator1Sesudah ?? ''}'),
        pw.Text('Interpretasi Sesudah Indikator 2: ${widget.interpretasiIndikator2Sesudah ?? ''}'),
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
            _buildTableCell('Sebelum Indikator 1', isHeader: true),
            _buildTableCell('Sebelum Indikator 2', isHeader: true),
            _buildTableCell('Sesudah Indikator 1', isHeader: true),
            _buildTableCell('Sesudah Indikator 2', isHeader: true),
            _buildTableCell('Keterangan', isHeader: true),
          ],
        ),
        ...detailedData.map((entry) => pw.TableRow(
          children: [
            _buildTableCell(entry['indikator']?? ''),
            _buildTableCell(entry['sub_indikator']?? ''),
            _buildTableCell(entry['sebelum']?? ''),
            _buildTableCell(entry['sebelum2']?? ''),
            _buildTableCell(entry['sesudah1']?? ''),
            _buildTableCell(entry['sesudah2']?? ''),
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
                    Text('Sebelum Indikator 1', style: TextStyle(fontSize: 18)),
                    Text(widget.sebelumIndikator1.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 1 Sebelum', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator1Sebelum,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         Text('Sesudah Indikator 1', style: TextStyle(fontSize: 18)),
                    Text(widget.sesudahIndikator1.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 1 Sesudah', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator1Sesudah,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Sebelum Indikator 2', style: TextStyle(fontSize: 18)),
                    Text(widget.sebelumIndikator2.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 2 Sebelum', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator2Sesudah,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Sesudah Indikator 2', style: TextStyle(fontSize: 18)),
                    Text(widget.sesudahIndikator2.toString(),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Interpretasi Indikator 2 Sesudah', style: TextStyle(fontSize: 16)),
                    Text(widget.interpretasiIndikator2Sesudah,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         SizedBox(height: 5),
                    Text('Interpretasi Indikator Akhir', style: TextStyle(fontSize: 16)),
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