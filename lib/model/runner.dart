class Runner {
  static String mockGenerate(String topic, Map<String, String> slots, List<String> lawpoints) {
    final buffer = StringBuffer();
    buffer.writeln('以下是基于您提供信息的法律建议（示例）：');
    buffer.writeln();
    buffer.writeln('1. 初步判断：根据描述，可能涉及 $topic 相关法律问题。');
    buffer.writeln('2. 建议步骤：');
    buffer.writeln('- 收集证据并保留证据原件；');
    buffer.writeln('- 与对方沟通或咨询律师；');
    buffer.writeln('- 必要时申请仲裁或提起诉讼。');
    buffer.writeln();
    buffer.writeln('参考要点：');
    for (var p in lawpoints) {
      buffer.writeln('- $p');
    }
    // ensure length ~150-220 chars
    var out = buffer.toString();
    if (out.length < 150) {
      out = out + '\n建议：及时咨询专业律师以获取详细法律意见。';
    }
    return out;
  }
}

import 'dart:async';
import 'llama_runner.dart';

abstract class ModelRunner {
  Future<void> init({required String modelPath, int nCtx = 512, int nThreads = 4, int nGpuLayers = 0});
  Future<String> generate({required String prompt, int maxTokens = 256, double temperature = 0.7, double topP = 0.9, List<String>? stop});
  Future<void> unload();
}

class Runner {
  static final Runner _instance = Runner._internal();
  factory Runner() => _instance;
  Runner._internal();

  ModelRunner? _impl;

  void setImpl(ModelRunner impl) {
    _impl = impl;
  }

  Future<void> init(String modelPath, {int nCtx = 512, int nThreads = 4, int nGpuLayers = 0}) async {
    if (_impl == null) throw Exception('ModelRunner impl not set');
    await _impl!.init(modelPath: modelPath, nCtx: nCtx, nThreads: nThreads, nGpuLayers: nGpuLayers);
  }

  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    if (_impl == null) throw Exception('ModelRunner impl not set');
    return await _impl!.generate(prompt: prompt, maxTokens: maxTokens);
  }

  Future<void> unload() async {
    if (_impl == null) return;
    await _impl!.unload();
  }
}


