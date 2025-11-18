import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';

/// 공통 모달 시트 헤더
class ModalSheetHeader extends StatelessWidget {
  const ModalSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ],
    );
  }
}

/// 공통 모달 시트 래퍼
class TabaModalSheet extends StatelessWidget {
  const TabaModalSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.86,
    this.maxChildSize = 0.92,
  });

  final Widget child;
  final double initialChildSize;
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: child,
          ),
        );
      },
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? child,
    WidgetBuilder? builder,
    double initialChildSize = 0.86,
    double maxChildSize = 0.92,
    bool fixedSize = true,
  }) {
    if (child == null && builder == null) {
      throw ArgumentError('Either child or builder must be provided to TabaModalSheet.show');
    }
    
    if (fixedSize) {
      // 내용 크기에 맞게 고정된 시트
      return showModalBottomSheet<T>(
        context: context,
        backgroundColor: AppColors.midnightSoft,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final content = builder != null ? builder(context) : child!;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: IntrinsicHeight(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: content,
                ),
              ),
            ),
          );
        },
      );
    }
    
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TabaModalSheet(
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        child: builder != null ? builder(context) : child!,
      ),
    );
  }
}

