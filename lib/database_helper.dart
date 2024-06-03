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
    print('Database Path: $path');
    return openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Pengguna (
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
        puskesmas TEXT,
        indikator TEXT,
        sub_indikator TEXT,
        kriteria TEXT,
        sebelum TEXT,
        sesudah TEXT,
        keterangan TEXT,
        FOREIGN KEY(user_id) REFERENCES Pengguna(user_id)
      );
    ''');
  }

  Future _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE Pengguna ADD COLUMN name TEXT');
      await db.execute('ALTER TABLE Pengguna ADD COLUMN position TEXT');
      await db.execute('ALTER TABLE Pengguna ADD COLUMN phone TEXT');
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
    List<Map<String, dynamic>> results = await db.query(
      'Pengguna',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> updateUserProfile(int userId, Map<String, dynamic> userData) async {
    final db = await database;
    await db.update(
      'Pengguna',
      userData,
      where: 'user_id = ?',
      whereArgs: [userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
