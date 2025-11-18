import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';

/// Taba 앱의 공통 텍스트 입력 필드 컴포넌트
class TabaTextField extends StatelessWidget {
  const TabaTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.neonPink, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.outline.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: AppColors.midnightGlass,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

