import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';

/// Taba 앱의 공통 버튼 컴포넌트
class TabaButton extends StatelessWidget {
  const TabaButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = TabaButtonVariant.primary,
    this.size = TabaButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final TabaButtonVariant variant;
  final TabaButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    
    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildButton(BuildContext context) {
    final style = _getButtonStyle(context);
    
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    variant == TabaButtonVariant.primary 
                        ? Colors.white 
                        : AppColors.neonPink,
                  ),
                ),
              )
            : Icon(icon, size: 20),
        label: Text(label),
        style: style,
      );
    }
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  variant == TabaButtonVariant.primary 
                      ? Colors.white 
                      : AppColors.neonPink,
                ),
              ),
            )
          : Text(label),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final height = size == TabaButtonSize.large ? 52.0 : 44.0;
    final padding = size == TabaButtonSize.large 
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 14)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    
    switch (variant) {
      case TabaButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonPink,
          foregroundColor: Colors.white,
          padding: padding,
          minimumSize: Size(0, height),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgRadius,
          ),
          elevation: 0,
        );
      case TabaButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.neonPink,
          padding: padding,
          minimumSize: Size(0, height),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgRadius,
            side: const BorderSide(color: AppColors.neonPink, width: 2),
          ),
          elevation: 0,
        );
      case TabaButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: padding,
          minimumSize: Size(0, height),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgRadius,
            side: BorderSide(color: Colors.white.withAlpha(60), width: 1),
          ),
          elevation: 0,
        );
    }
  }
}

enum TabaButtonVariant {
  primary,
  secondary,
  outline,
}

enum TabaButtonSize {
  large,
  medium,
}

