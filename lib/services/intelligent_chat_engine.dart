// import 'dart:convert'; // 未使用
// import 'dart:math'; // 未使用

/// 智能聊天引擎 - 实现真实的法律AI对话
class IntelligentChatEngine {
  static final IntelligentChatEngine _instance = IntelligentChatEngine._internal();
  factory IntelligentChatEngine() => _instance;
  IntelligentChatEngine._internal();

  /// 根据案由和已收集信息生成智能问题
  String generateContextualQuestion(String intent, Map<String, dynamic> slots, int turn) {
    final questions = _getQuestionsByIntent(intent);
    final askedQuestions = slots.keys.toSet();
    
    // 找到尚未询问的问题
    final remainingQuestions = questions.where((q) => !askedQuestions.contains(q['slot'])).toList();
    
    if (remainingQuestions.isEmpty) {
      return _generateFollowUpQuestion(intent, slots);
    }
    
    // 智能选择下一个问题
    final nextQuestion = _selectBestQuestion(remainingQuestions, slots);
    return nextQuestion['question'] as String;
  }

  /// 生成智能法律建议
  String generateIntelligentAdvice(String intent, Map<String, dynamic> slots, List<String> lawpoints) {
    final advice = StringBuffer();
    
    // 个性化开场
    advice.writeln(_generatePersonalizedOpening(intent, slots));
    advice.writeln();
    
    // 具体情况分析
    advice.writeln('【情况分析】');
    advice.writeln(_analyzeSpecificSituation(intent, slots));
    advice.writeln();
    
    // 法律依据
    if (lawpoints.isNotEmpty) {
      advice.writeln('【法律依据】');
      for (int i = 0; i < lawpoints.length && i < 3; i++) {
        advice.writeln('${i + 1}. ${lawpoints[i]}');
      }
      advice.writeln();
    }
    
    // 操作建议
    advice.writeln('【建议步骤】');
    final steps = _generateActionSteps(intent, slots);
    for (int i = 0; i < steps.length; i++) {
      advice.writeln('${i + 1}. ${steps[i]}');
    }
    advice.writeln();
    
    // 风险提示
    final risks = _identifyRisks(intent, slots);
    if (risks.isNotEmpty) {
      advice.writeln('【风险提示】');
      for (String risk in risks) {
        advice.writeln('⚠️ $risk');
      }
      advice.writeln();
    }
    
    // 专业建议
    advice.writeln('【专业提醒】');
    advice.writeln(_getFinalReminder(intent));
    
    return advice.toString();
  }

  /// 根据案由获取问题列表
  List<Map<String, String>> _getQuestionsByIntent(String intent) {
    switch (intent) {
      case 'divorce':
        return [
          {'slot': 'marriage_years', 'question': '您结婚多少年了？这关系到财产分割和子女抚养权的判定。'},
          {'slot': 'has_children', 'question': '您们有未成年子女吗？有几个孩子？年龄分别是多少？'},
          {'slot': 'joint_assets', 'question': '婚后主要共同财产有哪些？（如房产、车辆、存款、投资等）'},
          {'slot': 'separation_time', 'question': '您们分居多长时间了？是否有分居协议？'},
          {'slot': 'divorce_reason', 'question': '离婚的主要原因是什么？（感情不和、出轨、家暴、性格不合等）'},
          {'slot': 'fault_evidence', 'question': '如果对方有过错，您是否保留了相关证据？'},
        ];
      case 'labor_dispute':
        return [
          {'slot': 'work_years', 'question': '您在该公司工作了多长时间？'},
          {'slot': 'contract_status', 'question': '是否签订了劳动合同？合同期限是多长？'},
          {'slot': 'dispute_type', 'question': '具体争议是什么？（工资拖欠、违法解除、加班费、社保等）'},
          {'slot': 'salary_amount', 'question': '您的月工资是多少？是否有加班费、奖金等其他收入？'},
          {'slot': 'evidence_materials', 'question': '您有哪些证据材料？（工资条、工作记录、聊天记录等）'},
        ];
      case 'traffic_accident':
        return [
          {'slot': 'accident_time', 'question': '事故发生的具体时间是什么时候？'},
          {'slot': 'responsibility', 'question': '交警是否已出具责任认定书？责任划分是怎样的？'},
          {'slot': 'injury_level', 'question': '人员伤亡情况如何？是否需要住院治疗？'},
          {'slot': 'vehicle_damage', 'question': '车辆损坏程度如何？维修费用大概多少？'},
          {'slot': 'insurance_status', 'question': '双方车辆保险情况如何？保险公司是否已介入？'},
        ];
      default:
        return [
          {'slot': 'basic_situation', 'question': '请详细描述一下您遇到的具体情况？'},
          {'slot': 'key_concerns', 'question': '您最关心的问题是什么？希望达到什么目标？'},
          {'slot': 'evidence_status', 'question': '您目前有哪些相关的证据材料？'},
        ];
    }
  }

  /// 智能选择最佳问题
  Map<String, String> _selectBestQuestion(List<Map<String, String>> questions, Map<String, dynamic> slots) {
    // 根据已有信息的重要性选择下一个问题
    if (slots.isEmpty) {
      return questions.first; // 第一个问题
    }
    
    // 基于优先级选择
    final priorities = ['marriage_years', 'contract_status', 'accident_time', 'basic_situation'];
    for (String priority in priorities) {
      final question = questions.where((q) => q['slot'] == priority).firstOrNull;
      if (question != null) return question;
    }
    
    return questions.first;
  }

