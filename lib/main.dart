import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/splash_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'constants/app_theme.dart';
import 'model/runner.dart';
import 'model/llama_runner.dart';
import 'rag/lawpack.dart';

void main() async {
  // ✅ 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // ✅ 安全初始化ModelRunner避免崩溃
    await _initializeApp();
    
    runApp(
      const ProviderScope(
        child: LegalAdvisorApp(),
      ),
    );
  } catch (e) {
    print('应用初始化错误: $e');
    // ✅ 即使初始化失败也启动应用，在运行时处理错误
    runApp(
      const ProviderScope(
        child: LegalAdvisorApp(),
      ),
    );
  }
}

/// 安全的应用初始化
Future<void> _initializeApp() async {
  try {
    print('🚀 开始初始化应用组件...');
    
    // 延迟初始化，避免阻塞UI
    Future.delayed(Duration(milliseconds: 100), () async {
      try {
        // 初始化ModelRunner
        final runner = Runner();
        runner.setImpl(LlamaRunner());
        print('✅ ModelRunner初始化完成');
        
        // 预初始化LawPack数据库
        await LawPack.initializeWithAssets();
        print('✅ LawPack数据库初始化完成');
        
      } catch (e) {
        print('⚠️ 后台初始化警告: $e');
        // 静默处理，不影响UI
      }
    });
    
    print('✅ 应用启动成功');
  } catch (e) {
    print('⚠️ 应用初始化警告: $e');
    // 不抛出异常，让应用继续运行
  }
}

class LegalAdvisorApp extends ConsumerWidget {
  const LegalAdvisorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Legal Advisor',
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // 多语言配置
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('zh', ''), // Chinese  
        Locale('ug', ''), // Uyghur
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // 如果是维吾尔语，回退到中文
        if (locale?.languageCode == 'ug') {
          return const Locale('zh', '');
        }
        // 默认处理
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      
      // 路由配置
      routerConfig: _router,
    );
  }
}

// 路由配置
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language-selection',
      name: 'language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);