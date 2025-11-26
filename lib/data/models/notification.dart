import 'package:flutter/material.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/core/locale/app_strings.dart';

enum NotificationCategory { letter, reaction, friend, system }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    this.isUnread = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final NotificationCategory category;
  final bool isUnread;

  /// 로컬라이즈된 timeAgo (기존 getter는 하위 호환성을 위해 유지)
  String timeAgoLocalized(Locale locale) {
    return AppStrings.timeAgo(locale, time);
  }

  /// 로컬라이즈된 제목 반환 (친구 추가 알림인 경우)
  String localizedTitle(Locale locale) {
    if (category == NotificationCategory.friend) {
      // 친구 추가 알림 패턴 감지
      if (title.contains('친구로 추가되었어요') || 
          title.contains('친구 요청을 수락했어요') ||
          title.contains('친구로 추가')) {
        // 친구 닉네임 추출 시도 (제목에서 "님" 앞의 텍스트)
        final match = RegExp(r'^(.+?)님').firstMatch(title);
        if (match != null) {
          final friendName = match.group(1) ?? '';
          if (title.contains('친구 요청을 수락했어요')) {
            return '${friendName}${AppStrings.friendRequestAcceptedTitle(locale)}';
          } else {
            return '${friendName}${AppStrings.friendAddedTitle(locale)}';
          }
        }
      }
    }
    // 로컬라이즈가 필요 없는 경우 원본 반환
    return title;
  }

  /// 로컬라이즈된 본문 반환 (친구 추가 알림인 경우)
  String localizedSubtitle(Locale locale) {
    if (category == NotificationCategory.friend) {
      // 친구 추가 알림 본문 패턴 감지
      if (subtitle.contains('이제 서로 편지를 주고받을 수 있어요') ||
          subtitle.contains('이제 서로의 편지를 주고받을 수 있어요')) {
        return AppStrings.friendAddedMessage(locale);
      }
    }
    // 로컬라이즈가 필요 없는 경우 원본 반환
    return subtitle;
  }

  /// 기존 timeAgo getter (하위 호환성 유지)
  @Deprecated('Use timeAgoLocalized(Locale) instead')
  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
