import 'db_helper.dart';

class TransaksiDB {
  static Future<void> insert(Map<String, dynamic> data) async {
    final db = await DBHelper.database;
    await db.insert('transaksi', data);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DBHelper.database;
    return db.query('transaksi', orderBy: 'id DESC');
  }

  static Future<Map<String, int>> getTotal() async {
    final db = await DBHelper.database;
    final data = await db.query('transaksi');

    int masuk = 0;
    int keluar = 0;

    for (var t in data) {
      if (t['jenis'] == 'Masuk') {
        masuk += t['jumlah'] as int;
      } else {
        keluar += t['jumlah'] as int;
      }
    }

    return {'masuk': masuk, 'keluar': keluar};
  }
}
