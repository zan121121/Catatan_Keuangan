import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dompetku.db');

    return await openDatabase(
      path,
      version: 2, // PENTING: naikkan versi
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            pin TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS transaksi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis TEXT NOT NULL,
            kategori TEXT NOT NULL,
            jumlah INTEGER NOT NULL,
            tanggal TEXT NOT NULL,
            keterangan TEXT
          )
        ''');
      },
    );
  }
}
