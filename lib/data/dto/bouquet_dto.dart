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
  final String? fontFamily; // 최상위 레벨의 fontFamily
  final DateTime? scheduledAt; // 예약 전송 시간

  SharedFlowerDto({
    required this.id,
    required this.letter,
    required this.sentAt,
    required this.sentByMe,
    this.isRead,
    this.fontFamily,
    this.scheduledAt,
  });

  factory SharedFlowerDto.fromJson(Map<String, dynamic> json) {
    try {
      // API 명세서 응답 구조:
      // {
      //   "id": "letter-uuid",
      //   "letter": {
      //     "id": "letter-uuid",
      //     "title": "편지 제목",
      //     "preview": "미리보기",
      //     "fontFamily": "Arial"
      //   },
      //   "sentAt": "2024-01-01T00:00:00",
      //   "sentByMe": false,
      //   "isRead": true,
      //   "fontFamily": "Arial"  // 최상위 레벨 (letter.fontFamily보다 우선)
      // }
      final letterJson = json['letter'] as Map<String, dynamic>?;
      
      if (letterJson == null) {
        throw Exception('letter 객체가 없습니다: $json');
      }
      
      // letter 객체에서 정보 추출 (API 명세서: id, title, preview, fontFamily만 포함)
      final letterId = letterJson['id'] as String? ?? json['id'] as String? ?? '';
      final letterTitle = letterJson['title'] as String? ?? '';
      final letterPreview = letterJson['preview'] as String? ?? '';
      final letterFontFamily = letterJson['fontFamily'] as String?;
      
      // 최상위 레벨의 fontFamily (letter의 fontFamily보다 우선)
      final fontFamily = json['fontFamily'] as String? ?? letterFontFamily;
      
      // sentAt 파싱 (ISO 8601 형식, API 명세서에 따르면 항상 포함됨)
      DateTime sentAt;
      try {
        sentAt = DateTime.parse(json['sentAt'] as String);
      } catch (e) {
        print('SharedFlowerDto sentAt 파싱 에러: $e, 값: ${json['sentAt']}');
        sentAt = DateTime.now(); // 안전장치
      }
      
      // scheduledAt 파싱 (예약 전송 시간, 선택사항)
      DateTime? scheduledAt;
      if (json['scheduledAt'] != null) {
        try {
          scheduledAt = DateTime.parse(json['scheduledAt'] as String);
        } catch (e) {
          print('SharedFlowerDto scheduledAt 파싱 에러: $e, 값: ${json['scheduledAt']}');
          scheduledAt = null;
        }
      }
      
      // LetterDto를 생성하기 위해 필수 필드 구성
      // API 응답에는 일부 필드만 있으므로 기본값으로 채움
      // sender 정보는 letter 객체에 없음 (API 명세서에 명시되지 않음)
      // 템플릿 정보는 letter 객체에 포함될 수 있음
      final letterJsonForDto = {
        'id': letterId,
        'title': letterTitle,
        'content': letterPreview, // content가 없으면 preview 사용
        'preview': letterPreview,
        'sender': {
          // sender 정보는 letter 객체에 없으므로 기본값 사용
          // sentByMe로 발신자 판단 가능
          'id': '',
          'email': '',
          'nickname': '알 수 없음',
          'avatarUrl': null,
        },
        'sentAt': json['sentAt'] as String,
        'views': 0,
        'visibility': 'DIRECT', // 친구별 편지는 항상 DIRECT (API 명세서 참고)
      };
      
      // 템플릿 정보가 letter 객체에 있으면 포함
      if (letterJson['template'] != null) {
        letterJsonForDto['template'] = letterJson['template'];
      }
      
      final letterDto = LetterDto.fromJson(letterJsonForDto);
      
      return SharedFlowerDto(
        id: json['id'] as String? ?? letterId, // id가 없으면 letterId 사용
        letter: letterDto,
        sentAt: sentAt,
        sentByMe: json['sentByMe'] as bool? ?? false,
        // API 명세서: 내가 받은 편지인 경우 읽음 상태 (boolean), 내가 보낸 편지는 null
        isRead: json['isRead'] as bool?,
        fontFamily: fontFamily,
        scheduledAt: scheduledAt,
      );
    } catch (e, stackTrace) {
      print('SharedFlowerDto.fromJson 에러: $e');
      print('Stack trace: $stackTrace');
      print('JSON: $json');
      rethrow;
    }
  }

  SharedFlower toModel() {
    return SharedFlower(
      id: id,
      letter: letter.toModel(),
      sentAt: sentAt,
      sentByMe: sentByMe,
      isRead: isRead,
      scheduledAt: scheduledAt,
    );
  }
}
