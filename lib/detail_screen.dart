import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final int userId;

  DetailScreen({required this.userId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _puskesmasController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _kabupatenController = TextEditingController();
  final TextEditingController _noRespondenController = TextEditingController();

  void _submitDetails() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        '/category_selection',
        arguments: {
          'userId': widget.userId,
          'puskesmas': _puskesmasController.text,
          'tanggal': _tanggalController.text,
          'provinsi': _provinsiController.text,
          'kabupaten': _kabupatenController.text,
          'noResponden': _noRespondenController.text,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kegiatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _puskesmasController,
                decoration: InputDecoration(labelText: 'Nama Puskesmas'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _tanggalController,
                decoration: InputDecoration(labelText: 'Tanggal Kegiatan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _provinsiController,
                decoration: InputDecoration(labelText: 'Provinsi'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _kabupatenController,
                decoration: InputDecoration(labelText: 'Kabupaten/Kota'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _noRespondenController,
                decoration: InputDecoration(labelText: 'No. Responden'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitDetails,
                child: Text('Lanjutkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
