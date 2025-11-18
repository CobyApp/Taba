import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

/// 통일된 스낵바 스타일 알림 표시
/// 하단에 고정되어 화면을 밀지 않고 자동으로 사라짐
void showTabaSnackBar(
  BuildContext context, {
  required String message,
  String? title,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: _TabaSnackBarContent(
        message: message,
        title: title,
        icon: icon,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(16),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

/// 성공 메시지용 스낵바
void showTabaSuccess(
  BuildContext context, {
  required String message,
  String? title,
}) {
  final locale = AppLocaleController.localeNotifier.value;
  showTabaSnackBar(
    context,
    message: message,
    title: title ?? AppStrings.successTitle(locale),
    icon: Icons.check_circle,
    backgroundColor: AppColors.neonPink,
  );
}

/// 에러 메시지용 스낵바
void showTabaError(
  BuildContext context, {
  required String message,
  String? title,
}) {
  final locale = AppLocaleController.localeNotifier.value;
  showTabaSnackBar(
    context,
    message: message,
    title: title ?? AppStrings.errorTitle(locale),
    icon: Icons.error_outline,
    backgroundColor: Colors.red.withOpacity(0.9),
  );
}

/// 정보 메시지용 스낵바
void showTabaInfo(
  BuildContext context, {
  required String message,
  String? title,
  IconData? icon,
}) {
  showTabaSnackBar(
    context,
    message: message,
    title: title,
    icon: icon ?? Icons.info_outline,
  );
}

/// 레거시 호환을 위한 함수 (하위 호환성)
@Deprecated('showTabaSnackBar를 사용하세요')
Future<void> showTabaNotice(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.auto_awesome,
}) {
  showTabaSnackBar(
    context,
    message: message,
    title: title,
    icon: icon,
  );
  return Future.value();
}

class _TabaSnackBarContent extends StatelessWidget {
  const _TabaSnackBarContent({
    required this.message,
    this.title,
    this.icon,
  });

  final String message;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0036), Color(0xFF2F0059)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neonPink.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

