import 'package:flutter/material.dart';
import 'package:taba_app/data/models/user.dart';

enum FlowerType {
  rose('장미', '🌹', 'assets/svg/flower_rose.svg'),
  tulip('튤립', '🌷', 'assets/svg/flower_tulip.svg'),
  sakura('벚꽃', '🌸', 'assets/svg/flower_sakura.svg'),
  sunflower('해바라기', '🌻', null),
  daisy('데이지', '🌼', null),
  lavender('라벤더', '💜', null);

  const FlowerType(this.label, this.emoji, this.asset);

  final String label;
  final String emoji;
  final String? asset;
}

enum VisibilityScope {
  public('전체 공개'),
  friends('친구만'),
  direct('특정인'),
  private('나만 보기');

  const VisibilityScope(this.label);
  final String label;
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
    required this.flower,
    this.isAnonymous = false,
    this.likes = 0,
    this.views = 0,
    this.savedCount = 0,
    this.likeCount,
    this.isLiked,
    this.isSaved,
    this.visibility = VisibilityScope.public,
    this.tags = const [],
    this.template,
    this.attachedImages = const [],
  });

  final String id;
  final String title;
  final String preview;
  final String content;
  final DateTime sentAt;
  final TabaUser sender;
  final FlowerType flower;
  final bool isAnonymous;
  final int likes;
  final int views;
  final int savedCount;
  final int? likeCount; // 현재 좋아요 수
  final bool? isLiked; // 현재 사용자가 좋아요 했는지
  final bool? isSaved; // 현재 사용자가 저장했는지
  final VisibilityScope visibility;
  final List<String> tags;
  final LetterStyle? template;
  final List<String> attachedImages; // 사진 첨부 경로/URL 리스트

  String get senderDisplay => isAnonymous ? '익명' : sender.nickname;

  String timeAgo() {
    final diff = DateTime.now().difference(sentAt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
