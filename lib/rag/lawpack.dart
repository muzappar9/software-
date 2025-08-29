import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Lawpack {
  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lawpack.db');
    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }

  Future<List<String>> searchTopK(String topic, int k) async {
    try {
      final db = await _open();
      final rows = await db.rawQuery('SELECT snippet FROM lawpack WHERE topic = ? LIMIT ?', [topic, k]);
      return rows.map((r) => r['snippet'] as String).toList();
    } catch (e) {
      return <String>[];
    }
  }
}

import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class LawPack {
  final Database db;
  LawPack(this.db);

  static Future<LawPack> open(String path) async {
    final db = await openDatabase(path);
    return LawPack(db);
  }

  Future<List<Map<String, dynamic>>> retrieve(String query, {int k = 8}) async {
    // 占位版：优先使用 hints 中的要点，其次返回默认样例
    final lower = query.toLowerCase();
    if (lower.contains('离婚')) {
      final s = LAW_HINTS['divorce'] ?? [];
      return List.generate(min(k, s.length), (i) => {"id": "h$i", "text": s[i], "score": 1.0 - i * 0.1});
    }
    if (lower.contains('工资') || lower.contains('欠薪') || lower.contains('劳动')) {
      final s = LAW_HINTS['labor_dispute'] ?? [];
      return List.generate(min(k, s.length), (i) => {"id": "h$i", "text": s[i], "score": 1.0 - i * 0.1});
    }
    final s = LAW_HINTS['generic_case'] ?? [];
    return List.generate(min(k, s.length), (i) => {"id": "h$i", "text": s[i], "score": 1.0 - i * 0.1});
  }

  Future<Map<String, int>> stats() async {
    final chunks = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM chunks')) ?? 0;
    final articles = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM articles')) ?? 0;
    return {'chunks': chunks, 'articles': articles};
  }
}

