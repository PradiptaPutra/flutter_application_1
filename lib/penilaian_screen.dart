import 'package:flutter/material.dart';

class PenilaianScreen extends StatelessWidget {
  final int? kegiatanId;

  PenilaianScreen({this.kegiatanId});

  @override
  Widget build(BuildContext context) {
    var data = [
      {
        "title": "1.1 Tangga",
        "subtitle": "Dokter • 9 Tahun",
        "image": 'assets/images/logors.jpg',
        "hintTextSebelum": "Sebelum",
        "hintTextSesudah": "Sesudah"
      },
      {
        "title": "2.2 Sistem Sanitasi",
        "subtitle": "Sanitasi • 5 Tahun",
        "image": 'assets/images/logors.jpg',
        "hintTextSebelum": "Sebelum",
        "hintTextSesudah": "Sesudah"
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Penilaian'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: data.length, // Jumlah item yang ingin ditampilkan
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                color: Colors.grey[300],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(data[index]["image"]!),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index]["title"]!,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(data[index]["subtitle"]!),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                      SizedBox(height: 10), // Menambahkan jarak antar elemen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.help_outline),
                            onPressed: () {
                              // Handle help
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () {
                              // Handle view
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10), // Menambahkan jarak antar elemen
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: data[index]["hintTextSebelum"]!,
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: data[index]["hintTextSesudah"]!,
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');  // Navigate to the login route
              },
              child: Text('SIMPAN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(380, 50), // Size of button
              ),
            ),
          ),
        ],
      ),
    );
  }
}
