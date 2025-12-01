import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

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
    final bubbleMaxWidth = screenWidth * 0.92; // 말풍선을 더 넓게

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
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Expanded(child: bubble),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: isMine ? 0 : 0, // 친구 프로필사진 제거로 인해 패딩 제거
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
/// 예약전송 편지의 경우 scheduledAt을 사용하여 "언제 발송 예정인지" 표시
String formatTimeAgo(DateTime time, {DateTime? scheduledAt}) {
  final locale = AppLocaleController.localeNotifier.value;
  
  // 예약전송 편지인 경우 scheduledAt 사용
  if (scheduledAt != null) {
    final now = DateTime.now();
    // 아직 발송되지 않은 경우 (scheduledAt이 미래인 경우)
    if (scheduledAt.isAfter(now)) {
      return _formatScheduledTime(locale, scheduledAt);
    }
  }
  
  // 일반 편지 또는 이미 발송된 예약전송 편지
  final diff = DateTime.now().difference(time);
  if (diff.isNegative) {
    // 마이너스 시간 방지: 미래 시간인 경우 "곧" 표시
    return AppStrings.timeAgo(locale, time);
  }
  return AppStrings.timeAgo(locale, time);
}

/// 예약전송 시간 포맷팅 (로컬라이즈)
String _formatScheduledTime(Locale locale, DateTime scheduledAt) {
  final now = DateTime.now();
  final diff = scheduledAt.difference(now);
  
  String timeStr;
  if (diff.inDays > 0) {
    timeStr = '${diff.inDays}일';
  } else if (diff.inHours > 0) {
    timeStr = '${diff.inHours}시간';
  } else if (diff.inMinutes > 0) {
    timeStr = '${diff.inMinutes}분';
  } else {
    timeStr = '곧';
  }
  
  switch (locale.languageCode) {
    case 'en':
      if (diff.inDays > 0) {
        return 'Scheduled in $timeStr';
      } else if (diff.inHours > 0) {
        return 'Scheduled in $timeStr';
      } else if (diff.inMinutes > 0) {
        return 'Scheduled in $timeStr';
      } else {
        return 'Scheduled soon';
      }
    case 'ja':
      if (diff.inDays > 0) {
        return '$timeStr後に送信予定';
      } else if (diff.inHours > 0) {
        return '$timeStr後に送信予定';
      } else if (diff.inMinutes > 0) {
        return '$timeStr後に送信予定';
      } else {
        return 'まもなく送信予定';
      }
    default:
      if (diff.inDays > 0) {
        return '$timeStr 후 발송 예정';
      } else if (diff.inHours > 0) {
        return '$timeStr 후 발송 예정';
      } else if (diff.inMinutes > 0) {
        return '$timeStr 후 발송 예정';
      } else {
        return '곧 발송 예정';
      }
  }
}

