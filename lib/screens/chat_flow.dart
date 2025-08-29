import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../rag/lawpack.dart';
import '../rag/hints.dart';
import '../model/runner.dart';

class ChatFlow {
  // entry point called from UI
  static Future<String> onUserTurn(BuildContext context, String userText, WidgetRef ref) async {
    final topic = await routeTopic(userText);
    // load slots yaml for topic
    final slots = await _loadSlotsForTopic(topic);
    final filled = <String, String>{};

    // run up to 6 rounds
    for (int round = 0; round < 6; round++) {
      // check risk words
      if (_containsRiskWords(userText)) {
        break;
      }

      final remaining = slots.where((s) => !filled.containsKey(s)).toList();
      if (remaining.isEmpty) break;

      // ask next slot (simplified: prompt userText contains answer)
      final slot = remaining.first;
      // in this mock integration we try to extract from userText itself
      if (userText.contains('：') || userText.contains(':')) {
        // naive parse
        final parts = userText.split(RegExp(r'：|:'));
        if (parts.length >= 2) {
          filled[slot] = parts.sublist(1).join(':').trim();
        }
      }

      // break if no more info
      if (filled.length >= slots.length) break;
      // In this simplified flow we stop after one pass
      break;
    }

    final lawpoints = await retrieveLawpack(topic, filled);
    final advice = await generateAdvice(topic, filled, lawpoints);
    final bullets = lawpoints.map((s) => '- $s').join('\n');

    return '$advice\n\n要点：\n$bullets';
  }

  static Future<String> routeTopic(String text) async {
    final t = text.toLowerCase();
    if (t.contains('离婚') || t.contains('divorce')) return 'divorce';
    if (t.contains('工资') || t.contains('拖欠') || t.contains('薪')) return 'labor';
    if (t.contains('合同')) return 'contract';
    if (t.contains('欠款') || t.contains('债')) return 'debt';
    if (t.contains('交通') || t.contains('违章')) return 'traffic';
    if (t.contains('租') || t.contains('房屋') || t.contains('tenancy')) return 'tenancy';
    // fallback
    return 'generic';
  }

  static bool _containsRiskWords(String text) {
    final risk = ['家暴', '未成年', '暴力', '诈骗', '高额'];
    return risk.any((r) => text.contains(r));
  }

  static Future<List<String>> _loadSlotsForTopic(String topic) async {
    try {
      final yamlStr = await rootBundle.loadString('assets/slots/${topic}_zh.yaml');
      final doc = loadYaml(yamlStr);
      if (doc is Map && doc['slots'] is List) {
        return List<String>.from(doc['slots']);
      }
    } catch (_) {}
    return <String>[];
  }

  static Future<List<String>> retrieveLawpack(String topic, Map<String, String> filled) async {
    // use rag/lawpack
    final lp = Lawpack();
    final res = await lp.searchTopK(topic, 5);
    if (res.isEmpty) {
      return Hints.getHints(topic);
    }
    return res;
  }

  static Future<String> generateAdvice(String topic, Map<String, String> filled, List<String> lawpoints) async {
    final mock = Runner.mockGenerate(topic, filled, lawpoints);
    return mock;
  }
}

import 'dart:convert';
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

class _ChatFlow {
  static final _runner = LlamaRunner();
  static Map<String, dynamic> _slots = {};
  static late Map<String, dynamic> _dsl;
  static late LawPack _rag;
  static int _turns = 0;

  static Future<void> initChatLogic() async {
    final yaml = await rootBundle.loadString('assets/slots/divorce_zh.yaml');
    _dsl = json.decode(json.encode(loadYaml(yaml)));
    final dbFile = await LawPackInit.copyDbFromAssetsIfNeeded();
    _rag = await LawPack.open(dbFile);
    await _runner.init(modelPath: "app://models/gemma-270m-int4.gguf", nCtx: 512, nThreads: 4);
    _slots.clear();
    _turns = 0;
  }

