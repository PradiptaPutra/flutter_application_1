import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 7, // Increment the version number
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Indikator (
        id_indikator INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_indikator TEXT,
        aspek TEXT
      )
    ''');

    // Insert default data into Indikator table
    await db.execute('''
      INSERT INTO Indikator (nama_indikator, aspek) VALUES
      ('Fasiltas pelayanan kesehatan', 'fisik'),
      ('SDM kesehatan', 'non_fisik'),
      ('Program kesehatan', 'non_fisik'),
      ('Pembiayaan kesehatan', 'non_fisik')
    ''');
  }

  Future _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE DataEntry ADD COLUMN kegiatan_id INTEGER REFERENCES Kegiatan(kegiatan_id)');
    }
  }

  Future<void> insertPengguna(Map<String, dynamic> pengguna) async {
    final db = await database;
    await db.insert('Pengguna', pengguna, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int?> verifyLogin(String username, String password) async {
    final db = await database;
    List<Map> results = await db.query(
      'Pengguna',
      columns: ['user_id', 'username', 'password_hash'],
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, password],
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
}
