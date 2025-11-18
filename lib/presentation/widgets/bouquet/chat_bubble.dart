import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';

/// 채팅 버블 컴포넌트
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.contentTitle,
    required this.contentPreview,
    required this.emoji,
    required this.isMine,
    required this.timeLabel,
    required this.isUnread,
    required this.friendUser,
    required this.onTap,
  });

  final String contentTitle;
  final String contentPreview;
  final String emoji;
  final bool isMine;
  final String timeLabel;
  final bool isUnread;
  final TabaUser friendUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine 
        ? AppColors.neonBlue.withAlpha(40) 
        : AppColors.midnightGlass;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.lg),
      topRight: const Radius.circular(AppRadius.lg),
      bottomLeft: Radius.circular(isMine ? AppRadius.lg : 4),
      bottomRight: Radius.circular(isMine ? 4 : AppRadius.lg),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * 0.98;

    final bubble = InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
          border: Border.all(
            color: isUnread 
                ? AppColors.neonPink.withAlpha(120) 
                : Colors.white24,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      contentTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.neonPink,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                contentPreview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) ...[
                UserAvatar(
                  user: friendUser,
                  radius: 14,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(child: bubble),
                const Spacer(),
              ] else ...[
                const Spacer(),
                Flexible(child: bubble),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: isMine ? 0 : 36,
                right: isMine ? 0 : 0,
              ),
              child: Text(
                timeLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 시간 표시 헬퍼 함수
String formatTimeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}

