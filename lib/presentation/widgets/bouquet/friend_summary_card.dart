import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';

/// 친구 요약 카드 컴포넌트
class FriendSummaryCard extends StatelessWidget {
  const FriendSummaryCard({
    super.key,
    required this.bouquet,
    required this.unreadCount,
    required this.bouquetName,
    required this.onTap,
  });

  final FriendBouquet bouquet;
  final int unreadCount;
  final String bouquetName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = bouquet.resolveTheme(AppColors.neonPink);

    return TabaCard(
      onTap: onTap,
      variant: TabaCardVariant.gradientCard,
      backgroundColor: color,
      borderRadius: AppRadius.xlRadius,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bouquetName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  bouquet.friend.user.nickname,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bloom ${(bouquet.bloomLevel * 100).round()}% · 신뢰 ${bouquet.trustScore}%',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                unreadCount > 0 ? '$unreadCount' : '0',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                unreadCount > 0 ? '읽지 않은 꽃' : '모든 꽃 읽음',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

