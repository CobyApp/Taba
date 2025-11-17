import 'package:flutter/material.dart';

/// 일관된 간격 시스템
class AppSpacing {
  const AppSpacing._();

  // 기본 간격
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;

  // 화면 패딩
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: 16);
  
  // 카드 패딩
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(24);
  
  // 섹션 간격
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 12.0;
}

/// 일관된 BorderRadius
class AppRadius {
  const AppRadius._();

  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double xxxl = 32.0;

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxxlRadius = BorderRadius.all(Radius.circular(xxxl));
}

/// 일관된 그림자 스타일
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(120),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadowLarge => [
        BoxShadow(
          color: Colors.black.withAlpha(120),
          blurRadius: 30,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(150),
          blurRadius: 32,
          offset: const Offset(0, 16),
          spreadRadius: 4,
        ),
      ];
}

/// 일관된 카드 스타일
class AppCardStyle {
  const AppCardStyle._();

  static BoxDecoration defaultCard({
    Color? backgroundColor,
    Color? borderColor,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.black.withAlpha(80),
      borderRadius: AppRadius.xlRadius,
      border: Border.all(
        color: borderColor ?? Colors.white.withAlpha(35),
        width: 1,
      ),
      boxShadow: boxShadow ?? AppShadows.cardShadow,
    );
  }

  static BoxDecoration glassCard({
    Color? borderColor,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: AppRadius.xxlRadius,
      border: Border.all(
        color: borderColor ?? Colors.white.withAlpha(60),
        width: 1,
      ),
      boxShadow: boxShadow ?? AppShadows.cardShadow,
    );
  }
}

