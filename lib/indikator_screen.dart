import 'package:flutter/material.dart';

class IndikatorScreen extends StatelessWidget {
  final int userId;
  final int? kegiatanId;  // Tambahkan parameter kegiatanId
   IndikatorScreen({required this.userId, this.kegiatanId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Indikator Penilaian"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter logic
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari Indikator",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,  // The number of items in the grid
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/images/logors.jpg', fit: BoxFit.contain, height: 120),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "ACARBOSE",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text("Acarbose 50 mg Tablet"),
                      SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
