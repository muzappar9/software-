import 'dart:math' as math;

List<double> embedQueryCheap(String text) {
  // 占位向量: 将字符码取余映射
  final vec = List<double>.filled(128, 0.0);
  for (var i = 0; i < text.length && i < 128; i++) {
    vec[i] = (text.codeUnitAt(i) % 100) / 100.0;
  }
  return vec;
}

double cosineSim(List<double> a, List<double> b) {
  final dot = List.generate(a.length, (i) => a[i] * b[i]).reduce((x, y) => x + y);
  final na = math.sqrt(a.map((v) => v * v).reduce((x, y) => x + y));
  final nb = math.sqrt(b.map((v) => v * v).reduce((x, y) => x + y));
  if (na == 0 || nb == 0) return 0.0;
  return dot / (na * nb);
}

