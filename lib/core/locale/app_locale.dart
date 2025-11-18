import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class AppLocaleController {
  AppLocaleController._();
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('ko'));
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
    Locale('ja'),
  ];
  
  static const String _localeKey = 'app_locale';
  
  /// 시스템 언어 감지 및 저장된 언어 불러오기
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString(_localeKey);
    
    Locale locale;
    if (savedLocaleCode != null) {
      // 저장된 언어가 있으면 사용
      locale = Locale(savedLocaleCode);
      // 지원되는 언어인지 확인
      if (!supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
        locale = _getSystemLocale();
      }
    } else {
      // 저장된 언어가 없으면 시스템 언어 사용
      locale = _getSystemLocale();
      // 저장
      await prefs.setString(_localeKey, locale.languageCode);
    }
    
    localeNotifier.value = locale;
  }
  
  /// 시스템 언어 감지
  static Locale _getSystemLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final systemLanguageCode = systemLocale.languageCode;
    
    // 시스템 언어가 지원되는 언어인지 확인
    if (supportedLocales.any((l) => l.languageCode == systemLanguageCode)) {
      return Locale(systemLanguageCode);
    }
    
    // 지원되지 않으면 기본값(한국어) 반환
    return const Locale('ko');
  }
  
  /// 언어 변경 및 저장
  static Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    localeNotifier.value = locale;
  }
}


