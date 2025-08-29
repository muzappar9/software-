import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/model_manager_provider.dart';
import 'constants/app_theme.dart';
// import 'generated/l10n.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // copy lawpack db
  // Note: we intentionally don't await heavy IO here; splash screen can await if needed
  runApp(
    const ProviderScope(
      child: LegalAdvisorApp(),
    ),
  );
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
        // S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('zh', ''), // Chinese
        Locale('ug', ''), // Uyghur
      ],
      
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