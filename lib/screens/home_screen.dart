import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_theme.dart';

/// 主页面
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // 底部导航栏页面
  final List<Widget> _pages = [
    const HomePage(),
    const ConsultationPage(),
    const SearchPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '咨询',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '检索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

/// 首页内容
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('法律顾问'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageDialog(context, ref);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getWelcomeText(locale),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getSubtitleText(locale),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.gavel,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 功能区域
            Text(
              _getServicesText(locale),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // 功能网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  context,
                  Icons.chat,
                  _getLegalConsultationText(locale),
                  '智能法律问答',
                  AppTheme.primaryColor,
                ),
                _buildFeatureCard(
                  context,
                  Icons.search,
                  _getLawSearchText(locale),
                  '法条检索查询',
                  AppTheme.accentColor,
                ),
                _buildFeatureCard(
                  context,
                  Icons.library_books,
                  _getCaseLibraryText(locale),
                  '案例参考库',
                  AppTheme.successColor,
                ),
                _buildFeatureCard(
                  context,
                  Icons.quiz,
                  '法律知识',
                  '普法教育',
                  AppTheme.warningColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能卡片
  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 功能点击事件
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了$title')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('中文'),
              onTap: () {
                localeNotifier.setLocale(const Locale('zh'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('ئۇيغۇرچە'),
              onTap: () {
                localeNotifier.setLocale(const Locale('ug'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                localeNotifier.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 多语言文本方法
  String _getWelcomeText(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '欢迎使用法律顾问';
      case 'ug':
        return 'قانۇن مەسلىھەتچىسىگە خۇش كەلدىڭىز';
      case 'en':
      default:
        return 'Welcome to Legal Advisor';
    }
  }

  String _getSubtitleText(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '智能法律咨询服务平台';
      case 'ug':
        return 'ئەقلىي قانۇن مەسلىھەت مۇلازىمەت سۇپىسى';
      case 'en':
      default:
        return 'Intelligent Legal Consultation Platform';
    }
  }

  String _getServicesText(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '主要服务';
      case 'ug':
        return 'ئاساسىي مۇلازىمەت';
      case 'en':
      default:
        return 'Main Services';
    }
  }

  String _getLegalConsultationText(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '法律咨询';
      case 'ug':
        return 'قانۇن مەسلىھەتى';
      case 'en':
      default:
        return 'Legal Consultation';
    }
  }

  String _getLawSearchText(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '法律检索';
      case 'ug':
        return 'قانۇن ئىزدەش';
      case 'en':
      default:
        return 'Law Search';
    }
  }

  String _getCaseLibraryText(Locale? locale) {
    switch (locale?.languageCode) {
      case 'zh':
        return '案例库';
      case 'ug':
        return 'ئەھۋال ئامبىرى';
      case 'en':
      default:
        return 'Case Library';
    }
  }
}

/// 咨询页面
class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('法律咨询')),
      body: const Center(
        child: Text('法律咨询功能开发中...'),
      ),
    );
  }
}

/// 检索页面
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('法律检索')),
      body: const Center(
        child: Text('法律检索功能开发中...'),
      ),
    );
  }
}

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('主题模式'),
            subtitle: Text(themeModeNotifier.getThemeModeName(themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              themeModeNotifier.toggleThemeMode();
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 显示语言选择
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于应用'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '法律顾问',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 法律顾问团队',
              );
            },
          ),
        ],
      ),
    );
  }
}