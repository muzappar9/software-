import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/runner.dart';
import '../model/llama_runner.dart';
import '../model/prompts.dart';
import '../rag/lawpack.dart';
import '../rag/hints.dart';
import '../services/lawpack_init.dart';
import '../services/intelligent_chat_engine.dart';
import '../services/real_ai_engine.dart';

class ChatFlow {
  static Future<String> onUserTurn(BuildContext context, String userMessage, WidgetRef ref) async {
    print('🔄 ChatFlow.onUserTurn 被调用，用户输入: $userMessage');
    
    // 直接调用Android端真实AI推理，跳过复杂的槽位填充流程
    final result = await _callAndroidAI(userMessage);
    print('📝 ChatFlow 最终返回: $result');
    return result;
  }

  /// 直接调用Android端AI推理
  static Future<String> _callAndroidAI(String userMessage) async {
    print('🤖 _callAndroidAI 开始，输入: $userMessage');
    
    try {
      // 只在Android平台调用真实AI
      if (Platform.isAndroid) {
        final runner = LlamaRunner();
        print('📱 开始初始化模型...');
        await runner.init(modelPath: 'assets/models/gemma-3-270m.task');
        print('✅ 模型初始化完成，开始生成回复...');
        
        final response = await runner.generate(prompt: userMessage, maxTokens: 512);
        print('📝 Android端返回响应: $response');
        
        if (response.isNotEmpty) return response;
      }
      
      // Windows或其他平台使用智能回退
      return await _generateSmartResponse(userMessage);
      
    } catch (e) {
      print('❌ Android AI调用失败: $e');
      return await _generateSmartResponse(userMessage);
    }
  }

  /// 生成智能回复 - Windows平台专用
  static Future<String> _generateSmartResponse(String userMessage) async {
    final message = userMessage.toLowerCase();
    
    // 问候语
    if (message.contains('你好') || message.contains('hello') || message.contains('hi')) {
      return '您好！我是AI法律顾问，专门为您提供法律咨询服务。\n\n我可以帮助您：\n• 解答法律问题\n• 分析案件情况\n• 提供专业建议\n• 指导维权途径\n\n请告诉我您遇到的具体法律问题，我会为您详细分析。';
    }
    
    // 离婚相关
    if (message.contains('离婚') || message.contains('分居') || message.contains('夫妻')) {
      return '关于离婚问题，我为您分析如下：\n\n【法律依据】\n根据《民法典》相关规定，离婚有协议离婚和诉讼离婚两种方式。\n\n【具体建议】\n1. 协议离婚：双方协商一致，到民政局办理\n2. 诉讼离婚：一方不同意时，可向法院起诉\n3. 财产分割：夫妻共同财产原则上平等分割\n4. 子女抚养：以有利于子女成长为原则\n\n【注意事项】\n• 收集相关证据材料\n• 保护个人财产权益\n• 考虑子女最佳利益\n\n如需了解具体细节，请详细描述您的情况。';
    }
    
    // 合同相关
    if (message.contains('合同') || message.contains('违约') || message.contains('协议')) {
      return '关于合同问题，我为您提供以下分析：\n\n【合同效力】\n1. 检查合同是否合法有效\n2. 确认双方权利义务\n3. 识别违约责任条款\n\n【维权建议】\n• 保存完整合同文件\n• 收集履行证据\n• 及时主张权利\n• 必要时寻求法律救济\n\n【解决途径】\n1. 协商解决\n2. 调解处理\n3. 仲裁程序\n4. 诉讼维权\n\n请提供更多合同细节，我可以给出更具体的建议。';
    }
    
    // 劳动纠纷
    if (message.contains('工作') || message.contains('劳动') || message.contains('工资') || message.contains('辞职')) {
      return '关于劳动纠纷，我为您分析：\n\n【劳动权益】\n1. 工资报酬权\n2. 休息休假权\n3. 劳动保护权\n4. 社会保险权\n\n【常见问题处理】\n• 拖欠工资：申请劳动仲裁\n• 违法解除：要求经济补偿\n• 工伤事故：申请工伤认定\n• 加班费：收集加班证据\n\n【维权步骤】\n1. 收集劳动证据\n2. 申请劳动仲裁\n3. 必要时提起诉讼\n\n请详细说明您的劳动纠纷情况。';
    }
    
    // 通用法律回复
    return '感谢您的咨询。作为AI法律顾问，我需要了解更多细节才能为您提供准确的法律建议。\n\n【请提供以下信息】\n• 具体的法律问题类型\n• 相关事实和背景\n• 您希望达成的目标\n• 已有的证据材料\n\n【我的专业领域】\n✓ 婚姻家庭法\n✓ 合同纠纷\n✓ 劳动争议\n✓ 侵权责任\n✓ 房产纠纷\n\n请详细描述您的情况，我会为您提供专业的法律分析和建议。';
  }

