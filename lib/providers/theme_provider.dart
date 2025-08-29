import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题模式状态提供者
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// 从本地存储加载主题设置
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
      
      switch (themeModeIndex) {
        case 0:
          state = ThemeMode.system;
          break;
        case 1:
          state = ThemeMode.light;
          break;
        case 2:
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int index = 0;
      
      switch (themeMode) {
        case ThemeMode.system:
          index = 0;
          break;
        case ThemeMode.light:
          index = 1;
          break;
        case ThemeMode.dark:
          index = 2;
          break;
      }
      
      await prefs.setInt('theme_mode', index);
      state = themeMode;
    } catch (e) {
      state = themeMode;
    }
  }

  /// 获取主题模式的显示名称
  String getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  /// 切换到下一个主题模式
  Future<void> toggleThemeMode() async {
    ThemeMode nextMode;
    switch (state) {
      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;
    }
    await setThemeMode(nextMode);
  }
}