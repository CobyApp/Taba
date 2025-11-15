import 'package:flutter/material.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/models/letter.dart';

class SharedFlower {
  const SharedFlower({
    required this.id,
    required this.letter,
    required this.sentAt,
    required this.sentByMe,
    required this.seedId,
    this.energy = 0.5,
    this.isRead = true,
  });

  final String id;
  final Letter letter;
  final DateTime sentAt;
  final bool sentByMe;
  final String seedId;
  final double energy;
  final bool isRead;

  String get directionLabel => sentByMe ? '내가 보냄' : '친구가 보냄';
  FlowerType get flower => letter.flower;
  String get title => letter.title;
  String get preview => letter.preview;
}

class FriendBouquet {
  const FriendBouquet({
    required this.friend,
    required this.sharedFlowers,
    required this.bloomLevel,
    required this.trustScore,
    required this.bouquetName,
    this.themeColor,
  });

  final FriendProfile friend;
  final List<SharedFlower> sharedFlowers;
  final double bloomLevel; // 0.0 ~ 1.0
  final int trustScore; // 0 ~ 100
  final String bouquetName;
  final Color? themeColor;

  int get totalFlowers => sharedFlowers.length;
  int get unreadCount =>
      sharedFlowers.where((f) => !f.isRead && !f.sentByMe).length;

  SharedFlower get latestFlower => sharedFlowers.first;

  Color resolveTheme(Color fallback) => themeColor ?? fallback;
}
