import 'package:flutter/material.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

// FlowerType enum 제거됨 - 편지에서 꽃 정보는 더 이상 사용하지 않음

enum VisibilityScope {
  public('전체 공개'),
  friends('친구만'),
  direct('특정인'),
  private('나만 보기');

  const VisibilityScope(this.label);
  final String label;
  
  /// 로컬라이즈된 공개 범위 반환
  String localizedLabel(Locale locale) {
    return AppStrings.visibilityScope(locale, name);
  }
  
  /// 현재 로케일로 공개 범위 반환
  String getLocalizedLabel() {
    return AppStrings.visibilityScope(
      AppLocaleController.localeNotifier.value,
      name,
    );
  }
}

class LetterStyle {
  const LetterStyle({
    required this.background,
    required this.textColor,
    required this.fontFamily,
    required this.fontSize,
  });

  final Color background;
  final Color textColor;
  final String fontFamily;
  final double fontSize;
}

class Letter {
  const Letter({
    required this.id,
    required this.title,
    required this.preview,
    required this.content,
    required this.sentAt,
    required this.sender,
    this.views = 0,
    this.visibility = VisibilityScope.public,
    this.tags = const [],
    this.template,
    this.attachedImages = const [],
    this.isRead,
    this.scheduledAt, // 예약 전송 시간 (null이면 즉시 전송)
  });

  final String id;
  final String title;
  final String preview;
  final String content;
  final DateTime sentAt;
  final TabaUser sender;
  final int views;
  final VisibilityScope visibility;
  final List<String> tags;
  final LetterStyle? template;
  final List<String> attachedImages; // 사진 첨부 경로/URL 리스트
  final bool? isRead; // API에서 받아온 읽음 상태 (true: 읽음, false: 읽지 않음, null: 작성자인 경우 또는 비로그인 사용자)
  final DateTime? scheduledAt; // 예약 전송 시간 (null이면 즉시 전송)

  String get senderDisplay => sender.nickname;
  
  /// 로컬라이즈된 발신자 표시
  String localizedSenderDisplay(Locale locale) {
    return sender.nickname;
  }

  String timeAgo() {
    final diff = DateTime.now().difference(sentAt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
  
  /// 로컬라이즈된 시간 표시
  String localizedTimeAgo(Locale locale) {
    return AppStrings.timeAgo(locale, sentAt);
  }
}
