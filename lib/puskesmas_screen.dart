import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

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

  // Define dropdown value
  String dropdownValue = 'Rawat Inap';

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
        selectedDate != null) {
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
            SizedBox(height: 20), // Add spacing between fields and the "Next" button
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

  void _insertKegiatan() async {
    String namaPuskesmas = namaPuskesmasController.text;
    String tanggalKegiatan =
        selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate!) : '';

    // Mendapatkan data pengguna yang sedang login
    Map<String, dynamic>? userData = await DatabaseHelper().getUserData(widget.userId);

    // Jika data pengguna ditemukan
    if (userData != null) {
      // Mengisi kolom nama, jabatan, dan nomor telepon dari data pengguna
      String nama = userData['name'];
      String jabatan = userData['position'];
      String notelp = userData['phone'];

      // Membuat objek data kegiatan
      Map<String, dynamic> kegiatanData = {
        'user_id': widget.userId,
        'nama_puskesmas': namaPuskesmas,
        'dropdown_option': dropdownValue,
        'tanggal_kegiatan': tanggalKegiatan,
        'nama': nama, // Mengisi kolom nama dengan data pengguna
        'jabatan': jabatan, // Mengisi kolom jabatan dengan data pengguna
        'notelepon': notelp, // Mengisi kolom nomor telepon dengan data pengguna
      };

      // Memasukkan data kegiatan ke dalam database
      int kegiatanId = await DatabaseHelper().insertKegiatan(kegiatanData);

      // Mengosongkan input setelah data disimpan
      namaPuskesmasController.clear();
      setState(() {
        selectedDate = null;
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
