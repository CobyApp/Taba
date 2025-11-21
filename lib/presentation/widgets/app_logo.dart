import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

/// 앱 로고/타이틀을 표시하는 공통 위젯
/// 스플래시, 로그인, 메인 화면에서 일관된 스타일로 사용
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.fontSize,
    this.letterSpacing,
    this.color,
    this.shadows,
    this.showSubtitle = false,
    this.subtitle,
  });

  /// 로고 폰트 크기 (기본값: 36)
  final double? fontSize;
  
  /// 글자 간격 (기본값: 4)
  final double? letterSpacing;
  
  /// 텍스트 색상 (기본값: Colors.white)
  final Color? color;
  
  /// 그림자 효과
  final List<Shadow>? shadows;
  
  /// 서브 타이틀 표시 여부
  final bool showSubtitle;
  
  /// 서브 타이틀 텍스트 (null이면 기본 서브 타이틀 사용)
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocaleController.localeNotifier.value;
    // 로고 타이틀은 본문 폰트와 다르게 사용 (Press Start 2P - 레트로 스타일)
    final logoStyle = GoogleFonts.pressStart2p().copyWith(
      fontSize: fontSize ?? 36,
      letterSpacing: letterSpacing ?? 4,
      fontWeight: FontWeight.bold,
      color: color ?? Colors.white,
      shadows: shadows ?? [
        Shadow(
          color: Colors.black.withAlpha(100),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        Shadow(
          color: AppColors.neonPink.withAlpha(150),
          blurRadius: 24,
          offset: const Offset(0, 0),
        ),
      ],
    );

    if (showSubtitle) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.appName,
            style: logoStyle,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? AppStrings.letterCommunicationSpace(locale),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: (color ?? Colors.white).withAlpha(200),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
          ),
        ],
      );
    }

    return Text(
      AppStrings.appName,
      style: logoStyle,
    );
  }
}

