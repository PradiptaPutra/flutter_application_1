import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final data = await _dbHelper.getUserData(widget.userId);
    setState(() {
      userData = data;
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: widget.userId, userData: userData!),
      ),
    ).then((value) {
      if (value == true) {
        _loadUserData();
      }
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacementNamed(context, '/logreg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menambahkan baris ini
        title: Text('Profil'),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person, size: 30),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData!['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userData!['phone'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                     userData!['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: _navigateToEditProfile,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.qr_code),
                              SizedBox(width: 10),
                              Text(
                                'Kode Identitas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Umum',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.person_outline),
                            title: Text('Profil Tertaut'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.help_outline),
                            title: Text('Pusat Bantuan'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text('Nomor Gawat Darurat Nasional'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.book),
                            title: Text('Tentang'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preferensi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.notifications),
                            title: Text('Notifikasi'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.language),
                            title: Text('Bahasa'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text('Keamanan Akun'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: Icon(Icons.exit_to_app),
                            title: Text('Keluar'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
