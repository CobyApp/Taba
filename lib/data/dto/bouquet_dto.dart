import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/dto/user_dto.dart';
import 'package:taba_app/data/dto/letter_dto.dart';

class BouquetDto {
  final FriendProfileDto friend;
  final double bloomLevel;
  final int trustScore;
  final String? bouquetName;
  final int unreadCount;

  BouquetDto({
    required this.friend,
    required this.bloomLevel,
    required this.trustScore,
    this.bouquetName,
    required this.unreadCount,
  });

  factory BouquetDto.fromJson(Map<String, dynamic> json) {
    return BouquetDto(
      friend: FriendProfileDto.fromJson(json['friend'] as Map<String, dynamic>),
      bloomLevel: (json['bloomLevel'] as num?)?.toDouble() ?? 0.0,
      trustScore: json['trustScore'] as int? ?? 0,
      bouquetName: json['bouquetName'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  FriendBouquet toModel() {
    return FriendBouquet(
      friend: friend.toModel(),
      bloomLevel: bloomLevel,
      trustScore: trustScore,
      bouquetName: bouquetName ?? '', // null인 경우 빈 문자열로 처리
      unreadCount: unreadCount,
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
    // friend 객체가 직접 user 정보를 포함할 수도 있고, user 객체를 포함할 수도 있음
    Map<String, dynamic> userJson;
    if (json.containsKey('user')) {
      userJson = json['user'] as Map<String, dynamic>;
    } else {
      // friend 객체 자체가 user 정보를 포함하는 경우
      userJson = json;
    }
    
    return FriendProfileDto(
      id: json['id'] as String? ?? userJson['id'] as String? ?? '',
      user: UserDto.fromJson(userJson),
      lastLetterAt: json['lastLetterAt'] != null 
          ? DateTime.parse(json['lastLetterAt'] as String)
          : DateTime.now(),
      friendCount: json['friendCount'] as int? ?? 0,
      sentLetters: json['sentLetters'] as int? ?? 0,
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
  final bool? isRead;

  SharedFlowerDto({
    required this.id,
    required this.letter,
    required this.sentAt,
    required this.sentByMe,
    this.isRead,
  });

  factory SharedFlowerDto.fromJson(Map<String, dynamic> json) {
    // API 응답 구조에 맞춰 파싱
    // API 명세서: letter 객체는 id, title, preview만 포함
    final letterJson = json['letter'] as Map<String, dynamic>?;
    
    // LetterDto를 생성하기 위해 필요한 필드 구성
    // letter 객체가 있으면 사용, 없으면 전체 json에서 추출
    final letterId = letterJson?['id'] as String? ?? json['id'] as String;
    final letterTitle = letterJson?['title'] as String? ?? '';
    final letterPreview = letterJson?['preview'] as String? ?? '';
    
    // LetterDto를 생성하기 위해 필수 필드 구성
    // API 응답에는 일부 필드만 있으므로 기본값으로 채움
    final letterDto = LetterDto.fromJson({
      'id': letterId,
      'title': letterTitle,
      'content': letterPreview, // content가 없으면 preview 사용
      'preview': letterPreview,
      'sender': {
        'id': '',
        'email': '',
        'username': '',
        'nickname': '알 수 없음',
        'avatarUrl': null,
      },
      'flowerType': json['flowerType'] as String? ?? 'ROSE',
      'sentAt': json['sentAt'] as String,
      'isAnonymous': false,
      'views': 0,
      'visibility': 'DIRECT',
    });
    
    return SharedFlowerDto(
      id: json['id'] as String,
      letter: letterDto,
      sentAt: DateTime.parse(json['sentAt'] as String),
      sentByMe: json['sentByMe'] as bool,
      isRead: json['isRead'] as bool?,
    );
  }

  SharedFlower toModel() {
    return SharedFlower(
      id: id,
      letter: letter.toModel(),
      sentAt: sentAt,
      sentByMe: sentByMe,
      isRead: isRead,
    );
  }
}
