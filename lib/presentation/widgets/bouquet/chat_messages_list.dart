import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/presentation/widgets/bouquet/chat_bubble.dart';

/// 채팅 메시지 리스트 컴포넌트
class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({
    super.key,
    required this.flowers,
    required this.readFlowerIds,
    required this.onOpen,
    required this.friendUser,
  });

  final List<SharedFlower> flowers;
  final Set<String> readFlowerIds;
  final ValueChanged<SharedFlower> onOpen;
  final TabaUser friendUser;

  @override
  Widget build(BuildContext context) {
    final separatedCount = flowers.length * 2 - 1;
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) {
            return const SizedBox(height: AppSpacing.md);
          }
          
          final i = index ~/ 2;
          final item = flowers[i];
          final isUnread = !item.sentByMe && !readFlowerIds.contains(item.id);
          
          return ChatBubble(
            contentTitle: item.title,
            contentPreview: item.preview,
            emoji: '🌸', // 기본 꽃 이모지 (꽃 종류 제거됨)
            isMine: item.sentByMe,
            timeLabel: formatTimeAgo(item.sentAt),
            isUnread: isUnread,
            friendUser: friendUser,
            onTap: () => onOpen(item),
          );
        },
        childCount: separatedCount,
      ),
    );
  }
}

