import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/presentation/widgets/badge.dart';

/// 친구 목록 스트립 컴포넌트
class FriendStoryStrip extends StatelessWidget {
  const FriendStoryStrip({
    super.key,
    required this.bouquets,
    required this.selectedIndex,
    required this.unreadResolver,
    required this.onSelect,
  });

  final List<FriendBouquet> bouquets;
  final int selectedIndex;
  final int Function(FriendBouquet) unreadResolver;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        itemBuilder: (context, index) {
          final bouquet = bouquets[index];
          final selected = index == selectedIndex;
          final unread = unreadResolver(bouquet);
          
          return _FriendAvatarItem(
            bouquet: bouquet,
            selected: selected,
            unread: unread,
            onTap: () => onSelect(index),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
        itemCount: bouquets.length,
      ),
    );
  }
}

class _FriendAvatarItem extends StatelessWidget {
  const _FriendAvatarItem({
    required this.bouquet,
    required this.selected,
    required this.unread,
    required this.onTap,
  });

  final FriendBouquet bouquet;
  final bool selected;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? Colors.white
                          : Colors.white.withAlpha(60),
                      width: selected ? 3 : 1.5,
                    ),
                    boxShadow: [
                      if (selected)
                        BoxShadow(
                          color: bouquet
                              .resolveTheme(AppColors.neonPink)
                              .withAlpha(120),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: UserAvatar(
                    user: bouquet.friend.user,
                    radius: 34,
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: TabaBadge(
                      count: unread,
                      size: TabaBadgeSize.small,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: 80,
              child: Text(
                bouquet.friend.user.nickname,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(selected ? 255 : 200),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

