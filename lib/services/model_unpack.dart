import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ModelUnpack {
  static const String assetDir = 'assets/models';
  static const String modelFile = 'gemma-3-270m-instruct-q4_0.gguf';

  static Future<File?> ensureLocalModel() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final out = File('${docs.path}/$modelFile');
      if (await out.exists() && (await out.length()) > 100 * 1024 * 1024) {
        return out;
      }
      final data = await rootBundle.load('$assetDir/$modelFile');
      final bytes = data.buffer.asUint8List();
      await out.create(recursive: true);
      final raf = await out.open(mode: FileMode.write);
      const chunk = 4 * 1024 * 1024;
      for (int i = 0; i < bytes.length; i += chunk) {
        await raf.writeFrom(bytes, i, (i + chunk < bytes.length) ? i + chunk : bytes.length);
      }
      await raf.close();
      return out;
    } catch (_) {
      // 若模型没随包（走 CI 下载），这里会失败；不影响演示，可提示"未就绪"
      return null;
    }
  }
}