  /// 生成跟进问题
  String _generateFollowUpQuestion(String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        if (slots.containsKey('has_children') && slots['has_children'] == true) {
          return '关于子女抚养，您希望孩子跟谁生活？您的经济条件和照顾能力如何？';
        }
        return '您希望通过调解解决还是直接起诉离婚？是否愿意给对方一次挽回的机会？';
      case 'labor_dispute':
        return '您是否已经向劳动监察部门投诉或申请劳动仲裁？';
      default:
        return '还有其他重要细节需要补充吗？';
    }
  }

  /// 生成个性化开场
  String _generatePersonalizedOpening(String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        final years = slots['marriage_years'] ?? '未知';
        final children = slots['has_children'] == true ? '有子女' : '无子女';
        return '根据您提供的信息，您是一个结婚${years}年、${children}的离婚案例。';
      case 'labor_dispute':
        final type = slots['dispute_type'] ?? '劳动争议';
        return '您遇到的${type}问题在职场中较为常见，以下是针对性的分析和建议。';
      default:
        return '根据您的具体情况，我为您提供以下法律分析和建议。';
    }
  }

  /// 分析具体情况
  String _analyzeSpecificSituation(String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        final analysis = StringBuffer();
        if (slots['marriage_years'] != null) {
          final years = int.tryParse(slots['marriage_years'].toString()) ?? 0;
          if (years > 2) {
            analysis.write('结婚超过2年，财产关系较为复杂，需要详细清理共同财产。');
          }
        }
        if (slots['has_children'] == true) {
          analysis.write('有未成年子女的情况下，需要重点考虑子女利益最大化原则。');
        }
        return analysis.toString().isNotEmpty ? analysis.toString() : '基于目前信息，建议优先考虑调解方案。';
      
      case 'labor_dispute':
        if (slots['contract_status'] == false) {
          return '未签订劳动合同的情况下，可以要求双倍工资赔偿，但需要证明劳动关系的存在。';
        }
        return '有劳动合同的情况下，争议解决相对明确，关键在于证据收集和程序选择。';
      
      default:
        return '需要根据具体的法律关系和争议焦点进行深入分析。';
    }
  }

  /// 生成操作步骤
  List<String> _generateActionSteps(String intent, Map<String, dynamic> slots) {
    switch (intent) {
      case 'divorce':
        return [
          '收集和整理婚姻关系证明、财产证明、子女出生证明等材料',
          '尝试与对方协商，如果协商一致可以办理协议离婚',
          '协商不成的，准备起诉材料到法院提起离婚诉讼',
          '如涉及家暴等严重情况，及时申请人身保护令',
          '委托专业律师代理，确保合法权益得到保障'
        ];
      case 'labor_dispute':
        return [
          '整理劳动合同、工资条、考勤记录等证据材料',
          '先向公司人事部门或工会反映，寻求内部解决',
          '向劳动监察部门投诉或申请劳动仲裁',
          '仲裁不服的，可以向法院提起诉讼',
          '必要时咨询专业劳动法律师获取指导'
        ];
      case 'traffic_accident':
        return [
          '立即报警并联系保险公司，保护现场证据',
          '及时就医并保留所有医疗费用发票',
          '收集事故责任认定书、维修发票等材料',
          '与对方或保险公司协商赔偿方案',
          '协商不成的，准备材料提起民事诉讼'
        ];
      default:
        return [
          '详细收集和整理相关证据材料',
          '咨询专业律师获取法律意见',
          '选择合适的争议解决途径',
          '按照法律程序维护自身权益'
        ];
    }
  }

  /// 识别风险点
  List<String> _identifyRisks(String intent, Map<String, dynamic> slots) {
    final risks = <String>[];
    
    switch (intent) {
      case 'divorce':
        if (slots['fault_evidence'] == false) {
          risks.add('缺乏对方过错证据可能影响财产分割和子女抚养权争取');
        }
        if (slots['joint_assets'] != null && slots['joint_assets'].toString().contains('房产')) {
          risks.add('房产分割涉及复杂的评估和过户手续，建议提前准备');
        }
        break;
      case 'labor_dispute':
        if (slots['evidence_materials'] == null) {
          risks.add('缺乏证据材料将严重影响仲裁和诉讼结果');
        }
        risks.add('劳动仲裁有一年时效限制，请注意及时申请');
        break;
      case 'traffic_accident':
        if (slots['insurance_status'] == null) {
          risks.add('保险情况不明可能影响赔偿金额和方式');
        }
        break;
    }
    
    return risks;
  }

  /// 获取最终提醒
  String _getFinalReminder(String intent) {
    switch (intent) {
      case 'divorce':
        return '离婚涉及感情和财产双重考量，建议在做出最终决定前慎重考虑，必要时寻求心理咨询师和专业律师的帮助。';
      case 'labor_dispute':
        return '劳动争议案件时效性强，建议及时采取行动。如涉及金额较大或情况复杂，建议委托专业劳动法律师代理。';
      case 'traffic_accident':
        return '交通事故处理时限较紧，建议及时处理。重大事故或人员伤亡案件建议委托专业律师处理保险理赔和民事赔偿。';
      default:
        return '以上建议仅供参考，具体情况建议咨询专业律师获取详细的法律意见。';
    }
  }
}