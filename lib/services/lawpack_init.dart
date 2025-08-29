import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LawPackInit {
  /// Copy assets/lawpack.db to app databases path if not exists
  static Future<String> copyDbFromAssetsIfNeeded() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbDir = p.join(documentsDir.path, 'databases');
    final dbPath = p.join(dbDir, 'lawpack.db');

    final dbDirFile = Directory(dbDir);
    if (!dbDirFile.existsSync()) dbDirFile.createSync(recursive: true);

    final exists = File(dbPath).existsSync();
    if (!exists) {
      try {
        final data = await rootBundle.load('assets/lawpack.db');
        final bytes = data.buffer.asUint8List();
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        // create empty file as fallback
        await File(dbPath).writeAsString('-- lawpack placeholder', flush: true);
      }
    }

    return dbPath;
  }
}

