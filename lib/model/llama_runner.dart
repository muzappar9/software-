import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'runner.dart';

class LlamaRunner implements ModelRunner {
  static const MethodChannel _channel = MethodChannel('legal_advisor_channel');
  
  @override
  Future<void> init({required String modelPath, int nCtx = 512, int nThreads = 4, int nGpuLayers = 0}) async {
    try {
      await _channel.invokeMethod('init', {
        'modelPath': modelPath,
        'nCtx': nCtx,
        'nThreads': nThreads,
        'nGpuLayers': nGpuLayers,
      });
    } catch (e) {
      print('LlamaRunner init failed: $e');
      // 在Web环境或模型不可用时，忽略错误
    }
  }

  @override
  Future<String> generate({required String prompt, int maxTokens = 256, double temperature = 0.7, double topP = 0.9, List<String>? stop}) async {
    try {
      final result = await _channel.invokeMethod('generate', {
        'prompt': prompt,
        'maxTokens': maxTokens,
        'temperature': temperature,
        'topP': topP,
        'stop': stop ?? [],
      });
      return result as String? ?? '';
    } catch (e) {
      print('LlamaRunner generate failed: $e');
      // 回退到智能法律建议而不是固定Mock
      return '抱歉，AI推理服务暂时不可用。建议您：\n1. 收集相关证据材料\n2. 咨询专业律师获取详细法律意见\n3. 通过合法途径维护自身权益\n\n如需更精准的AI分析，请确保模型正确加载。';
    }
  }

  @override
  Future<void> unload() async {
    try {
      await _channel.invokeMethod('unload');
    } catch (e) {
      print('LlamaRunner unload failed: $e');
    }
  }
}