import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_spacing.dart';

/// 로딩 인디케이터 컴포넌트
class TabaLoadingIndicator extends StatelessWidget {
  const TabaLoadingIndicator({
    super.key,
    this.size = TabaLoadingSize.medium,
    this.message,
  });

  final TabaLoadingSize size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = size == TabaLoadingSize.small ? 24.0 
        : size == TabaLoadingSize.medium ? 32.0 
        : 48.0;
    
    final widget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: widget,
    );
  }
}

enum TabaLoadingSize {
  small,
  medium,
  large,
}

/// 무한 스크롤용 작은 로딩 인디케이터
class TabaInfiniteLoadingIndicator extends StatelessWidget {
  const TabaInfiniteLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