  static Future<List<String>> generateSlots(String topic) async {
    try {
      var assetContent = await rootBundle.loadString('assets/slots/${topic}_zh.yaml');
      var yamlDoc = loadYaml(assetContent);
      
      if (yamlDoc['slots'] != null) {
        return List<String>.from(yamlDoc['slots']);
      }
    } catch (_) {}
    return <String>[];
  }

  static Future<List<String>> retrieveLawpack(String topic, Map<String, String> filled) async {
    try {
      // 简化版本，直接返回一些提示
      return Hints.getHints(topic);
    } catch (_) {
      return ['相关法律条文加载中...'];
    }
  }

  static Future<String> generateAdvice(String topic, Map<String, String> filled, List<String> lawpoints) async {
    // 使用智能聊天引擎生成建议
    final intelligentEngine = IntelligentChatEngine();
    return intelligentEngine.generateIntelligentAdvice(topic, filled, lawpoints);
  }
}

class _ChatFlow {
  static final _runner = LlamaRunner();
  static Map<String, dynamic> _slots = {};
  static Map<String, dynamic> _dsl = {};
  static late LawPack _rag;
  static int _turns = 0;

  static Future<void> init(String yamlPath) async {
    try {
      var assetContent = await rootBundle.loadString(yamlPath);
      _dsl = loadYaml(assetContent) as Map<String, dynamic>;
      _slots.clear();
      _turns = 0;

      // 初始化LawPack
      final dbFile = await LawPackInit.copyDbFromAssetsIfNeeded();
      _rag = await LawPack.open(dbFile);
    } catch (e) {
      // 如果失败，使用空的配置
      _dsl = {
        'name': 'default',
        'slots': {},
        'max_turns': 5,
      };
    }
  }

  static void resetSlots() {
    _slots.clear();
    _turns = 0;
  }

  static bool setSlot(String key, String value) {
    if (_dsl['slots']?[key] != null) {
      _slots[key] = value;
      return true;
    }
    return false;
  }

  static String? _nextIntent(Map<String, dynamic> slots) {
    final slotsConfig = _dsl['slots'] as Map<String, dynamic>? ?? {};
    for (String key in slotsConfig.keys) {
      if (!slots.containsKey(key)) {
        return key;
      }
    }
    return null;
  }

  static Future<String> generateResponse(String userInput) async {
    _turns++;
    
    // 尝试填充槽位
    final slotFilled = _tryFillSlot(userInput);
    if (slotFilled) {
      // 检查是否有风险关键词
      final risk = _checkRisk(userInput);
      if (risk) {
        return "您的情况可能涉及紧急法律问题。建议您立即寻求专业律师的帮助，或拨打法律援助热线。";
      }
    }

    final askIntent = _nextIntent(_slots);
    final maxTurns = (_dsl['max_turns'] as int? ?? 6);

    final done = askIntent == null || _turns >= maxTurns;
    if (!done) {
      // 使用真实AI引擎生成个性化问题 - 执行卡#3+#4
      final ask = await RealAIEngine.generateContextualQuestion(
        intent: askIntent ?? '', 
        slots: _slots, 
        turn: _turns
      );
      return ask.isNotEmpty ? ask : '请补充相关信息';
    }

    // 生成最终建议 - 直接调用Android端真实AI推理
    try {
      return await ChatFlow._callAndroidAI(userInput);
    } catch (e) {
      return '感谢您的咨询。基于您提供的信息，建议您咨询专业律师获取详细的法律意见。';
    }
  }

  static bool _tryFillSlot(String input) {
    final askIntent = _nextIntent(_slots);
    if (askIntent != null) {
      _slots[askIntent] = input;
      return true;
    }
    return false;
  }

  static bool _checkRisk(String input) {
    final riskKeywords = ['家暴', '暴力', '威胁', '伤害', '紧急', '报警'];
    return riskKeywords.any((keyword) => input.contains(keyword));
  }

  static Future<List<String>> _retrieveLawPoints() async {
    try {
      // 简化版本，返回一些通用法律要点
      return [
        '根据相关法律法规规定...',
        '当事人应当依法维护自身合法权益',
        '建议通过合法途径解决争议'
      ];
    } catch (e) {
      return ['相关法律条文'];
    }
  }
}