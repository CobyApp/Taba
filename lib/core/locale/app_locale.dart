import 'package:flutter/material.dart';

class AppLocaleController {
  AppLocaleController._();
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('ko'));
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
    Locale('ja'),
  ];
}


