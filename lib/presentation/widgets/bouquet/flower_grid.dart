import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/empty_state.dart';

/// 꽃 그리드 컴포넌트
class FlowerGrid extends StatelessWidget {
  const FlowerGrid({
    super.key,
    required this.flowers,
    required this.onFlowerTap,
  });

  final List<SharedFlower> flowers;
  final ValueChanged<SharedFlower> onFlowerTap;

  @override
  Widget build(BuildContext context) {
    if (flowers.isEmpty) {
      return const EmptyState(
        icon: Icons.local_florist_outlined,
        title: '아직 편지가 없습니다',
        subtitle: '친구에게 편지를 보내보세요',
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: flowers
          .map(
            (flower) => _FlowerCard(
              flower: flower,
              onTap: () => onFlowerTap(flower),
            ),
          )
          .toList(),
    );
  }
}

class _FlowerCard extends StatelessWidget {
  const _FlowerCard({
    required this.flower,
    required this.onTap,
  });

  final SharedFlower flower;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: TabaCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.lgRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 꽃 이모지 제거됨
              Text(
                flower.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                flower.preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

