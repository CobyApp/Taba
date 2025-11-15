import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taba_app/core/theme/app_theme.dart';
import 'package:taba_app/data/mock/mock_data.dart';
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
    _stageTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _stage = AppStage.auth);
    });
    MockDataRepository.instance.seed(); // ensure mock repo warms up
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
        child = const MainShell();
    }

    return MaterialApp(
      title: 'Taba',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: child,
      ),
    );
  }
}
