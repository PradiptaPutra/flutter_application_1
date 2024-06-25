import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



class PuskesmasScreen extends StatefulWidget {
  final int userId;

  PuskesmasScreen({required this.userId});

  @override
  _PuskesmasScreenState createState() => _PuskesmasScreenState();
}

class _PuskesmasScreenState extends State<PuskesmasScreen> {
  // Define controllers for text fields
  TextEditingController namaPuskesmasController = TextEditingController();
  DateTime? selectedDate;

  // Define dropdown values
  String dropdownValue = 'Rawat Inap';
  String? selectedProvinsi;
  String? selectedKabupaten;
  
  List<String> provinsiList = [
    'Aceh', 'Bali', 'Banten', 'Bengkulu', 'Gorontalo', 'Jakarta', 
    'Jambi', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'Kalimantan Barat',
    'Kalimantan Selatan', 'Kalimantan Tengah', 'Kalimantan Timur',
    'Kalimantan Utara', 'Kepulauan Bangka Belitung', 'Kepulauan Riau', 
    'Lampung', 'Maluku', 'Maluku Utara', 'Nusa Tenggara Barat', 
    'Nusa Tenggara Timur', 'Papua', 'Papua Barat', 'Riau', 'Sulawesi Barat',
    'Sulawesi Selatan', 'Sulawesi Tengah', 'Sulawesi Tenggara', 'Sulawesi Utara',
    'Sumatera Barat', 'Sumatera Selatan', 'Sumatera Utara', 'Yogyakarta'
  ];
  Map<String, List<String>> kabupatenList = {
    'Aceh': ['Banda Aceh', 'Langsa', 'Lhokseumawe', 'Meulaboh', 'Sabang', 'Subulussalam'],
    'Bali': ['Denpasar'],
    'Banten': ['Cilegon', 'Serang', 'Tangerang', 'Tangerang Selatan'],
    'Bengkulu': ['Bengkulu'],
    'Gorontalo': ['Gorontalo'],
    'Jakarta': ['Jakarta Barat', 'Jakarta Pusat', 'Jakarta Selatan', 'Jakarta Timur', 'Jakarta Utara'],
    'Jambi': ['Jambi'],
    'Jawa Barat': ['Bandung', 'Bekasi', 'Bogor', 'Cimahi', 'Cirebon', 'Depok', 'Sukabumi', 'Tasikmalaya'],
    'Jawa Tengah': ['Magelang', 'Pekalongan', 'Salatiga', 'Semarang', 'Surakarta', 'Tegal'],
    'Jawa Timur': ['Batu', 'Blitar', 'Kediri', 'Madiun', 'Malang', 'Mojokerto', 'Pasuruan', 'Probolinggo', 'Surabaya'],
    'Kalimantan Barat': ['Pontianak', 'Singkawang'],
    'Kalimantan Selatan': ['Banjarbaru', 'Banjarmasin'],
    'Kalimantan Tengah': ['Palangka Raya'],
    'Kalimantan Timur': ['Balikpapan', 'Bontang', 'Samarinda'],
    'Kalimantan Utara': ['Tarakan'],
    'Kepulauan Bangka Belitung': ['Pangkal Pinang'],
    'Kepulauan Riau': ['Batam', 'Tanjung Pinang'],
    'Lampung': ['Bandar Lampung', 'Metro'],
    'Maluku': ['Ambon', 'Tual'],
    'Maluku Utara': ['Ternate', 'Tidore Kepulauan'],
    'Nusa Tenggara Barat': ['Bima', 'Mataram'],
    'Nusa Tenggara Timur': ['Kupang'],
    'Papua': ['Jayapura'],
    'Papua Barat': ['Manokwari'],
    'Riau': ['Dumai', 'Pekanbaru'],
    'Sulawesi Barat': ['Mamuju'],
    'Sulawesi Selatan': ['Makassar', 'Palopo', 'Parepare'],
    'Sulawesi Tengah': ['Palu'],
    'Sulawesi Tenggara': ['Bau-Bau', 'Kendari'],
    'Sulawesi Utara': ['Bitung', 'Kotamobagu', 'Manado', 'Tomohon'],
    'Sumatera Barat': ['Bukittinggi', 'Padang', 'Padang Panjang', 'Pariaman', 'Payakumbuh', 'Sawahlunto', 'Solok'],
    'Sumatera Selatan': ['Lubuklinggau', 'Pagar Alam', 'Palembang', 'Prabumulih'],
    'Sumatera Utara': ['Binjai', 'Gunungsitoli', 'Medan', 'Padang Sidempuan', 'Pematang Siantar', 'Sibolga', 'Tanjungbalai', 'Tebing Tinggi'],
    'Yogyakarta': ['Yogyakarta'],
  };
List<int>? _imageBytes;
File? _selectedImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to text fields and other inputs
    namaPuskesmasController.addListener(_validateInputs);
  }

  void _validateInputs() {
    if (namaPuskesmasController.text.isNotEmpty &&
        selectedDate != null &&
        selectedProvinsi != null &&
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
    // Dispose controllers when the screen is disposed
    namaPuskesmasController.dispose();
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
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            ListTile(
              title: TextField(
                controller: namaPuskesmasController,
                decoration: InputDecoration(
                  labelText: 'Nama Puskesmas',
                ),
              ),
            ),
            ListTile(
              title: DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    _validateInputs();
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
            ListTile(
              title: DropdownButton<String>(
                hint: Text('Pilih Provinsi'),
                value: selectedProvinsi,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProvinsi = newValue;
                    selectedKabupaten = null; // Reset kabupaten when provinsi changes
                    _validateInputs();
                  });
                },
                items: provinsiList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: DropdownButton<String>(
                hint: Text('Pilih Kabupaten/Kota'),
                value: selectedKabupaten,
                onChanged: selectedProvinsi != null
                    ? (String? newValue) {
                        setState(() {
                          selectedKabupaten = newValue;
                          _validateInputs();
                        });
                      }
                    : null,
                items: selectedProvinsi != null
                    ? kabupatenList[selectedProvinsi]!
                        .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList()
                    : [],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.date_range),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: selectedDate == null
                        ? Text('Pilih Tanggal')
                        : Text(DateFormat('dd MMMM yyyy').format(selectedDate!)),
                  ),
                ],
              ),
            ),
            // Input gambar untuk upload
          ListTile(
              leading: Icon(Icons.add_a_photo),
              title: Row(
                children: [
                  Icon(Icons.image),
                  SizedBox(width: 10),
                  Text('Pilih Gambar'),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'camera') {
                        _getImage(ImageSource.camera);
                      } else if (value == 'gallery') {
                        _getImage(ImageSource.gallery);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'camera',
                        child: ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text('Ambil Foto'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'gallery',
                        child: ListTile(
                          leading: Icon(Icons.image),
                          title: Text('Pilih dari Galeri'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: _isNextButtonEnabled ? _insertKegiatan : null,
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

     Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

Future<bool> _requestPermission() async {
  PermissionStatus status = await Permission.storage.request();
  return status.isGranted;
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _validateInputs();
      });
    }
  }

Future<void> _insertKegiatan() async {
  // Meminta izin terlebih dahulu
  bool permissionGranted = await _requestPermission();
  if (!permissionGranted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Permission untuk menyimpan gambar ditolak.'),
    ));
    return;
  }

  String namaPuskesmas = namaPuskesmasController.text;
  String tanggalKegiatan =
      selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate!) : '';
  
  // Mendapatkan data pengguna yang sedang login
  Map<String, dynamic>? userData = await DatabaseHelper().getUserData(widget.userId);

  if (userData != null) {
    String nama = userData['name'];
    String jabatan = userData['position'];
    String notelp = userData['phone'];

    // Menyimpan gambar ke penyimpanan lokal
    String namaFileFoto = '';
    if (_selectedImage != null) {
      final downloadsDir = Directory('/storage/emulated/0/Download/fotopuskesmas');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true); // Membuat folder fotopuskesmas jika belum ada
      }
      namaFileFoto = 'foto_${namaPuskesmas}.jpg';
      String filePath = '${downloadsDir.path}/$namaFileFoto';
      await _selectedImage!.copy(filePath);
    }

    // Membuat objek data kegiatan
    Map<String, dynamic> kegiatanData = {
      'user_id': widget.userId,
      'nama_puskesmas': namaPuskesmas,
      'dropdown_option': dropdownValue,
      'provinsi': selectedProvinsi,
      'kabupaten_kota': selectedKabupaten,
      'tanggal_kegiatan': tanggalKegiatan,
      'nama': nama,
      'jabatan': jabatan,
      'notelepon': notelp,
      'foto': namaFileFoto, // Menyimpan nama file foto
    };

    // Memasukkan data kegiatan ke dalam database
    int kegiatanId = await DatabaseHelper().insertKegiatan(kegiatanData);

    // Mengosongkan input setelah data disimpan
    namaPuskesmasController.clear();
    setState(() {
      selectedDate = null;
      selectedProvinsi = null;
      selectedKabupaten = null;
      _selectedImage = null;
      _validateInputs();
    });

    // Pindah ke halaman selanjutnya
    Navigator.pushNamed(context, '/category_selection',
        arguments: {'userId': widget.userId, 'kegiatanId': kegiatanId});
  } else {
    // Jika data pengguna tidak ditemukan, tampilkan pesan kesalahan
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Data pengguna tidak ditemukan.'),
    ));
  }
}
}