import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../constants/app_theme.dart';

/// 语言选择器组件（右上角椭圆形）
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    
    return PopupMenuButton<Locale>(
      onSelected: (Locale selectedLocale) {
        localeNotifier.setLocale(selectedLocale);
      },
      itemBuilder: (BuildContext context) => [
        _buildLanguageMenuItem(
          const Locale('zh'),
          '中文',
          Icons.translate,
          locale?.languageCode == 'zh',
        ),
        _buildLanguageMenuItem(
          const Locale('ug'),
          'ئۇيغۇرچە',
          Icons.language_outlined,
          locale?.languageCode == 'ug',
        ),
        _buildLanguageMenuItem(
          const Locale('kk'),
          'Қазақша',
          Icons.language,
          locale?.languageCode == 'kk',
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              _getLanguageDisplayName(locale),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建语言菜单项
  PopupMenuItem<Locale> _buildLanguageMenuItem(
    Locale locale,
    String displayName,
    IconData icon,
    bool isSelected,
  ) {
    return PopupMenuItem<Locale>(
      value: locale,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check,
              size: 16,
              color: AppTheme.primaryColor,
            ),
        ],
      ),
    );
  }

  /// 获取语言显示名称
  String _getLanguageDisplayName(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '中文';
      case 'ug':
        return 'ئۇيغۇر';
      case 'kk':
        return 'Қазақ';
      default:
        return '中文';
    }
  }
}