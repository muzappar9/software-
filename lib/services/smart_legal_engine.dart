import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 智能法律引擎 - 快速可用方案
/// 结合规则引擎 + 云端AI，提供真正智能的法律咨询体验
class SmartLegalEngine {
  static final Map<String, List<String>> _conversationHistory = {};
  static final Random _random = Random();

  /// 生成智能法律建议
  static Future<String> generateSmartAdvice({
    required String intent,
    required Map<String, dynamic> userSlots,
    required List<String> lawPoints,
    String userId = 'default',
  }) async {
    try {
      // 更新对话历史
      _updateConversationHistory(userId, intent, userSlots);
      
      // 尝试云端AI (如果可用)
      final cloudResponse = await _tryCloudAI(intent, userSlots, lawPoints);
      if (cloudResponse.isNotEmpty) {
        return cloudResponse;
      }
      
      // 使用智能规则引擎
      return await _generateWithSmartRules(intent, userSlots, lawPoints, userId);
      
    } catch (e) {
      // 保底方案
      return _generateBasicAdvice(intent, userSlots);
    }
  }

  /// 生成智能上下文问题
  static Future<String> generateSmartQuestion({
    required String intent,
    required Map<String, dynamic> slots,
    required int turn,
    String userId = 'default',
  }) async {
    try {
      // 分析对话历史
      final history = _conversationHistory[userId] ?? [];
      
      // 生成上下文相关问题
      final question = _generateContextualQuestion(intent, slots, turn, history);
      
      // 记录问题
      _addToHistory(userId, 'question', question);
      
      return question;
      
    } catch (e) {
      return _getDefaultQuestion(intent, slots);
    }
  }

  /// 智能规则引擎
  static Future<String> _generateWithSmartRules(
    String intent, 
    Map<String, dynamic> slots, 
    List<String> lawPoints,
    String userId
  ) async {
    final advice = StringBuffer();
    final history = _conversationHistory[userId] ?? [];
    
    // 个性化开场
    advice.writeln(_generatePersonalizedGreeting(intent, slots, history));
    advice.writeln();
    
    // 智能案情分析
    advice.writeln('【AI智能分析】');
    advice.writeln(_generateIntelligentAnalysis(intent, slots, history));
    advice.writeln();
    
    // 相关法律依据
    if (lawPoints.isNotEmpty) {
      advice.writeln('【法律依据】');
      final selectedLawPoints = _selectRelevantLawPoints(lawPoints, intent, slots);
      for (int i = 0; i < selectedLawPoints.length; i++) {
        advice.writeln('${i + 1}. ${selectedLawPoints[i]}');
      }
      advice.writeln();
    }
    
    // 专业建议
    advice.writeln('【专业建议】');
    final recommendations = _generateSmartRecommendations(intent, slots, history);
    for (int i = 0; i < recommendations.length; i++) {
      advice.writeln('${i + 1}. ${recommendations[i]}');
    }
    advice.writeln();
    
    // 风险提示
    final risks = _identifySmartRisks(intent, slots);
    if (risks.isNotEmpty) {
      advice.writeln('【风险提示】');
      for (String risk in risks) {
        advice.writeln('⚠️ $risk');
      }
      advice.writeln();
    }
    
    // 后续建议
    advice.writeln('【后续建议】');
    advice.writeln(_generateFollowUpAdvice(intent, slots, history));
    
    return advice.toString();
  }

