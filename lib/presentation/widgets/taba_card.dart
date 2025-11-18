import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';

/// Taba 앱의 공통 카드 컴포넌트
class TabaCard extends StatelessWidget {
  const TabaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = TabaCardVariant.defaultCard,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final TabaCardVariant variant;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      decoration: _getDecoration(),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppRadius.xlRadius,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getDecoration() {
    final radius = borderRadius ?? AppRadius.xlRadius;
    
    switch (variant) {
      case TabaCardVariant.defaultCard:
        return BoxDecoration(
          color: backgroundColor ?? AppColors.midnightGlass,
          borderRadius: radius,
          border: Border.all(
            color: borderColor ?? Colors.white.withAlpha(60),
            width: 1,
          ),
        );
      case TabaCardVariant.glassCard:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha(51),
              Colors.white.withAlpha(17),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          border: Border.all(
            color: borderColor ?? Colors.white.withAlpha(60),
            width: 1,
          ),
        );
      case TabaCardVariant.gradientCard:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (backgroundColor ?? AppColors.neonPink).withAlpha(220),
              Colors.white.withAlpha(16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          border: Border.all(
            color: borderColor ?? Colors.white.withAlpha(30),
            width: 1,
          ),
        );
    }
  }
}

enum TabaCardVariant {
  defaultCard,
  glassCard,
  gradientCard,
}

