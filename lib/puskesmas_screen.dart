import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PuskesmasScreen extends StatefulWidget {
  final int userId;

  PuskesmasScreen({required this.userId});

  @override
  _PuskesmasScreenState createState() => _PuskesmasScreenState();
}

class _PuskesmasScreenState extends State<PuskesmasScreen> {
  TextEditingController namaPuskesmasController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  TextEditingController kelurahanController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  DateTime? selectedDate;

  String dropdownValue = 'Rawat Inap';
  String? selectedProvinsi = 'Jambi'; // Default to Jambi province
  String? selectedKabupaten;

  List<String> provinsiList = ['Jambi'];
  Map<String, List<String>> kabupatenList = {
    'Jambi': ['Kota Jambi', 'Kabupaten Bungo', 'Kabupaten Kerinci', 'Kabupaten Muaro Jambi', 'Kabupaten Sarolangun', 'Kabupaten Tanjung Jabung Barat', 'Kabupaten Tanjung Jabung Timur', 'Kabupaten Tebo']
  };

  File? _selectedImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    namaPuskesmasController.addListener(_validateInputs);
  }

  void _validateInputs() {
    if (namaPuskesmasController.text.isNotEmpty &&
        lokasiController.text.isNotEmpty &&
        kelurahanController.text.isNotEmpty &&
        kecamatanController.text.isNotEmpty &&
        selectedDate != null &&
        selectedProvinsi != null &&
        _selectedImage != null &&
        selectedKabupaten != null) {
      setState(() {
        _isNextButtonEnabled = true;
      });
    } else {
      setState(() {
        _isNextButtonEnabled = false;
      });
    }
  }

  @override
  void dispose() {
    namaPuskesmasController.dispose();
    lokasiController.dispose();
    kelurahanController.dispose();
    kecamatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Pilih Kategori'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/logopuskesmas.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 10),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Puskesmas'),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                // Handle Rumah Sakit tap
              },
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/logors.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 10),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Rumah Sakit'),
                ],
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                // Handle Dinas Kesehatan tap
              },
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/logodinkes.jpg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 10),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Dinas Kesehatan'),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Image.asset(
                'assets/images/puskesmasheader.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: namaPuskesmasController,
                decoration: InputDecoration(
                  labelText: 'Nama Puskesmas',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: lokasiController,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: selectedProvinsi,
                hint: Text('Pilih Provinsi'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProvinsi = newValue;
                    selectedKabupaten = null; // Reset selected kabupaten when province changes
                  });
                  _validateInputs();
                },
                items: provinsiList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            if (selectedProvinsi != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedKabupaten,
                  hint: Text('Pilih Kabupaten/Kota'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedKabupaten = newValue;
                    });
                    _validateInputs();
                  },
                  items: kabupatenList[selectedProvinsi!]!.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: kecamatanController,
                  decoration: InputDecoration(
                    labelText: 'Kecamatan',
                  ),
                  onChanged: (value) {
                    _validateInputs();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: kelurahanController,
                  decoration: InputDecoration(
                    labelText: 'Kelurahan',
                  ),
                  onChanged: (value) {
                    _validateInputs();
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: InputDecoration(labelText: 'Jenis Layanan'),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Rawat Inap', 'Non Rawat Inap']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                title: Text(
                  selectedDate == null
                      ? 'Tanggal Kegiatan'
                      : DateFormat('dd-MM-yyyy').format(selectedDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text('Ambil dari Galeri'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Ambil Foto'),
                ),
              ],
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isNextButtonEnabled ? _nextStep : null,
                child: Text('Selanjutnya'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _validateInputs();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      File compressedFile = await _compressImage(File(image.path));
      setState(() {
        _selectedImage = compressedFile;
        _validateInputs();
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return File(result!.path);
  }

  Future<void> _nextStep() async {
    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );

    final String namaPuskesmas = namaPuskesmasController.text;
    final String lokasi = lokasiController.text;
    final String kelurahan = kelurahanController.text;
    final String kecamatan = kecamatanController.text;
    final String tanggalPendirian = selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '';
    final String jenisLayanan = dropdownValue;
    final String provinsi = selectedProvinsi ?? '';
    final String kabupaten = selectedKabupaten ?? '';

    // Ensure _selectedImage is not null before accessing its path
    final String imagePath = _selectedImage != null ? _selectedImage!.path : '';

    //Mendapatkan data pengguna yang sedang login
    Map<String, dynamic>? userData = await DatabaseHelper.instance.getUserData(widget.userId);

    if (userData != null) {
      String nama = userData['name'];
      String jabatan = userData['position'];
      String notelp = userData['phone'];

      // Menyimpan gambar ke penyimpanan lokal
      String namaFileFoto = '';
      if (_selectedImage != null) {
        final downloadsDir = await getExternalStorageDirectory();
        final directoryPath = '${downloadsDir!.path}/fotopuskesmas';

        // Create the directory if it doesn't exist
        final directory = Directory(directoryPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        if (downloadsDir != null) {
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true); // Membuat folder fotopuskesmas jika belum ada
          }
          namaFileFoto = 'foto_${namaPuskesmas.replaceAll(' ', '_').toLowerCase()}.jpg';
          String filePath = path.join(downloadsDir.path, 'fotopuskesmas', namaFileFoto);
          try {
            if (_selectedImage != null) {
              if (downloadsDir != null) {
                final fotopuskesmasDir = Directory('${downloadsDir.path}/fotopuskesmas');
                if (!await fotopuskesmasDir.exists()) {
                  await fotopuskesmasDir.create(recursive: true);
                }
                String namaFileFoto = 'foto_${namaPuskesmas.replaceAll(' ', '_').toLowerCase()}.jpg';
                String filePath = '${fotopuskesmasDir.path}/$namaFileFoto';
                await _selectedImage!.copy(filePath);
                print('Berhasil menyimpan foto ke: $filePath');
              } else {
                print('Gagal mendapatkan direktori eksternal');
              }
            }
          } catch (e) {
            print('Gagal menyimpan foto: $e');
          }
        } else {
          print("Error: Tidak dapat mengakses direktori penyimpanan.");
        }
      }

      final int result = await DatabaseHelper.instance.insertPuskesmas({
        'user_id': widget.userId,
        'nama_puskesmas': namaPuskesmas,
        'lokasi': lokasi,
        'tanggal_kegiatan': tanggalPendirian,
        'dropdown_option': jenisLayanan,
        'nama': nama,
        'jabatan': jabatan,
        'notelepon': notelp,
        'provinsi': provinsi,
        'kabupaten_kota': kabupaten,
        'kelurahan': kelurahan,
        'kecamatan': kecamatan,
        'foto': namaFileFoto,
      });

      // Mengosongkan input setelah data disimpan
      namaPuskesmasController.clear();
      lokasiController.clear();
      kelurahanController.clear();
      kecamatanController.clear();
      setState(() {
        selectedDate = null;
        selectedProvinsi = 'Jambi'; // Reset to default Jambi province
        selectedKabupaten = null;
        _selectedImage = null;
        _validateInputs();
      });

      // Tutup dialog loading
      Navigator.pop(context);

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
        // Navigasi ke halaman berikutnya atau tindakan lain yang ingin Anda lakukan
        Navigator.pushNamed(context, '/category_selection',
            arguments: {'userId': widget.userId, 'kegiatanId': result});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data')));
      }
    }
  }
}
