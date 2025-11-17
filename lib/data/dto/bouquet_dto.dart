import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/dto/user_dto.dart';
import 'package:taba_app/data/dto/letter_dto.dart';

class BouquetDto {
  final FriendProfileDto friend;
  final List<SharedFlowerDto> sharedFlowers;
  final double bloomLevel;
  final int trustScore;
  final String bouquetName;
  final int unreadCount;

  BouquetDto({
    required this.friend,
    required this.sharedFlowers,
    required this.bloomLevel,
    required this.trustScore,
    required this.bouquetName,
    required this.unreadCount,
  });

  factory BouquetDto.fromJson(Map<String, dynamic> json) {
    return BouquetDto(
      friend: FriendProfileDto.fromJson(json['friend'] as Map<String, dynamic>),
      sharedFlowers: (json['sharedFlowers'] as List<dynamic>?)
              ?.map((item) => SharedFlowerDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      bloomLevel: (json['bloomLevel'] as num?)?.toDouble() ?? 0.0,
      trustScore: json['trustScore'] as int? ?? 0,
      bouquetName: json['bouquetName'] as String,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  FriendBouquet toModel() {
    return FriendBouquet(
      friend: friend.toModel(),
      sharedFlowers: sharedFlowers.map((dto) => dto.toModel()).toList(),
      bloomLevel: bloomLevel,
      trustScore: trustScore,
      bouquetName: bouquetName,
    );
  }
}

class FriendProfileDto {
  final String id;
  final UserDto user;
  final DateTime lastLetterAt;
  final int friendCount;
  final int sentLetters;

  FriendProfileDto({
    required this.id,
    required this.user,
    required this.lastLetterAt,
    required this.friendCount,
    required this.sentLetters,
  });

  factory FriendProfileDto.fromJson(Map<String, dynamic> json) {
    return FriendProfileDto(
      id: json['id'] as String? ?? json['user']['id'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      lastLetterAt: DateTime.parse(json['lastLetterAt'] as String),
      friendCount: json['friendCount'] as int,
      sentLetters: json['sentLetters'] as int,
    );
  }

  FriendProfile toModel() {
    return FriendProfile(
      user: user.toModel(),
      lastLetterAt: lastLetterAt,
      friendCount: friendCount,
      sentLetters: sentLetters,
      inviteCode: '', // API에서 제공되지 않으면 빈 문자열
    );
  }
}

class SharedFlowerDto {
  final String id;
  final LetterDto letter;
  final DateTime sentAt;
  final bool sentByMe;
  final String seedId;
  final double energy;
  final bool isRead;

  SharedFlowerDto({
    required this.id,
    required this.letter,
    required this.sentAt,
    required this.sentByMe,
    required this.seedId,
    this.energy = 0.5,
    this.isRead = true,
  });

  factory SharedFlowerDto.fromJson(Map<String, dynamic> json) {
    return SharedFlowerDto(
      id: json['id'] as String,
      letter: LetterDto.fromJson(json['letter'] as Map<String, dynamic>),
      sentAt: DateTime.parse(json['sentAt'] as String),
      sentByMe: json['sentByMe'] as bool,
      seedId: json['seedId'] as String,
      energy: (json['energy'] as num?)?.toDouble() ?? 0.5,
      isRead: json['isRead'] as bool? ?? true,
    );
  }

  SharedFlower toModel() {
    return SharedFlower(
      id: id,
      letter: letter.toModel(),
      sentAt: sentAt,
      sentByMe: sentByMe,
      seedId: seedId,
      energy: energy,
      isRead: isRead,
    );
  }
}
