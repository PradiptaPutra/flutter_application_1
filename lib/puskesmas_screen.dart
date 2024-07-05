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
  String? selectedProvinsi; // Default to null, let user choose
  String? selectedKabupaten;

  List<String> provinsiList = [
    'Aceh', 'Sumatera Utara', 'Sumatera Barat', 'Riau', 'Jambi', 'Sumatera Selatan',
    'Bengkulu', 'Lampung', 'Kepulauan Bangka Belitung', 'Kepulauan Riau', 'DKI Jakarta',
    'Jawa Barat', 'Jawa Tengah', 'DI Yogyakarta', 'Jawa Timur', 'Banten', 'Bali', 'Nusa Tenggara Barat',
    'Nusa Tenggara Timur', 'Kalimantan Barat', 'Kalimantan Tengah', 'Kalimantan Selatan', 'Kalimantan Timur',
    'Kalimantan Utara', 'Sulawesi Utara', 'Sulawesi Tengah', 'Sulawesi Selatan', 'Sulawesi Tenggara',
    'Gorontalo', 'Sulawesi Barat', 'Maluku', 'Maluku Utara', 'Papua Barat', 'Papua'
  ];

  Map<String, List<String>> kabupatenList = {
    'Aceh': ['Aceh Besar', 'Aceh Selatan', 'Aceh Tengah', 'Aceh Timur', 'Aceh Utara', 'Bener Meriah', 'Gayo Lues', 'Pidie', 'Pidie Jaya', 'Bireuen', 'Aceh Barat', 'Nagan Raya', 'Aceh Jaya', 'Aceh Singkil'],
    'Sumatera Utara': ['Asahan', 'Batubara', 'Dairi', 'Deli Serdang', 'Humbang Hasundutan', 'Karo', 'Labuhan Batu', 'Labuhan Batu Selatan', 'Labuhan Batu Utara', 'Langkat', 'Mandailing Natal', 'Nias', 'Nias Barat', 'Nias Selatan', 'Nias Utara', 'Padang Lawas', 'Padang Lawas Utara', 'Pakpak Bharat', 'Samosir', 'Serdang Bedagai', 'Simalungun', 'Tapanuli Selatan', 'Tapanuli Tengah', 'Tapanuli Utara', 'Toba Samosir'],
    'Sumatera Barat': ['Agam', 'Dharmasraya', 'Kepulauan Mentawai', 'Lima Puluh Kota', 'Padang Pariaman', 'Pasaman', 'Pasaman Barat', 'Pesisir Selatan', 'Sijunjung', 'Solok', 'Solok Selatan', 'Tanah Datar'],
    'Riau': ['Bengkalis', 'Indragiri Hilir', 'Indragiri Hulu', 'Kampar', 'Kepulauan Meranti', 'Kuantan Singingi', 'Pelalawan', 'Rokan Hilir', 'Rokan Hulu', 'Siak', 'Dumai', 'Pekanbaru'],
    'Jambi': ['Batang Hari', 'Bungo', 'Kerinci', 'Merangin', 'Muaro Jambi', 'Sarolangun', 'Tanjung Jabung Barat', 'Tanjung Jabung Timur', 'Tebo'],
    'Sumatera Selatan': ['Banyuasin', 'Empat Lawang', 'Lahat', 'Muara Enim', 'Musi Banyuasin', 'Musi Rawas', 'Ogan Ilir', 'Ogan Komering Ilir', 'Ogan Komering Ulu', 'Ogan Komering Ulu Selatan', 'Ogan Komering Ulu Timur', 'Penukal Abab Lematang Ilir'],
    'Bengkulu': ['Bengkulu Selatan', 'Bengkulu Tengah', 'Bengkulu Utara', 'Kaur', 'Kepahiang', 'Lebong', 'Mukomuko', 'Rejang Lebong', 'Seluma'],
    'Lampung': ['Bandar Lampung', 'Lampung Barat', 'Lampung Selatan', 'Lampung Tengah', 'Lampung Timur', 'Lampung Utara', 'Mesuji', 'Pesawaran', 'Pesisir Barat', 'Pringsewu', 'Tanggamus', 'Tulang Bawang', 'Tulang Bawang Barat', 'Way Kanan'],
    'Kepulauan Bangka Belitung': ['Bangka', 'Bangka Barat', 'Bangka Selatan', 'Bangka Tengah', 'Belitung', 'Belitung Timur'],
    'Kepulauan Riau': ['Bintan', 'Karimun', 'Kepulauan Anambas', 'Lingga', 'Natuna', 'Tanjung Pinang'],
    'DKI Jakarta': ['Jakarta Barat', 'Jakarta Pusat', 'Jakarta Selatan', 'Jakarta Timur', 'Jakarta Utara'],
    'Jawa Barat': ['Bandung', 'Bandung Barat', 'Bekasi', 'Bogor', 'Ciamis', 'Cianjur', 'Cirebon', 'Garut', 'Indramayu', 'Karawang', 'Kuningan', 'Majalengka', 'Pangandaran', 'Purwakarta', 'Subang', 'Sukabumi', 'Sumedang', 'Tasikmalaya'],
    'Jawa Tengah': ['Banjarnegara', 'Banyumas', 'Batang', 'Blora', 'Boyolali', 'Brebes', 'Cilacap', 'Demak', 'Grobogan', 'Jepara', 'Karanganyar', 'Kebumen', 'Kendal', 'Klaten', 'Kudus', 'Magelang', 'Pati', 'Pekalongan', 'Pemalang', 'Purbalingga', 'Purworejo', 'Rembang', 'Semarang', 'Sragen', 'Sukoharjo', 'Tegal', 'Temanggung', 'Wonogiri', 'Wonosobo'],
    'DI Yogyakarta': ['Bantul', 'Gunung Kidul', 'Kulon Progo', 'Sleman', 'Yogyakarta'],
    'Jawa Timur': ['Bangkalan', 'Banyuwangi', 'Blitar', 'Bojonegoro', 'Bondowoso', 'Gresik', 'Jember', 'Jombang', 'Kediri', 'Lamongan', 'Lumajang', 'Madiun', 'Magetan', 'Malang', 'Mojokerto', 'Nganjuk', 'Ngawi', 'Pacitan', 'Pamekasan', 'Pasuruan', 'Ponorogo', 'Probolinggo', 'Sampang', 'Sidoarjo', 'Situbondo', 'Sumenep', 'Tuban', 'Tulungagung'],
    'Banten': ['Cilegon', 'Kabupaten Lebak', 'Kabupaten Pandeglang', 'Kabupaten Serang', 'Pandeglang', 'Serang', 'Tangerang', 'Tangerang Selatan'],
    'Bali': ['Badung', 'Bangli', 'Buleleng', 'Denpasar', 'Gianyar', 'Jembrana', 'Karangasem', 'Klungkung', 'Tabanan'],
    'Nusa Tenggara Barat': ['Bima', 'Dompu', 'Lombok Barat', 'Lombok Tengah', 'Lombok Timur', 'Lombok Utara', 'Mataram', 'Sumbawa', 'Sumbawa Barat'],
    'Nusa Tenggara Timur': ['Alor', 'Belu', 'Ende', 'Flores Timur', 'Kupang', 'Lembata', 'Malaka', 'Manggarai', 'Manggarai Barat', 'Manggarai Timur', 'Nagekeo', 'Ngada', 'Rote Ndao', 'Sabu Raijua', 'Sikka', 'Sumba Barat', 'Sumba Barat Daya', 'Sumba Tengah', 'Sumba Timur', 'Timor Tengah Selatan', 'Timor Tengah Utara'],
'Kalimantan Barat': ['Bengkayang', 'Kabupaten Kapuas Hulu', 'Ketapang', 'Kubu Raya', 'Landak', 'Melawi', 'Mempawah', 'Pontianak', 'Sambas', 'Sanggau', 'Sekadau', 'Sintang', 'Kabupaten Kayong Utara'],
'Kalimantan Tengah': ['Barito Selatan', 'Barito Timur', 'Barito Utara', 'Gunung Mas', 'Kapuas', 'Katingan', 'Kotawaringin Barat', 'Kotawaringin Timur', 'Lamandau', 'Murung Raya', 'Pulang Pisau', 'Sukamara', 'Seruyan', 'Kabupaten Barito Utara'],
'Kalimantan Selatan': ['Balangan', 'Banjar', 'Barito Kuala', 'Hulu Sungai Selatan', 'Hulu Sungai Tengah', 'Hulu Sungai Utara', 'Kotabaru', 'Tabalong', 'Tanah Bumbu', 'Tanah Laut', 'Tapin'],
'Kalimantan Timur': ['Berau', 'Kutai Barat', 'Kutai Kartanegara', 'Kutai Timur', 'Mahakam Ulu', 'Paser', 'Penajam Paser Utara', 'Kabupaten Bulungan', 'Kabupaten Berau', 'Kabupaten Nunukan', 'Kabupaten Malinau', 'Kabupaten Kubar'],
'Kalimantan Utara': ['Bulungan', 'Malinau', 'Nunukan', 'Tana Tidung'],
'Sulawesi Utara': ['Bitung', 'Bolaang Mongondow', 'Kotamobagu', 'Kabupaten Kepulauan Sangihe', 'Kabupaten Kepulauan Siau Tagulandang Biaro', 'Kabupaten Kepulauan Talaud', 'Kabupaten Minahasa', 'Kabupaten Minahasa Selatan', 'Kabupaten Minahasa Tenggara', 'Kabupaten Minahasa Utara', 'Manado', 'Tomohon'],
   'Sulawesi Tengah': ['Banggai', 'Banggai Kepulauan', 'Banggai Laut', 'Buol', 'Donggala', 'Morowali', 'Palu', 'Parigi Moutong', 'Poso', 'Tojo Una-Una', 'Toli-Toli'],
    'Sulawesi Selatan': ['Bantaeng', 'Barru', 'Bone', 'Bulukumba', 'Enrekang', 'Gowa', 'Jeneponto', 'Kepulauan Selayar', 'Luwu', 'Luwu Timur', 'Luwu Utara', 'Makassar', 'Maros', 'Pangkajene Kepulauan', 'Parepare', 'Pinrang', 'Sidenreng Rappang', 'Sinjai', 'Soppeng', 'Takalar', 'Tana Toraja', 'Toraja Utara', 'Wajo'],
    'Sulawesi Tenggara': ['Bombana', 'Buton', 'Buton Selatan', 'Buton Tengah', 'Buton Utara', 'Kendari', 'Konawe', 'Konawe Kepulauan', 'Konawe Selatan', 'Konawe Utara', 'Kolaka', 'Kolaka Timur', 'Kolaka Utara', 'Muna', 'Muna Barat', 'Wakatobi'],
    'Gorontalo': ['Bone Bolango', 'Gorontalo', 'Gorontalo Utara', 'Pohuwato'],
    'Sulawesi Barat': ['Majene', 'Mamasa', 'Mamuju', 'Mamuju Utara', 'Polewali Mandar'],
    'Maluku': ['Ambon', 'Buru', 'Buru Selatan', 'Kepulauan Aru', 'Maluku Barat Daya', 'Maluku Tengah', 'Maluku Tenggara', 'Maluku Tenggara Barat', 'Seram Bagian Barat', 'Seram Bagian Timur'],
    'Maluku Utara': ['Halmahera Barat', 'Halmahera Tengah', 'Halmahera Timur', 'Halmahera Utara', 'Kepulauan Sula', 'Morotai', 'Pulau Taliabu', 'Ternate', 'Tidore Kepulauan'],
    'Papua Barat': ['Fakfak', 'Kaimana', 'Manokwari', 'Maybrat', 'Raja Ampat', 'Sorong', 'Sorong Selatan', 'Teluk Bintuni', 'Teluk Wondama'],
    'Papua': ['Asmat', 'Biak Numfor', 'Deiyai', 'Dogiyai', 'Intan Jaya', 'Jayapura', 'Jayawijaya', 'Keerom', 'Lanny Jaya', 'Mamberamo Raya', 'Mamberamo Tengah', 'Mappi', 'Merauke', 'Nabire', 'Nduga', 'Paniai', 'Pegunungan Bintang', 'Puncak', 'Puncak Jaya', 'Sarmi', 'Supiori', 'Tolikara', 'Waropen', 'Yahukimo', 'Yalimo']
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
                'assets/images/dangerdisaster.jpg',
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
              onChanged: (String? newValue) {
                setState(() {
                  selectedProvinsi = newValue;
                  selectedKabupaten = null; // Reset kabupaten when provinsi changes
                });
                _validateInputs();
              },
            items: provinsiList.map((String provinsi) {
                return DropdownMenuItem<String>(
                  value: provinsi,
                  child: Text(provinsi),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Provinsi'),
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
