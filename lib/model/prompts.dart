String draftAsk(String intent, Map<String, dynamic> slotMeta) {
  // 构建简单提示词，让模型生成一个友好的问题
  final ask = slotMeta['ask'] ?? '请补充信息';
  return '请以专业、简洁的方式问用户：$ask';
}

String finalAdvice(String facts, List<Map<String, dynamic>> retrieved) {
  final buffer = StringBuffer();
  buffer.writeln('根据以下事实：');
  buffer.writeln(facts);
  buffer.writeln('\n参考资料：');
  for (var doc in retrieved) {
    buffer.writeln('- ${doc['text']}');
  }
  buffer.writeln('\n请给出150到220字的法律建议，并列出2-3条相关法条要点。');
  return buffer.toString();
}

