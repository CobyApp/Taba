import 'package:flutter/material.dart';

class TabaUser {
  const TabaUser({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    this.joinedAt,
  });

  final String id;
  final String nickname;
  final String avatarUrl;
  final DateTime? joinedAt;

  String get initials {
    final parts = nickname.trim().split(' ');
    if (parts.length >= 2) {
      return parts.first[0] + parts.last[0];
    }
    return nickname.isNotEmpty ? nickname[0] : '?';
  }

  Color avatarFallbackColor() {
    final hash = id.hashCode;
    const colors = [
      Color(0xFFFF9AC9),
      Color(0xFF82D4F2),
      Color(0xFF7EDCCB),
      Color(0xFFDCC5FF),
    ];
    return colors[hash % colors.length];
  }
}
