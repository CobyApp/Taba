import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/presentation/widgets/badge.dart';

/// 공통 네비게이션 헤더 컴포넌트
class NavHeader extends StatelessWidget {
  const NavHeader({
    super.key,
    this.title,
    this.titleStyle,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.badge,
    this.child,
  });

  final String? title;
  final TextStyle? titleStyle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final int? badge;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: child != null
          ? Row(
              children: [
                if (showBackButton)
                  _BackButton(
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                if (showBackButton) const SizedBox(width: AppSpacing.md),
                Expanded(child: child!),
                if (actions != null) ...actions!,
              ],
            )
          : Row(
              children: [
                if (showBackButton)
                  _BackButton(
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                if (showBackButton && title != null)
                  const SizedBox(width: AppSpacing.md),
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: titleStyle ?? const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
    );
  }
}

/// 세련된 뒤로가기 버튼
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha(40),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// 세련된 헤더 아이콘 버튼
class NavIconButton extends StatelessWidget {
  const NavIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha(40),
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: TabaBadge(
                    count: badge!,
                    size: TabaBadgeSize.small,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: button,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: button,
    );
  }
}

