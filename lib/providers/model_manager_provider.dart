import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;

class ModelManagerState {
  final bool hasModel;
  final String path;
  const ModelManagerState({this.hasModel = false, this.path = ''});
}

class ModelManager extends StateNotifier<ModelManagerState> {
  ModelManager(): super(const ModelManagerState()) {
    _loadManifest();
  }

  Future<void> _loadManifest() async {
    try {
      final s = await rootBundle.loadString('assets/models/manifest.json');
      final data = jsonDecode(s);
      final model = data['models']?[0];
      final localPath = model?['localPath'] ?? '';
      if (localPath != null && localPath.isNotEmpty) {
        state = ModelManagerState(hasModel: true, path: localPath);
      }
    } catch (e) {
      // ignore
    }
  }
}

final modelManagerProvider = StateNotifierProvider<ModelManager, ModelManagerState>((ref) {
  return ModelManager();
});

