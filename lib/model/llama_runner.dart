// Placeholder for llama runner integration
import 'runner.dart';

class LlamaRunner {
  // currently mocked
  Future<String> generate(String prompt) async {
    return Runner.mockGenerate('generic', {}, []);
  }
}

import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'runner.dart';

class LlamaRunner implements ModelRunner {
  static const _ch = MethodChannel('llama_runner');

  bool _loaded = false;

  @override
  Future<void> init({required String modelPath, int nCtx = 512, int nThreads = 4, int nGpuLayers = 0}) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      _loaded = true; return;
    }
    await _ch.invokeMethod('init', {
      'modelPath': modelPath,
      'nCtx': nCtx,
      'nThreads': nThreads,
      'nGpuLayers': nGpuLayers,
    });
    _loaded = true;
  }

  @override
  Future<String> generate({required String prompt, int maxTokens = 200, double temperature = 0.7, double topP = 0.9, List<String>? stop}) async {
    if (!_loaded) return "（模型未加载，使用模板兜底）";
    if (!(Platform.isAndroid || Platform.isIOS)) {
      // Mock：非移动端返回简短占位，保证演示流程
      final p = prompt.trim();
      if (p.contains("提问意图")) return "请问你们结婚几年了？目前是否分居？";
      return "【基本判断】根据已知情况建议先行调解并准备证据。\n【下一步建议】1) 准备分居与照料证据；2) 整理房产与流水；3) 协商不成再起诉。\n【免责声明】此为一般性信息，非正式法律意见。";
    }
    final r = await _ch.invokeMethod<String>('generate', {
      'prompt': prompt,
      'maxTokens': maxTokens,
      'temperature': temperature,
      'topP': topP,
      'stop': stop ?? []
    });
    return (r ?? "").trim();
  }

  @override
  Future<void> unload() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _ch.invokeMethod('unload');
    }
    _loaded = false;
  }
}

