import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PuskesmasScreen extends StatefulWidget {
  final int userId;

  PuskesmasScreen({required this.userId});

  @override
  _PuskesmasScreenState createState() => _PuskesmasScreenState();
}

class _PuskesmasScreenState extends State<PuskesmasScreen> {
  TextEditingController namaPuskesmasController = TextEditingController();
  TextEditingController lokasiController = TextEditingController();
  DateTime? selectedDate;

  String dropdownValue = 'Rawat Inap';
  String? selectedProvinsi = 'Jambi'; // Default to Jambi province
  String? selectedKabupaten;
  String? selectedKelurahan;
  String? selectedKecamatan;

  List<String> provinsiList = ['Jambi'];
  Map<String, List<String>> kabupatenList = {
    'Jambi': ['Kota Jambi', 'Kabupaten Bungo', 'Kabupaten Kerinci', 'Kabupaten Muaro Jambi', 'Kabupaten Sarolangun', 'Kabupaten Tanjung Jabung Barat', 'Kabupaten Tanjung Jabung Timur', 'Kabupaten Tebo']
  };
 Map<String, List<String>> kelurahanList = {
  'Kota Jambi': [
    'Talang Banjar',
    'Beringin',
    'Kasang'],
  'Kabupaten Bungo': [
    'Bathin II Babeko',
    'Muko-Muko Bathin VII',
    'Penyengat I'],
  'Kabupaten Kerinci': [
    'Dusun Baru',
    'Mentawak',
    'Talang Kuta'],
  'Kabupaten Muaro Jambi': [
    'Pelayangan',
    'Pasar Muara Bungo',
    'Teluk Binjai'],
  'Kabupaten Sarolangun': [
    'Danau Lamo',
    'Renah Kemumu',
    'Sungai Gula'],
  'Kabupaten Tanjung Jabung Barat': [
    'Batu Hampar',
    'Mendalo Darat',
    'Renah Pembarap'],
  'Kabupaten Tanjung Jabung Timur': [
    'Babeko',
    'Batang Asai',
    'Penyengat Rendah'],
  'Kabupaten Tebo': [
    'Air Hitam',
    'Lubuk Raman',
    'Sungai Penuh']
};

Map<String, List<String>> kecamatanList = {
  'Kota Jambi': [
    'Alam Barajo',
    'Jelutung',
    'Kota Baru'],
  'Kabupaten Bungo': [
    'Bathin II Babeko',
    'Muko-Muko Bathin VII',
    'Pasar Muara Bungo'],
  'Kabupaten Kerinci': [
    'Air Hangat Timur',
    'Kayu Aro',
    'Keliling Danau'],
  'Kabupaten Muaro Jambi': [
    'Jambi Selatan',
    'Jambi Timur',
    'Jambi Utara'],
  'Kabupaten Sarolangun': [
    'Mandiangin',
    'Pauh',
    'Sarolangun'],
  'Kabupaten Tanjung Jabung Barat': [
    'Dendang',
    'Muara Papalik',
    'Nasal'],
  'Kabupaten Tanjung Jabung Timur': [
    'Dalam',
    'Rantau Rasau',
    'Tungkal Ulu'],
  'Kabupaten Tebo': [
    'Rimbo Bujang',
    'Tebo Tengah',
    'Tebo Ulu']
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
        selectedDate != null &&
        selectedProvinsi != null &&
        _selectedImage != null &&
        selectedKabupaten != null &&
        selectedKelurahan != null &&
        selectedKecamatan != null) {
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
                  labelText: 'Lokasi',
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
                    selectedKelurahan = null; // Reset selected kelurahan when province changes
                    selectedKecamatan = null; // Reset selected kecamatan when province changes
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
                      selectedKelurahan = null; // Reset selected kelurahan when kabupaten changes
                      selectedKecamatan = null; // Reset selected kecamatan when kabupaten changes
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
              if (selectedKabupaten != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedKelurahan,
                    hint: Text('Pilih Kelurahan'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedKelurahan = newValue;
                      });
                      _validateInputs();
                    },
                    items: kelurahanList[selectedKabupaten!]!.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedKecamatan,
                    hint: Text('Pilih Kecamatan'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedKecamatan = newValue;
                      });
                      _validateInputs();
                    },
                    items: kecamatanList[selectedKabupaten!]!.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _validateInputs();
      });
  }

  void _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _validateInputs();
      });
    }
  }

  Future<void> _nextStep() async {
    final String namaPuskesmas = namaPuskesmasController.text;
    final String lokasi = lokasiController.text;
    final String tanggalPendirian = selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '';
    final String jenisLayanan = dropdownValue;
    final String provinsi = selectedProvinsi ?? '';
    final String kabupaten = selectedKabupaten ?? '';
    final String kelurahan = selectedKelurahan ?? '';
    final String kecamatan = selectedKecamatan ?? '';

    // Ensure _selectedImage is not null before accessing its path
    final String imagePath = _selectedImage != null ? _selectedImage!.path : '';

    // Mendapatkan data pengguna yang sedang login
    Map<String, dynamic>? userData = await DatabaseHelper.instance.getUserData(widget.userId);

    if (userData != null) {
      String nama = userData['name'];
      String jabatan = userData['position'];
      String notelp = userData['phone'];

       // Menyimpan gambar ke penyimpanan lokal
      String namaFileFoto = '';
      if (_selectedImage != null) {
        final downloadsDir = await getExternalStorageDirectory();
        if (downloadsDir != null) {
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true); // Membuat folder fotopuskesmas jika belum ada
          }
          namaFileFoto = 'foto_${namaPuskesmas.replaceAll(' ', '_').toLowerCase()}.jpg';
          String filePath = path.join(downloadsDir.path, 'fotopuskesmas', namaFileFoto);
         try {
  if (_selectedImage != null) {
    final downloadsDir = await getExternalStorageDirectory();
    if (downloadsDir != null) {
      final fotopuskesmasDir = Directory('${downloadsDir.path}/fotopuskesmas');
      if (!await fotopuskesmasDir.exists()) {
        await fotopuskesmasDir.create(recursive: true);
      }
      String namaFileFoto = 'foto_${namaPuskesmas}.jpg';
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
      setState(() {
        selectedDate = null;
        selectedProvinsi = 'Jambi'; // Reset to default Jambi province
        selectedKabupaten = null;
        selectedKelurahan = null;
        selectedKecamatan = null;
        _selectedImage = null;
        _validateInputs();
      });

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
