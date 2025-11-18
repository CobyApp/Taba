import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/core/theme/app_theme.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/screens/auth/login_screen.dart';
import 'package:taba_app/presentation/screens/main/main_shell.dart';
import 'package:taba_app/presentation/screens/splash/splash_screen.dart';
import 'package:taba_app/presentation/screens/tutorial/tutorial_screen.dart';

enum AppStage { splash, auth, tutorial, main }

class TabaApp extends StatefulWidget {
  const TabaApp({super.key});

  @override
  State<TabaApp> createState() => _TabaAppState();
}

class _TabaAppState extends State<TabaApp> {
  AppStage _stage = AppStage.splash;
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // 앱 언어 초기화 (시스템 언어 감지 및 저장)
    await AppLocaleController.initialize();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _stageTimer = Timer(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      
      final isAuthenticated =
          await DataRepository.instance.isAuthenticated();
      
      if (mounted) {
        setState(() {
          _stage = isAuthenticated ? AppStage.main : AppStage.auth;
        });
      }
    });
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _stage = AppStage.tutorial);
  }

  void _completeTutorial() {
    setState(() => _stage = AppStage.main);
  }

  void _handleLogout() {
    setState(() => _stage = AppStage.auth);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_stage) {
      case AppStage.splash:
        child = const SplashScreen();
      case AppStage.auth:
        child = LoginScreen(onSuccess: _handleLogin);
      case AppStage.tutorial:
        child = TutorialScreen(
          onFinish: _completeTutorial,
          onSkip: _completeTutorial,
        );
      case AppStage.main:
        child = MainShell(onLogout: _handleLogout);
    }

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
    return MaterialApp(
      title: 'Taba',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(locale),
          locale: locale,
          supportedLocales: AppLocaleController.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: child,
      ),
        );
      },
    );
  }
}
