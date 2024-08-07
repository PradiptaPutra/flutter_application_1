import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';

class DatabaseHelper {
 static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }
 Future<Database> _initDatabase() async {
    // Get the path to the database
    String path = join(await getDatabasesPath(), 'health_app.db');
    print('Database initialized at path: $path');

    // Check if the database file exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time the app is run after installation
      print('Creating new database...');
      // Copy your database initialization code here
      _database = await openDatabase(
        path,
        version: 16, // Update the version number as needed
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
      );
    } else {
      // If the database already exists, open it
      _database = await openDatabase(path);
    }

    return _database!;
  }
//   Future<Database> initializeDatabase() async {
//   String path = join(await getDatabasesPath(), 'health_app.db');
//   print('Database initialized at path: $path');
//   return openDatabase(
//     path,
//     version: 15, // Meningkatkan nomor versi database
//     onCreate: _createDb,
//     onUpgrade: _upgradeDb,
//   );
// }


  Future _createDb(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS Pengguna (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT, 
      username TEXT, 
      password_hash TEXT, 
      email TEXT, 
      name TEXT,
      position TEXT,
      phone TEXT,
      created_at TEXT,
      kodeverif TEXT  -- Add new column
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS DataEntry (
      entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      kegiatan_id INTEGER,
      id_category INTEGER,
      puskesmas TEXT,
      indikator TEXT,
      sub_indikator TEXT,
      kriteria TEXT,
      SPM TEXT,
      SBL TEXT,
      SDH TEXT,
      sebelum TEXT,
      sesudah TEXT,
      sebelum2 TEXT,
      sesudah2 TEXT,
      indikator1 TEXT,
      indikator2 TEXT,
      indikator3 TEXT,
      indikator4 TEXT,
      keterangan TEXT,
      skor TEXT,          -- Kolom baru
      jumlah INTEGER,     -- Kolom baru
      FOREIGN KEY(user_id) REFERENCES Pengguna(user_id),
      FOREIGN KEY(kegiatan_id) REFERENCES Kegiatan(kegiatan_id)
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS Kegiatan (
      kegiatan_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      nama_puskesmas TEXT,
      dropdown_option TEXT,
      provinsi TEXT,
      kabupaten_kota TEXT,
      kelurahan TEXT,
      kecamatan TEXT,
      tanggal_kegiatan TEXT,
      nama TEXT,
      jabatan TEXT,
      notelepon TEXT,
      foto TEXT, -- New column for storing photos as binary data
      lokasi TEXT,
      FOREIGN KEY(user_id) REFERENCES Pengguna(user_id)
    )
  ''');
}

  Future _upgradeDb(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 7) {
    await db.execute('ALTER TABLE DataEntry ADD COLUMN kegiatan_id INTEGER REFERENCES Kegiatan(kegiatan_id)');
  }
  if (oldVersion < 8) {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tblbangunan (
        id_tbl INTEGER PRIMARY KEY AUTOINCREMENT,
        panduan_pertanyaan TEXT,
        nama_indikator TEXT,
        sub_indikator TEXT,
        kriteria TEXT,
        id_sebelum TEXT,
        id_sesudah TEXT
      )
    ''');
  }
  if (oldVersion < 9) {
    await db.execute('ALTER TABLE DataEntry ADD COLUMN id_category INTEGER');
  }
  if (oldVersion < 10) {
    await db.execute('ALTER TABLE DataEntry ADD COLUMN sebelum2 TEXT');
    await db.execute('ALTER TABLE DataEntry ADD COLUMN sesudah2 TEXT');
  }
  if (oldVersion < 11) {
    await db.execute('ALTER TABLE DataEntry ADD COLUMN SPM TEXT');
    await db.execute('ALTER TABLE DataEntry ADD COLUMN SBL TEXT');
    await db.execute('ALTER TABLE DataEntry ADD COLUMN SDH TEXT');
  }
  if (oldVersion < 12) {
    await db.execute('ALTER TABLE DataEntry ADD COLUMN indikator1 TEXT');
    await db.execute('ALTER TABLE DataEntry ADD COLUMN indikator2 TEXT');
    await db.execute('ALTER TABLE DataEntry ADD COLUMN indikator3 TEXT');
    await db.execute('ALTER TABLE DataEntry ADD COLUMN indikator4 TEXT');
  }
  // Tidak perlu ada perubahan untuk versi 13 karena tabel dibuat ulang dengan kolom baru
}


 Future<void> insertPengguna(Map<String, dynamic> pengguna) async {
  final db = await database;
  await db.insert(
    'Pengguna',
    pengguna,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

  Future<int?> verifyLogin(String username, String password, String verificationCode) async {
  final db = await database;
  final passwordHash = sha256.convert(utf8.encode(password)).toString();
  List<Map> results = await db.query(
    'Pengguna',
    columns: ['user_id', 'username', 'password_hash', 'kodeverif'], // Include 'kodeverif' column
    where: 'username = ? AND password_hash = ? AND kodeverif = ?', // Add 'kodeverif' check
    whereArgs: [username, passwordHash, verificationCode], // Pass verificationCode as a parameter
  );
  if (results.isNotEmpty) {
    return results.first['user_id'] as int?;
  }
  return null;
}


  Future<String?> getEmailByUserId(int userId) async {
    final db = await database;
    List<Map> results = await db.query(
      'Pengguna',
      columns: ['email'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return results.first['email'] as String?;
    }
    return null;
  }

  Future<void> insertDataEntry(Map<String, dynamic> dataEntry) async {
    final db = await database;
    await db.insert('DataEntry', dataEntry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveDataEntry(Map<String, dynamic> dataEntry) async {
    final db = await database;
    if (dataEntry.containsKey('entry_id') && dataEntry['entry_id'] != null) {
      int entryId = dataEntry['entry_id'];
      await db.update(
        'DataEntry',
        dataEntry,
        where: 'entry_id = ?',
        whereArgs: [entryId],
      );
    } else {
      await db.insert('DataEntry', dataEntry);
    }
  }


  Future<void> saveDataEntry2(Map<String, dynamic> dataEntry) async {
    final db = await database;
    await db.insert('entries', dataEntry);
  }

  Future<List<Map<String, dynamic>>> getDataEntriesForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DataEntry',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps;
  }

  Future<Map<String, dynamic>?> getUserData(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Pengguna',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
  // Metode untuk mengambil tanggal kegiatan
  Future<String> getTanggalKegiatan(int kegiatanId) async {
    final db = await database;
    var result = await db.query(
      'kegiatan',
      columns: ['tanggal_kegiatan'],
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );
    if (result.isNotEmpty) {
      return result.first['tanggal_kegiatan'] as String? ?? 'Tidak ada tanggal';
    } else {
      return 'Tidak ada tanggal';
    }
  }

   Future<String> getLokasiKegiatan(int kegiatanId) async {
    final db = await database;
    var result = await db.query(
      'kegiatan',
      columns: ['lokasi'],
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );
    if (result.isNotEmpty) {
      return result.first['lokasi'] as String? ?? 'Tidak ada tanggal';
    } else {
      return 'tidak ada lokasi';
    }
  }

  // Metode untuk mengambil semua data pengguna
 Future<List<Map<String, dynamic>>> getAllPengguna(int userId) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'Pengguna',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
  return result;
}

  // Metode untuk mengambil semua data pengguna
 Future<List<Map<String, dynamic>>> getAllKegiatan(int userId,kegiatanId) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'Kegiatan',
    where: 'user_id = ? AND kegiatan_id = ?',
    whereArgs: [userId,kegiatanId],
  );
  return result;
}




  // Metode untuk mengambil category_id yang sudah diselesaikan
  Future<List<int>> getCompletedCategoriesForKegiatan(int kegiatanId, List<int> requiredCategories) async {
    Database db = await database;

    // Fetch completed categories for the given kegiatan_id
    List<Map<String, dynamic>> dataEntries = await db.query(
      'dataentry',
      columns: ['id_category'],
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );

    List<int> completedCategories = [];

    // Check each required category
    for (int category in requiredCategories) {
      bool isCompleted = dataEntries.any((entry) => entry['id_category'] == category);
      if (isCompleted) {
        completedCategories.add(category);
      }
    }

    return completedCategories;
  }

  Future<void> updateUserData(Map<String, dynamic> userData) async {
    final db = await database;
    await db.update(
      'Pengguna',
      userData,
      where: 'user_id = ?',
      whereArgs: [userData['user_id']],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<int> insertKegiatan(Map<String, dynamic> kegiatan) async {
  //   final db = await database;
  //   return await db.insert('Kegiatan', kegiatan, conflictAlgorithm: ConflictAlgorithm.replace);
  // }
   Future<int> insertPuskesmas(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Kegiatan', row);
  }

  Future<List<Map<String, dynamic>>> getKegiatanForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kegiatan',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps;
  }

  Future<void> insertIndikator(Map<String, dynamic> indikator) async {
    final db = await database;
    await db.insert('Indikator', indikator, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getIndikators() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Indikator');
    return maps;
  }

  Future<Map<String, dynamic>?> loadDataEntry(int entryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DataEntry',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getEntriesByEntryId(int entryId) async {
    final db = await database;
    return await db.query(
      'DataEntry',
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
  }

  Future<List<Map<String, dynamic>>> getEntriesByKegiatanId(int kegiatanId) async {
    final db = await database;
    return await db.query(
      'DataEntry',
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );
  }

 Future<List<String>> getUniquePuskesmasNames(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Kegiatan',
      columns: ['DISTINCT nama_puskesmas'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((row) => row['nama_puskesmas'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getScheduledSurveys(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Kegiatan',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> loadExcelDataDirectly(String assetPath) async {
    List<Map<String, dynamic>> excelData = [];
    try {
      ByteData data = await rootBundle.load(assetPath);
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet != null) {
          for (var row in sheet.rows.skip(1)) { // Skip header row
            if (row.length >= 5) {
              var rowData = {
                'nama_indikator': row[1]?.value?.toString(),
                'sub_indikator': row[2]?.value?.toString(),
                'keterangan': row[3]?.value?.toString(),
                'kriteria': row[4]?.value?.toString(),
              };
              excelData.add(rowData);
            } else {
              print('Error: Row does not have enough columns');
            }
          }
        }
      }
    } catch (e) {
      print('Error loading Excel data: $e');
    }
    return excelData;
  }
Future<List<Map<String, dynamic>>> getKegiatanForUserSorted(int userId, bool ascending) async {
    final db = await database;
    String orderBy = ascending ? 'tanggal_kegiatan ASC' : 'tanggal_kegiatan DESC';
    return await db.query(
      'kegiatan',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: orderBy, // Mengurutkan berdasarkan tanggal_kegiatan
    );
  }
  Future<double?> getSdhValue(int? kegiatanId, int categoryId, String indikator) async {
    final db = await database;

    print('Query Arguments - kegiatanId: $kegiatanId, categoryId: $categoryId, indikator: $indikator');

    List<Map<String, dynamic>> result = await db.query(
      'dataentry',
      columns: ['SDH'],
      where: 'kegiatan_id = ? AND id_category = ? AND indikator = ?',
      whereArgs: [kegiatanId, categoryId, indikator],
      limit: 1,
    );

    print('Query Result: $result');

    if (result.isNotEmpty && result[0]['SDH'] != null) {
      // Convert the SDH value from String to double
      return double.tryParse(result[0]['SDH'].toString());
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getEntriesByKegiatanIdAndIndikator(int kegiatanId, int categoryId, String indikator) async {
    final db = await database;

    return await db.query(
      'DataEntry',
      where: 'kegiatan_id = ? AND id_category = ? AND indikator = ?',
      whereArgs: [kegiatanId, categoryId, indikator],
    );
  }

Future<void> updateKegiatanPhoto(int kegiatanId, Uint8List photoData) async {
  final db = await database;
  await db.update(
    'Kegiatan',
    {'foto': photoData},
    where: 'kegiatan_id = ?',
    whereArgs: [kegiatanId],
  );
}

Future<Uint8List?> getKegiatanPhoto(int kegiatanId) async {
  final db = await database;
  List<Map<String, dynamic>> result = await db.query(
    'Kegiatan',
    columns: ['foto'],
    where: 'kegiatan_id = ?',
    whereArgs: [kegiatanId],
    limit: 1,
  );
  if (result.isNotEmpty) {
    // Convert BLOB data back to Uint8List
    return result.first['foto'] as Uint8List?;
  }
  return null;
}

Future<List<Map<String, dynamic>>> getEntriesByKegiatanIdAndKriteria(int kegiatanId, String kriteria, String indikator) async {
    final db = await database;
    return await db.query(
      'DataEntry',
      where: 'kegiatan_id = ? AND kriteria = ? AND indikator = ?',
      whereArgs: [kegiatanId, kriteria, indikator],
    );
  }
  Future<List<Map<String, dynamic>>> getEntriesByKegiatanIdAndCategoryAndUser(int kegiatanId, int categoryId, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DataEntry',
      where: 'kegiatan_id = ? AND id_category = ? AND user_id = ?',
      whereArgs: [kegiatanId, categoryId, userId],
    );
    return maps;
  }

  Future<int> updateDataEntry3(Map<String, dynamic> entry) async {
    final db = await database;

    return await db.update(
      'DataEntry',
      entry,
      where: 'entry_id = ?',
      whereArgs: [entry['entry_id']],
    );
  }
  Future<void> updateDataEntry(Map<String, dynamic> dataEntry) async {
    final db = await database;
    await db.update(
      'DataEntry',
      dataEntry,
      where: 'kegiatan_id = ? AND kriteria = ?',
      whereArgs: [dataEntry['kegiatan_id'], dataEntry['kriteria']],
    );
  }
Future<void> updateDataEntry2(Map<String, dynamic> dataEntry) async {
    final db = await database;
    await db.update(
      'entries',
      dataEntry,
      where: 'kegiatan_id = ? AND kriteria = ?',
      whereArgs: [dataEntry['kegiatan_id'], dataEntry['kriteria']],
    );
  }
  Future<List<Map<String, dynamic>>> loadExcelDataDirectly2(String assetPath) async {
    List<Map<String, dynamic>> excelData = [];
    try {
      ByteData data = await rootBundle.load(assetPath);
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet != null) {
          for (var row in sheet.rows.skip(1)) { // Skip header row
            var namaIndikator = row[1]?.value;
            var subIndikator = row[2]?.value;

            var rowData = {
              'nama_indikator': namaIndikator?.toString(),
              'sub_indikator': subIndikator?.toString(),
            };

            excelData.add(rowData);
          }
        }
      }
    } catch (e) {
      print('Error loading Excel data: $e');
    }
    return excelData;
  }

  Future<void> insertExcelData(List<Map<String, dynamic>> excelData) async {
    final db = await database;
    for (var row in excelData) {
      await db.insert('tblbangunan', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> getExcelData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tblbangunan');
    return maps;
  }

  Future<String> loadRowData(int rowIndex) async {
    try {
      ByteData data = await rootBundle.load('assets/form_penilaian_bangunan.xlsx');
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet != null && sheet.rows.length > rowIndex) {
          var row = sheet.rows[rowIndex];
          return row.map((cell) => cell?.value?.toString() ?? '').join(', ');
        }
      }
    } catch (e) {
      print('Error loading Excel row data: $e');
    }
    return 'Data tidak ditemukan';
  }

  Future<String> loadRowData2(int rowIndex) async {
    try {
      ByteData data = await rootBundle.load('assets/form_penilaian_bangunan.xlsx');
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet != null && sheet.rows.length > rowIndex) {
          var row = sheet.rows[rowIndex];
          return row.map((cell) => cell?.value?.toString() ?? '').join(', ');
        }
      }
    } catch (e) {
      print('Error loading Excel row data: $e');
    }
    return 'Data tidak ditemukan';
  }

  Future<List<Map<String, dynamic>>> getDataEntriesForUserHome(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT kegiatan_id, nama_puskesmas, dropdown_option , provinsi ,kabupaten_kota, foto
      FROM Kegiatan 
      WHERE user_id = ?
    ''', [userId]);
    return maps;
  }
 Future<Uint8List?> getImageByKegiatanId(int kegiatanId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kegiatan',
      columns: ['foto'],
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );

    if (maps.isNotEmpty) {
      String fotoName = maps.first['foto'] as String;
      String fotoPath = '/storage/emulated/0/Android/data/com.example.flutter_application_1/files/fotopuskesmas/$fotoName';
      File file = File(fotoPath);
      return await file.readAsBytes();
    }
    return null;
  }
  Future<File?> getImageFileByKegiatanId(int kegiatanId) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'kegiatan', // Sesuaikan nama tabelnya
    where: 'kegiatan_id = ?',
    whereArgs: [kegiatanId],
  );

  if (maps.isNotEmpty) {
    String? imageName = maps.first['foto'];
    if (imageName != null) {
      String imagePath = '/storage/emulated/0/Android/data/com.example.flutter_application_1/files/fotopuskesmas/$imageName';
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
    }
  }
  return null;
}
  Future<bool> entryExists(int kegiatanId, String kriteria) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'DataEntry',
      where: 'kegiatan_id = ? AND kriteria = ?',
      whereArgs: [kegiatanId, kriteria],
    );
    return result.isNotEmpty;
  }
   Future<List<Map<String, dynamic>>> getKegiatanForUserSortedAndFiltered(int userId, bool ascending, String query) async {
    Database db = await database;
    String orderBy = ascending ? 'ASC' : 'DESC';
    List<Map<String, dynamic>> result = await db.query(
      'kegiatan',
      where: 'user_id = ? AND nama_puskesmas LIKE ?',
      whereArgs: [userId, '%$query%'],
      orderBy: 'tanggal_kegiatan $orderBy',
    );
    return result;
  }
  Future<double> getProgressForKegiatan(int kegiatanId) async {
    final db = await database;
    final List<Map<String, dynamic>> entries = await db.rawQuery('''
      SELECT sebelum, sesudah, sebelum2, sesudah2,SPM,SBL,SDH,indikator1,indikator2,indikator3,indikator4
      FROM DataEntry
      WHERE kegiatan_id = ?
    ''', [kegiatanId]);

    int totalFields =11; // Total fields to check (sebelum, sesudah, sebelum2, sesudah2)
    int filledFields = 0;

    for (var entry in entries) {
      if (entry['sebelum'] != null && entry['sebelum'].toString().isNotEmpty) filledFields++;
      if (entry['sesudah'] != null && entry['sesudah'].toString().isNotEmpty) filledFields++;
      if (entry['sebelum2'] != null && entry['sebelum2'].toString().isNotEmpty) filledFields++;
      if (entry['sesudah2'] != null && entry['sesudah2'].toString().isNotEmpty) filledFields++;
      if (entry['SPM'] != null && entry['SPM'].toString().isNotEmpty) filledFields++;
      if (entry['SBL'] != null && entry['SBL'].toString().isNotEmpty) filledFields++;
      if (entry['SDH'] != null && entry['SDH'].toString().isNotEmpty) filledFields++;
      if (entry['indikator1'] != null && entry['indikator1'].toString().isNotEmpty) filledFields++;
      if (entry['indikator2'] != null && entry['indikator2'].toString().isNotEmpty) filledFields++;
      if (entry['indikator3'] != null && entry['indikator3'].toString().isNotEmpty) filledFields++;
      if (entry['indikator4'] != null && entry['indikator4'].toString().isNotEmpty) filledFields++;
    }

    if (entries.isNotEmpty) {
      return (filledFields / (entries.length * totalFields)) * 100;
    } else {
      return 0.0;
    }
  }


  Future<int> getPuskesmasSurveyedCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT nama_puskesmas) as count
      FROM Kegiatan
      WHERE user_id = ?
    ''', [userId]);
    print('Puskesmas surveyed count query result: $result');
    return result[0]['count'] as int;
  }

  Future<String> fetchDropdownOption(int kegiatanId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'Kegiatan',
      columns: ['dropdown_option'],
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );
    if (result.isNotEmpty) {
      return result.first['dropdown_option'] as String;
    }
    return ''; // Return empty string or handle null case as per your requirement
  }

  Future<void> deleteKegiatan(int kegiatanId) async {
  final db = await database;
  await db.delete(
    'kegiatan',
    where: 'kegiatan_id = ?',
    whereArgs: [kegiatanId],
  );
}

Future<int?> verifyLoginWithVerificationCode(String username, String password, String verificationCode) async {
  final db = await database;
  final List<Map<String, dynamic>> result = await db.query(
    'Pengguna',
    where: 'username = ? AND password_hash = ? AND kodeverif = ?',
    whereArgs: [username, sha256.convert(utf8.encode(password)).toString(), verificationCode],
  );

  print('Query result: $result'); // Debug print

  if (result.isNotEmpty) {
    return result.first['id'] as int?;
  } else {
    return null;
  }
}


Future<void> deleteDataEntriesForKegiatan(int kegiatanId) async {
  final db = await database;
  await db.delete(
    'DataEntry',
    where: 'kegiatan_id = ?',
    whereArgs: [kegiatanId],
  );
}
  Future<bool> isUsernameExist(String username) async {
    final db = await database;
    var res = await db.query("Pengguna", where: "username = ?", whereArgs: [username]);
    return res.isNotEmpty;
  }

  Future<bool> isEmailExist(String email) async {
    final db = await database;
    var res = await db.query("Pengguna", where: "email = ?", whereArgs: [email]);
    return res.isNotEmpty;
  }
    Future<String?> getPuskesmasNameByKegiatanId(int kegiatanId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'kegiatan',
      columns: ['nama_puskesmas'],
      where: 'kegiatan_id = ?',
      whereArgs: [kegiatanId],
    );
    if (result.isNotEmpty) {
      return result.first['nama_puskesmas'] as String?;
    }
    return null;
  }
}
