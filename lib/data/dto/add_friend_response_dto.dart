import 'package:taba_app/data/dto/user_dto.dart';

/// 친구 추가 응답 DTO
/// API 명세서: POST /friends/invite 응답 구조
class AddFriendResponseDto {
  final UserDto friend;
  final bool alreadyFriends;
  final bool isOwnCode;

  AddFriendResponseDto({
    required this.friend,
    required this.alreadyFriends,
    required this.isOwnCode,
  });

  factory AddFriendResponseDto.fromJson(Map<String, dynamic> json) {
    return AddFriendResponseDto(
      friend: UserDto.fromJson(json['friend'] as Map<String, dynamic>),
      alreadyFriends: json['alreadyFriends'] as bool? ?? false,
      isOwnCode: json['isOwnCode'] as bool? ?? false,
    );
  }
}