  /// Route first utterance to topic intent using simple gazetteer/regex
  static String routeTopic(String text) {
    final t = text.toLowerCase();
    if (t.contains('离婚')) return 'divorce';
    if (t.contains('工资') || t.contains('拖欠')) return 'labor_dispute';
    if (t.contains('合同') || t.contains('违约')) return 'contract_dispute';
    if (t.contains('借款') || t.contains('欠款')) return 'debt_dispute';
    if (t.contains('车祸') || t.contains('交通')) return 'traffic_accident';
    if (t.contains('房东') || t.contains('押金') || t.contains('租')) return 'tenancy_dispute';
    if (t.contains('买房') || t.contains('烂尾') || t.contains('开发商')) return 'property_sale';
    if (t.contains('物业') || t.contains('小区')) return 'property_service';
    if (t.contains('邻居') || t.contains('噪音')) return 'neighbor_dispute';
    if (t.contains('诽谤') || t.contains('名誉')) return 'tort_personality';
    if (t.contains('知识产权') || t.contains('专利') || t.contains('商标')) return 'ip_basic';
    if (t.contains('退款') || t.contains('网购')) return 'ecommerce_dispute';
    if (t.contains('医疗') || t.contains('手术')) return 'medical_dispute';
    if (t.contains('学校') || t.contains('校园')) return 'education_dispute';
    if (t.contains('隐私') || t.contains('个人信息')) return 'data_privacy';
    // default
    return 'generic_case';
  }

  static bool _hitRisk(String text) {
    final List risks = (_dsl['risk_triggers'] as List?) ?? [];
    return risks.any((k) => text.contains(k.toString()));
  }

  static String? _nextIntent(Map<String, dynamic> s) {
    final order = (_dsl['slots'] as Map).keys.toList();
    for (final k in order) {
      if (!s.containsKey(k)) {
        final cfg = _dsl['slots'][k];
        return cfg['ask'] as String;
      }
    }
    return null;
  }

  static void _fillSlotsFromUser(String userText) {
    if (!_slots.containsKey('marriage_years')) {
      final m = RegExp(r'(?:结婚|婚后)(\d{1,2})年').firstMatch(userText);
      if (m != null) _slots['marriage_years'] = int.parse(m.group(1)!);
    }
    if (!_slots.containsKey('has_children')) {
      if (RegExp(r'孩子|儿子|女儿|未成年|小孩').hasMatch(userText)) {
        _slots['has_children'] = true;
      }
    }
    if (!_slots.containsKey('joint_assets')) {
      if (RegExp(r'房|车|存款|按揭|贷款').hasMatch(userText)) {
        _slots['joint_assets'] = "可能有房/车/存款/贷款";
      }
    }
    if (!_slots.containsKey('reason')) {
      for (final r in ["性格不合", "分居", "家暴", "出轨", "其他"]) {
        if (userText.contains(r)) {
          _slots['reason'] = r;
          break;
        }
      }
    }
  }

  static Future<String> onUserTurn(String userText, BuildContext context, WidgetRef ref) async {
    _fillSlotsFromUser(userText);
    _turns += 1;

    final risk = _hitRisk(userText);
    final askIntent = _nextIntent(_slots);
    final maxTurns = (_dsl['max_turns'] as int? ?? 6);

    final done = risk || askIntent == null || _turns >= maxTurns;
    if (!done) {
      final ask = await _runner.generate(prompt: draftAsk(askIntent ?? ''), maxTokens: 48, temperature: 0.6, topP: 0.9, stop: ["\n"]);
      return ask.isNotEmpty ? ask : (askIntent ?? '请补充信息');
    }

    final facts = "离婚 婚龄:${_slots['marriage_years'] ?? '?'} 子女:${_slots['has_children'] ?? '?'} 财产:${_slots['joint_assets'] ?? '?'} 原因:${_slots['reason'] ?? '?'}";
    final docs = await _rag.retrieve("离婚 ${_slots['reason'] ?? ''} ${_slots['joint_assets'] ?? ''}");
    final bullets = docs.map((e) => e['text'] as String).take(4).toList();

    final advice = await _runner.generate(prompt: finalAdvice(facts, bullets), maxTokens: 220, temperature: 0.6, topP: 0.9);

    if (advice.trim().isNotEmpty) return advice.trim();

    final bt = (bullets.isNotEmpty ? "【法条要点】${bullets.take(3).join('；')}\n" : "");
    return "【基本判断】结合你提供的婚姻年限、子女与共同财产情况，离婚程序通常先行调解，抚养与财产会一并处理。\n"+
           "【建议】1) 保留分居/共同生活证据；2) 准备子女主要照料证据；3) 整理房产与还贷流水；4) 协商不成可起诉离婚并主张分割。\n"+
           "${bt}【提示】以上为一般信息，非正式法律意见。";
  }
}