  /// 云端AI尝试
  static Future<String> _tryCloudAI(
    String intent, 
    Map<String, dynamic> slots, 
    List<String> lawPoints
  ) async {
    try {
      // 构建智能prompt
      final prompt = _buildSmartPrompt(intent, slots, lawPoints);
      
      // 尝试多个API端点
      final apis = [
        'https://api.deepseek.com/v1/chat/completions',
        'https://api.openai.com/v1/chat/completions',
      ];
      
      for (String apiUrl in apis) {
        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer demo-key',
            },
            body: jsonEncode({
              'model': 'deepseek-chat',
              'messages': [
                {
                  'role': 'system',
                  'content': '你是一位专业的中国法律顾问，擅长提供准确、实用的法律建议。'
                },
                {
                  'role': 'user', 
                  'content': prompt
                }
              ],
              'max_tokens': 800,
              'temperature': 0.7
            }),
          ).timeout(Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final content = data['choices'][0]['message']['content'];
            if (content != null && content.toString().trim().isNotEmpty) {
              return content.toString();
            }
          }
        } catch (e) {
          continue; // 尝试下一个API
        }
      }
      
      return ''; // 所有API都失败
      
    } catch (e) {
      return ''; // 返回空字符串，使用规则引擎
    }
  }

  /// 生成个性化问候
  static String _generatePersonalizedGreeting(
    String intent, 
    Map<String, dynamic> slots,
    List<String> history
  ) {
    final isReturningUser = history.length > 2;
    
    if (isReturningUser) {
      final greetings = [
        '很高兴再次为您服务，我注意到您之前咨询过相关问题。',
        '欢迎回来！基于我们之前的交流，让我为您提供更针对性的建议。',
        '感谢您的信任。结合您的情况，我来为您详细分析。'
      ];
      return greetings[_random.nextInt(greetings.length)];
    }
    
    switch (intent) {
      case 'divorce':
        return '我理解您正面临婚姻方面的困扰，这确实是一个需要慎重考虑的重要决定。';
      case 'labor_dispute':
        return '劳动权益是每个人都应该得到保障的，让我帮您分析这个劳动争议案件。';
      case 'traffic_accident':
        return '交通事故确实让人烦恼，不过别担心，我们一步步来处理这个问题。';
      default:
        return '感谢您的信任，我将为您提供专业的法律咨询服务。';
    }
  }

  /// 智能案情分析
  static String _generateIntelligentAnalysis(
    String intent, 
    Map<String, dynamic> slots,
    List<String> history
  ) {
    final analysis = StringBuffer();
    
    // 分析收集到的信息
    final infoCount = slots.length;
    analysis.write('基于您提供的${infoCount}项关键信息，');
    
    switch (intent) {
      case 'divorce':
        analysis.write('您的离婚案件');
        if (slots.containsKey('marriage_years')) {
          final years = slots['marriage_years'];
          analysis.write('涉及${years}年的婚姻关系，');
        }
        if (slots.containsKey('has_children')) {
          analysis.write('需要特别关注子女抚养问题，');
        }
        if (slots.containsKey('joint_assets')) {
          analysis.write('财产分割将是重要考虑因素。');
        } else {
          analysis.write('建议详细梳理夫妻共同财产。');
        }
        break;
        
      case 'labor_dispute':
        analysis.write('您的劳动争议案件');
        if (slots.containsKey('work_years')) {
          analysis.write('涉及${slots['work_years']}的工作经历，');
        }
        if (slots.containsKey('dispute_type')) {
          analysis.write('主要争议点在于${slots['dispute_type']}，');
        }
        analysis.write('需要重点关注证据材料的收集和保全。');
        break;
        
      default:
        analysis.write('案件的复杂程度适中，通过合理的法律途径可以得到妥善解决。');
    }
    
    return analysis.toString();
  }

  /// 生成智能建议
  static List<String> _generateSmartRecommendations(
    String intent, 
    Map<String, dynamic> slots,
    List<String> history
  ) {
    final recommendations = <String>[];
    
    switch (intent) {
      case 'divorce':
        recommendations.addAll([
          '首先尝试协议离婚，这是最快捷、成本最低的方式',
          '详细梳理夫妻共同财产，包括房产、存款、投资等',
          '如涉及子女，优先考虑子女利益，制定合理的抚养方案',
          '保留好相关证据材料，如感情破裂的证据、财产证明等',
          '必要时寻求专业律师帮助，特别是财产较多或争议较大的情况'
        ]);
        break;
        
      case 'labor_dispute':
        recommendations.addAll([
          '收集和整理所有相关证据：劳动合同、工资条、考勤记录等',
          '先尝试与公司人事部门或工会协商解决',
          '协商无果时，及时向劳动监察部门投诉或申请劳动仲裁',
          '注意劳动仲裁的时效限制，一般为一年',
          '准备充分的证据材料，确保维权成功率'
        ]);
        break;
        
      case 'traffic_accident':
        recommendations.addAll([
          '立即报警并联系保险公司，确保事故处理程序正确',
          '拍照取证：现场照片、车辆损伤、人员伤情等',
          '保留好所有相关单据：医疗费、修车费、误工证明等',
          '配合交警部门调查，等待责任认定书',
          '根据责任认定结果，与对方或保险公司协商赔偿事宜'
        ]);
        break;
        
      default:
        recommendations.addAll([
          '详细了解相关法律法规，明确自己的权利和义务',
          '收集和保全相关证据材料',
          '尝试通过协商方式解决争议',
          '必要时寻求专业法律帮助',
          '选择合适的法律途径维护自身权益'
        ]);
    }
    
    return recommendations;
  }

  /// 识别智能风险
  static List<String> _identifySmartRisks(String intent, Map<String, dynamic> slots) {
    final risks = <String>[];
    
    switch (intent) {
      case 'divorce':
        risks.add('协议离婚需要双方都同意，如果一方不配合可能需要诉讼离婚');
        if (!slots.containsKey('evidence')) {
          risks.add('缺乏感情破裂的有力证据可能影响诉讼离婚的成功率');
        }
        risks.add('财产分割过程中要防止对方转移隐匿财产');
        break;
        
      case 'labor_dispute':
        risks.add('劳动仲裁有一年的时效限制，超过时效将失去救济机会');
        risks.add('缺乏书面证据将严重影响仲裁结果');
        risks.add('在争议解决过程中要防止公司进行报复性措施');
        break;
        
      case 'traffic_accident':
        risks.add('交通事故责任认定对后续赔偿影响重大');
        risks.add('伤情鉴定时机很重要，过早或过晚都可能影响结果');
        risks.add('保险理赔有时间限制，要及时申请');
        break;
    }
    
    return risks;
  }

  /// 生成上下文相关问题
  static String _generateContextualQuestion(
    String intent, 
    Map<String, dynamic> slots, 
    int turn,
    List<String> history
  ) {
    // 基于已收集信息生成针对性问题
    final missingInfo = _identifyMissingInformation(intent, slots);
    
    if (missingInfo.isNotEmpty) {
      // 添加上下文和解释
      final question = missingInfo.first;
      final explanation = _getQuestionExplanation(intent, question);
      return '$question\n\n💡 $explanation';
    }
    
    // 深度追问
    return _generateDeepQuestion(intent, slots, turn);
  }

  /// 获取问题解释
  static String _getQuestionExplanation(String intent, String question) {
    if (question.contains('结婚') && question.contains('时间')) {
      return '这个信息有助于确定夫妻共同财产的范围和子女抚养等问题。';
    }
    if (question.contains('工作') && question.contains('时间')) {
      return '工作年限影响经济补偿金的计算和社保权益。';
    }
    if (question.contains('子女')) {
      return '子女的年龄和现状直接影响抚养权和抚养费的确定。';
    }
    return '这个信息对于准确分析您的案件很重要。';
  }

  /// 生成深度问题
  static String _generateDeepQuestion(String intent, Map<String, dynamic> slots, int turn) {
    switch (intent) {
      case 'divorce':
        final deepQuestions = [
          '您是否尝试过婚姻咨询或调解？\n\n💡 法院在审理离婚案件时通常会先进行调解。',
          '对于财产分割，您有什么具体的期望？\n\n💡 了解您的期望有助于制定合理的谈判策略。',
          '如果有子女，您希望争取抚养权吗？\n\n💡 抚养权的争取需要考虑多个因素，包括经济条件、抚养能力等。'
        ];
        return deepQuestions[turn % deepQuestions.length];
        
      case 'labor_dispute':
        final deepQuestions = [
          '公司是否有工会或员工代表？您是否尝试过内部申诉？\n\n💡 内部解决途径有时更快捷有效。',
          '您是否担心维权会影响当前工作或未来就业？\n\n💡 法律保护劳动者的合法维权行为。',
          '除了经济损失，这件事对您造成了哪些其他影响？\n\n💡 精神损害等也可能成为赔偿的一部分。'
        ];
        return deepQuestions[turn % deepQuestions.length];
        
      default:
        return '您对这个问题的解决有什么时间要求吗？\n\n💡 时间因素会影响我们选择的解决策略。';
    }
  }

  /// 识别缺失信息
  static List<String> _identifyMissingInformation(String intent, Map<String, dynamic> slots) {
    final questions = <String>[];
    
    switch (intent) {
      case 'divorce':
        if (!slots.containsKey('marriage_years')) {
          questions.add('您结婚多长时间了？');
        }
        if (!slots.containsKey('has_children')) {
          questions.add('您们有子女吗？如果有，孩子几岁了？');
        }
        if (!slots.containsKey('joint_assets')) {
          questions.add('婚后有哪些主要的共同财产？（如房产、车辆、存款等）');
        }
        if (!slots.containsKey('separation_reason')) {
          questions.add('导致离婚的主要原因是什么？');
        }
        break;
        
      case 'labor_dispute':
        if (!slots.containsKey('work_years')) {
          questions.add('您在该公司工作多长时间了？');
        }
        if (!slots.containsKey('contract_status')) {
          questions.add('您与公司签订了劳动合同吗？合同期限是多久？');
        }
        if (!slots.containsKey('dispute_type')) {
          questions.add('具体是什么类型的劳动争议？（如工资拖欠、违法解除、工伤等）');
        }
        if (!slots.containsKey('evidence')) {
          questions.add('您手头有哪些相关的证据材料？');
        }
        break;
    }
    
    return questions;
  }

  /// 选择相关法条
  static List<String> _selectRelevantLawPoints(
    List<String> lawPoints, 
    String intent, 
    Map<String, dynamic> slots
  ) {
    // 智能筛选最相关的法条
    final relevant = <String>[];
    
    for (String lawPoint in lawPoints) {
      if (_isRelevantLawPoint(lawPoint, intent, slots)) {
        relevant.add(lawPoint);
      }
    }
    
    // 返回最多3条最相关的法条
    return relevant.take(3).toList();
  }

  /// 判断法条相关性
  static bool _isRelevantLawPoint(String lawPoint, String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        return lawPoint.contains('离婚') || 
               lawPoint.contains('夫妻') || 
               lawPoint.contains('财产') ||
               lawPoint.contains('子女');
      case 'labor_dispute':
        return lawPoint.contains('劳动') || 
               lawPoint.contains('工资') || 
               lawPoint.contains('解除');
      default:
        return true;
    }
  }

  /// 生成后续建议
  static String _generateFollowUpAdvice(
    String intent, 
    Map<String, dynamic> slots,
    List<String> history
  ) {
    switch (intent) {
      case 'divorce':
        return '建议您先与对方尝试协商，如果协商不成，可以考虑寻求专业律师的帮助。同时，开始收集相关证据材料。如需进一步咨询，我随时为您服务。';
      case 'labor_dispute':
        return '建议您尽快收集证据材料，并在法定时效内采取行动。如果情况复杂，建议咨询专业劳动法律师。如有新的进展，欢迎随时与我讨论。';
      default:
        return '以上分析仅供参考，具体情况还需要结合更多细节。建议您根据实际情况选择合适的解决方案，必要时寻求专业法律帮助。';
    }
  }

  /// 构建智能prompt
  static String _buildSmartPrompt(
    String intent, 
    Map<String, dynamic> slots, 
    List<String> lawPoints
  ) {
    final prompt = StringBuffer();
    
    prompt.writeln('请作为专业法律顾问，针对以下案件提供专业建议：');
    prompt.writeln();
    prompt.writeln('案件类型：$intent');
    prompt.writeln('用户情况：');
    
    slots.forEach((key, value) {
      prompt.writeln('- $key: $value');
    });
    
    if (lawPoints.isNotEmpty) {
      prompt.writeln();
      prompt.writeln('相关法条：');
      for (String point in lawPoints.take(3)) {
        prompt.writeln('- $point');
      }
    }
    
    prompt.writeln();
    prompt.writeln('请提供：1)案情分析 2)法律依据 3)具体建议 4)风险提示 5)后续步骤');
    prompt.writeln('要求：专业、具体、实用，字数控制在500字以内。');
    
    return prompt.toString();
  }

  /// 更新对话历史
  static void _updateConversationHistory(
    String userId, 
    String intent, 
    Map<String, dynamic> slots
  ) {
    if (!_conversationHistory.containsKey(userId)) {
      _conversationHistory[userId] = [];
    }
    
    final entry = 'intent:$intent,slots:${slots.length}';
    _conversationHistory[userId]!.add(entry);
    
    // 保持历史记录在合理范围内
    if (_conversationHistory[userId]!.length > 10) {
      _conversationHistory[userId]!.removeAt(0);
    }
  }

  /// 添加到历史记录
  static void _addToHistory(String userId, String type, String content) {
    if (!_conversationHistory.containsKey(userId)) {
      _conversationHistory[userId] = [];
    }
    
    _conversationHistory[userId]!.add('$type:${content.substring(0, 50)}...');
    
    if (_conversationHistory[userId]!.length > 10) {
      _conversationHistory[userId]!.removeAt(0);
    }
  }

  /// 获取默认问题
  static String _getDefaultQuestion(String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        return '能详细说说您的具体情况吗？这将帮助我为您提供更准确的建议。';
      case 'labor_dispute':
        return '请描述一下具体发生了什么？越详细越好。';
      default:
        return '请提供更多详细信息，这样我能为您提供更准确的法律建议。';
    }
  }

  /// 生成基础建议
  static String _generateBasicAdvice(String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        return '''【法律建议】
基于您的离婚咨询，建议：
1. 首先尝试协议离婚，这是最快捷的方式
2. 收集夫妻感情破裂的相关证据
3. 梳理夫妻共同财产，准备财产清单
4. 如有子女，考虑子女的最佳利益
5. 必要时寻求专业律师帮助

【温馨提示】
离婚是人生重大决定，建议慎重考虑。如需详细咨询，建议面谈专业律师。''';

      case 'labor_dispute':
        return '''【法律建议】
针对您的劳动争议，建议：
1. 收集劳动合同、工资条等证据材料
2. 先尝试与公司协商解决
3. 协商无果可申请劳动仲裁
4. 注意一年的仲裁时效限制
5. 保护好自己的合法权益

【重要提醒】
劳动仲裁是免费的，不要错过维权机会。建议尽快行动。''';

      default:
        return '''【法律建议】
根据您的咨询，一般建议：
1. 详细了解相关法律法规
2. 收集和保全证据材料
3. 尝试协商解决争议
4. 选择合适的法律途径
5. 必要时寻求专业帮助

【咨询提醒】
具体情况需要结合更多细节分析，建议详细咨询专业律师。''';
    }
  }
}