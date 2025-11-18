import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';

/// 배지 컴포넌트 (알림 개수 등)
class TabaBadge extends StatelessWidget {
  const TabaBadge({
    super.key,
    required this.count,
    this.color = AppColors.neonPink,
    this.size = TabaBadgeSize.medium,
  });

  final int count;
  final Color color;
  final TabaBadgeSize size;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final height = size == TabaBadgeSize.small ? 16.0 : 20.0;
    final horizontalPadding = size == TabaBadgeSize.small ? 6.0 : 8.0;
    final fontSize = size == TabaBadgeSize.small ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum TabaBadgeSize {
  small,
  medium,
}

