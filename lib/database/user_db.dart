import 'db_helper.dart';

class UserDB {
  static Future<bool> isUserExist() async {
    final db = await DBHelper.database;
    final result = await db.query('user');
    return result.isNotEmpty;
  }

  static Future<void> insertUser(String nama, String pin) async {
    final db = await DBHelper.database;
    await db.insert('user', {'nama': nama, 'pin': pin});
  }

  static Future<bool> checkPin(String pin) async {
    final db = await DBHelper.database;
    final result = await db.query('user', limit: 1);

    if (result.isEmpty) return false;
    return result.first['pin'] == pin;
  }
}
