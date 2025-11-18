import 'package:flutter/material.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/models/letter.dart';

/// 친구와 주고받은 편지 정보
/// API: GET /friends/{friendId}/letters 응답 구조
class SharedFlower {
  const SharedFlower({
    required this.id,
    required this.letter,
    required this.sentAt,
    required this.sentByMe,
    this.isRead,
  });

  final String id; // 편지 ID (Letter 테이블의 ID)
  final Letter letter; // 편지 정보
  final DateTime sentAt; // 전송 시간
  final bool sentByMe; // 현재 사용자가 보낸 편지인지 여부
  final bool? isRead; // 내가 받은 편지인 경우 읽음 상태 (내가 보낸 편지는 null)

  String get directionLabel => sentByMe ? '내가 보냄' : '친구가 보냄';
  // flower 필드 제거됨
  String get title => letter.title;
  String get preview => letter.preview;
}

class FriendBouquet {
  const FriendBouquet({
    required this.friend,
    required this.bloomLevel,
    required this.trustScore,
    required this.bouquetName,
    required this.unreadCount,
    this.themeColor,
  });

  final FriendProfile friend;
  final double bloomLevel; // 0.0 ~ 1.0
  final int trustScore; // 0 ~ 100
  final String bouquetName;
  final int unreadCount; // 읽지 않은 편지 수
  final Color? themeColor;

  Color resolveTheme(Color fallback) => themeColor ?? fallback;
}
