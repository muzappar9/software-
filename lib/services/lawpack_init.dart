import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LawPackInit {
  /// Copy assets/lawpack.db to app databases path if not exists
  static Future<String> copyDbFromAssetsIfNeeded() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbDir = p.join(documentsDir.path, 'databases');
    final dbPath = p.join(dbDir, 'lawpack.db');

    final dbDirFile = Directory(dbDir);
    if (!dbDirFile.existsSync()) dbDirFile.createSync(recursive: true);

    final exists = await File(dbPath).exists();
    if (!exists) {
      try {
        final data = await rootBundle.load('assets/lawpack.db');
        final bytes = data.buffer.asUint8List();
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        print('从assets复制数据库失败: $e');
        // 创建基础数据库结构
        await _createBasicDatabase(dbPath);
      }
    }

    return dbPath;
  }

  /// 创建基础数据库结构
  static Future<void> _createBasicDatabase(String dbPath) async {
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chunks (
            id INTEGER PRIMARY KEY,
            chunk_text TEXT,
            source TEXT
          )
        ''');
        
        await db.execute('''
          CREATE VIRTUAL TABLE articles_fts USING fts5(content)
        ''');
        
        // 插入基础法律条文
        await db.insert('chunks', {
          'chunk_text': '法律面前人人平等，任何组织或者个人都不得有超越宪法法律的特权。',
          'source': 'constitution'
        });
        
        await db.insert('chunks', {
          'chunk_text': '依法成立的合同，对当事人具有法律约束力。当事人应当按照约定履行自己的义务。',
          'source': 'contract_law'
        });
        
        await db.insert('chunks', {
          'chunk_text': '劳动者享有平等就业和选择职业的权利、取得劳动报酬的权利、休息休假的权利。',
          'source': 'labor_law'
        });
      },
    );
    await db.close();
  }
}

