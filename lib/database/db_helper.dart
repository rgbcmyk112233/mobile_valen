import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nakamerch.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        isLoggedIn INTEGER DEFAULT 0
      );
    ''');

    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT,
        description TEXT
      );
    ''');

    await db.insert('products', {
      'name': 'Kaos Nakama',
      'price': 120000,
      'image': '',
      'description': 'Kaos official NakaMerch, nyaman dipakai.'
    });

    await db.insert('products', {
      'name': 'Hoodie Grand Line',
      'price': 250000,
      'image': '',
      'description': 'Hoodie tebal, motif eksklusif.'
    });
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    final res =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty;
  }

  Future<Map<String, dynamic>?> login(
      String email, String passwordHash) async {
    final db = await instance.database;
    final res = await db.query('users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, passwordHash],
        limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> setLoginSession(String email) async {
    final db = await database;

    await db.update('users', {'isLoggedIn': 0});
    await db.update('users', {'isLoggedIn': 1},
        where: 'email = ?', whereArgs: [email]);
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.update('users', {'isLoggedIn': 0});
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final db = await database;
    final res = await db
        .query('users', where: 'isLoggedIn = ?', whereArgs: [1], limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products', orderBy: 'id DESC');
  }

  // ✅ Tambahan supaya profil.dart tidak error
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final res =
        await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    return res.isNotEmpty ? res.first : null;
  }
}
