import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言设置状态提供者
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  /// 从本地存储加载语言设置
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');
      
      if (languageCode != null) {
        state = Locale(languageCode);
      } else {
        // 默认使用系统语言，如果不支持则使用中文
        state = const Locale('zh');
      }
    } catch (e) {
      // 如果出错，使用中文作为默认语言
      state = const Locale('zh');
    }
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      state = locale;
    } catch (e) {
      // 处理错误，但仍然更新状态
      state = locale;
    }
  }

  /// 获取当前语言的显示名称
  String getLanguageName(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '中文';
      case 'ug':
        return 'ئۇيغۇرچە';
      case 'kk':
        return 'Қазақша';
      case 'en':
      default:
        return 'English';
    }
  }

  /// 获取支持的语言列表
  List<Locale> get supportedLocales => const [
    Locale('zh'),
    Locale('ug'),
    Locale('kk'), // 添加哈萨克语支持
  ];
}