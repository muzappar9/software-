import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemma_service.dart';

// Gemma模型状态
class GemmaState {
  final bool isConnected;
  final bool isModelLoaded;
  final String modelName;
  final int modelSize;
  final bool isLoading;
  final String? error;

  const GemmaState({
    this.isConnected = false,
    this.isModelLoaded = false,
    this.modelName = '未连接',
    this.modelSize = 0,
    this.isLoading = false,
    this.error,
  });

  GemmaState copyWith({
    bool? isConnected,
    bool? isModelLoaded,
    String? modelName,
    int? modelSize,
    bool? isLoading,
    String? error,
  }) {
    return GemmaState(
      isConnected: isConnected ?? this.isConnected,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      modelName: modelName ?? this.modelName,
      modelSize: modelSize ?? this.modelSize,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Gemma状态管理
class GemmaNotifier extends StateNotifier<GemmaState> {
  final GemmaService _gemmaService;

  GemmaNotifier(this._gemmaService) : super(const GemmaState()) {
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isConnected = await _gemmaService.initializeModel();
      if (isConnected) {
        final status = await _gemmaService.getModelStatus();
        state = state.copyWith(
          isConnected: true,
          isModelLoaded: status['model_loaded'] ?? false,
          modelName: status['model_name'] ?? '未找到',
          modelSize: status['model_size'] ?? 0,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isConnected: false,
          isLoading: false,
          error: 'Ollama服务未运行',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshStatus() async {
    await _initializeModel();
  }

  Future<String> askQuestion(String question, String language) async {
    try {
      return await _gemmaService.askLegalQuestion(
        question: question,
        language: language,
      );
    } catch (e) {
      throw Exception('提问失败: $e');
    }
  }
}

// Provider定义
final gemmaServiceProvider = Provider<GemmaService>((ref) {
  return GemmaService();
});

final gemmaProvider = StateNotifierProvider<GemmaNotifier, GemmaState>((ref) {
  final gemmaService = ref.watch(gemmaServiceProvider);
  return GemmaNotifier(gemmaService);
}); 