import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'health_app.db');
    print('Database initialized at path: $path');
    return openDatabase(
      path,
      version: 9, // Incremented version number
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

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
        created_at TEXT
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
        sebelum TEXT,
        sesudah TEXT,
        keterangan TEXT,
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
        tanggal_kegiatan TEXT,
        nama TEXT,
        jabatan TEXT,
        notelepon TEXT,
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
  }

  Future<void> insertPengguna(Map<String, dynamic> pengguna) async {
    final db = await database;
    await db.insert('Pengguna', pengguna, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int?> verifyLogin(String username, String password) async {
    final db = await database;
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    List<Map> results = await db.query(
      'Pengguna',
      columns: ['user_id', 'username', 'password_hash'],
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, passwordHash],
    );
    if (results.isNotEmpty) {
      return results.first['user_id'] as int?;
    }
    return null;
  }

  Future<void> insertDataEntry(Map<String, dynamic> dataEntry) async {
    final db = await database;
    await db.insert('DataEntry', dataEntry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDataEntry(int entryId, Map<String, dynamic> dataEntry) async {
    final db = await database;
    await db.update(
      'DataEntry',
      dataEntry,
      where: 'entry_id = ?',
      whereArgs: [entryId],
    );
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

  Future<int> insertKegiatan(Map<String, dynamic> kegiatan) async {
    final db = await database;
    return await db.insert('Kegiatan', kegiatan, conflictAlgorithm: ConflictAlgorithm.replace);
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

  Future<List<String>> getUniquePuskesmasNames() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT puskesmas FROM DataEntry WHERE puskesmas IS NOT NULL AND puskesmas != ''
    ''');
    List<String> puskesmasNames = result.map((row) => row['puskesmas'] as String).toList();
    return puskesmasNames;
  }

  Future<List<Map<String, dynamic>>> getScheduledSurveys() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Kegiatan');
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
}
