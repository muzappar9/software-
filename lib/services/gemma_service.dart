import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GemmaService {
  static final GemmaService _instance = GemmaService._internal();
  factory GemmaService() => _instance;
  GemmaService._internal();

  final Logger _logger = Logger();
  
  // 模型配置
  static const String _modelName = 'gemma-3-270m';
  static const String _baseUrl = 'http://localhost:11434'; // Ollama服务地址
  
  // 法律知识库
  final Map<String, dynamic> _legalKnowledge = {
    'zh': {
      'divorce': '离婚相关法律知识...',
      'property': '财产分割相关法律...',
      'child_custody': '子女抚养相关法律...',
    },
    'ug': {
      'divorce': 'ئاجرىشىش ھەققىدە قانۇن...',
      'property': 'مۈلۈك تارقىتىش ھەققىدە...',
      'child_custody': 'بالا تەربىيەلەش ھەققىدە...',
    },
    'en': {
      'divorce': 'Legal knowledge about divorce...',
      'property': 'Legal knowledge about property division...',
      'child_custody': 'Legal knowledge about child custody...',
    }
  };

  /// 初始化Gemma模型
  Future<bool> initializeModel() async {
    try {
      // 检查Ollama服务是否运行
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _logger.i('Ollama服务连接成功');
        return true;
      }
    } catch (e) {
      _logger.w('Ollama服务未运行，将使用本地知识库: $e');
    }
    return false;
  }

  /// 发送法律咨询请求
  Future<String> askLegalQuestion({
    required String question,
    required String language,
    String? context,
  }) async {
    try {
      // 构建提示词
      final prompt = _buildPrompt(question, language, context);
      
      // 尝试使用Ollama API
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _modelName,
          'prompt': prompt,
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
            'max_tokens': 1000,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '抱歉，我无法回答这个问题。';
      }
    } catch (e) {
      _logger.w('API调用失败，使用本地知识库: $e');
    }

    // 回退到本地知识库
    return _getLocalResponse(question, language);
  }

  /// 构建提示词
  String _buildPrompt(String question, String language, String? context) {
    final languageMap = {
      'zh': '中文',
      'ug': '维吾尔语',
      'en': 'English',
    };

    return '''
你是一个专业的法律顾问，请用${languageMap[language] ?? '中文'}回答以下法律问题。

${context != null ? '背景信息：$context\n' : ''}
问题：$question

请提供：
1. 相关法律依据
2. 具体建议
3. 注意事项

回答：
''';
  }

  /// 本地知识库回答
  String _getLocalResponse(String question, String language) {
    // 简单的关键词匹配
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('离婚') || lowerQuestion.contains('divorce') || lowerQuestion.contains('ئاجرىشىش')) {
      return _legalKnowledge[language]?['divorce'] ?? '暂无相关信息';
    }
    
    if (lowerQuestion.contains('财产') || lowerQuestion.contains('property') || lowerQuestion.contains('مۈلۈك')) {
      return _legalKnowledge[language]?['property'] ?? '暂无相关信息';
    }
    
    if (lowerQuestion.contains('子女') || lowerQuestion.contains('child') || lowerQuestion.contains('بالا')) {
      return _legalKnowledge[language]?['child_custody'] ?? '暂无相关信息';
    }
    
    return _getDefaultResponse(language);
  }

  /// 获取默认回答
  String _getDefaultResponse(String language) {
    final responses = {
      'zh': '感谢您的咨询。建议您咨询专业律师获取更详细的法律建议。',
      'ug': 'سوئالڭىزغا رەھمەت. تەپسىرلىك ھوقۇقىي مەسلىھەت ئۈچۈن مۇتەخەسسىس ۋەكىلگە مۇراجىئەت قىلىڭ.',
      'en': 'Thank you for your question. Please consult a professional lawyer for detailed legal advice.',
    };
    
    return responses[language] ?? responses['zh']!;
  }

  /// 加载法律知识库
  Future<void> loadLegalDatabase() async {
    try {
      // 从assets加载法律数据
      final data = await rootBundle.loadString('assets/legal-data/laws.json');
      final laws = jsonDecode(data);
      // 这里可以扩展知识库
      _logger.i('法律知识库加载成功');
    } catch (e) {
      _logger.w('法律知识库加载失败: $e');
    }
  }

  /// 获取模型状态
  Future<Map<String, dynamic>> getModelStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        final gemmaModel = models.firstWhere(
          (model) => model['name'].toString().contains('gemma'),
          orElse: () => null,
        );

        return {
          'connected': true,
          'model_loaded': gemmaModel != null,
          'model_name': gemmaModel?['name'] ?? '未找到',
          'model_size': gemmaModel?['size'] ?? 0,
        };
      }
    } catch (e) {
      _logger.w('获取模型状态失败: $e');
    }

    return {
      'connected': false,
      'model_loaded': false,
      'model_name': '未连接',
      'model_size': 0,
    };
  }
} 