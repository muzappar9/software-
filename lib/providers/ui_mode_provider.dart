import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UI模式枚举
enum UIMode {
  simple, // 简洁模式（用户设计）
  modern, // 现代模式（AI设计）
}

/// UI模式状态管理
class UIModeNotifier extends StateNotifier<UIMode> {
  UIModeNotifier() : super(UIMode.simple) {
    _loadUIMode();
  }

  static const String _uiModeKey = 'ui_mode';

  /// 加载保存的UI模式
  Future<void> _loadUIMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_uiModeKey);
      if (modeString != null) {
        state = UIMode.values.firstWhere(
          (mode) => mode.toString() == modeString,
          orElse: () => UIMode.simple,
        );
      }
    } catch (e) {
      // 默认使用简洁模式
      state = UIMode.simple;
    }
  }

  /// 设置UI模式
  Future<void> setUIMode(UIMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_uiModeKey, mode.toString());
      state = mode;
    } catch (e) {
      // 忽略保存错误，只更新状态
      state = mode;
    }
  }

  /// 切换UI模式
  Future<void> toggleUIMode() async {
    final newMode = state == UIMode.simple ? UIMode.modern : UIMode.simple;
    await setUIMode(newMode);
  }

  /// 获取当前模式名称
  String get currentModeName {
    switch (state) {
      case UIMode.simple:
        return '简洁模式';
      case UIMode.modern:
        return '现代模式';
    }
  }

  /// 获取另一个模式的名称
  String get otherModeName {
    switch (state) {
      case UIMode.simple:
        return '现代模式';
      case UIMode.modern:
        return '简洁模式';
    }
  }
}

/// UI模式提供者
final uiModeProvider = StateNotifierProvider<UIModeNotifier, UIMode>((ref) {
  return UIModeNotifier();
});