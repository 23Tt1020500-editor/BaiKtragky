import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chi_tieu.dart';

class CoSoDuLieu {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'chi_tieu.db'),
      version: 1,
      onCreate: (db, v) => db.execute('''
        CREATE TABLE chi_tieu(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tieuDe TEXT NOT NULL,
          soTien REAL NOT NULL,
          danhMuc TEXT NOT NULL,
          ngay TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  static Future<int> them(ChiTieu c) async {
    final map = c.toMap()..remove('id');
    return (await db).insert('chi_tieu', map);
  }

  static Future<void> sua(ChiTieu c) async => (await db).update(
    'chi_tieu',
    c.toMap(),
    where: 'id = ?',
    whereArgs: [c.id],
  );

  static Future<void> xoa(int id) async =>
      (await db).delete('chi_tieu', where: 'id = ?', whereArgs: [id]);

  static Future<List<ChiTieu>> layTatCa() async {
    final rows = await (await db).query('chi_tieu', orderBy: 'ngay DESC');
    return rows.map(ChiTieu.fromMap).toList();
  }
}
