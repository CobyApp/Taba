import 'package:taba_app/data/models/user.dart';

class UserDto {
  final String id;
  final String email;
  final String username;
  final String nickname;
  final String? avatarUrl;
  final String? statusMessage;
  final DateTime? joinedAt;
  final int? friendCount;
  final int? sentLetters;

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.nickname,
    this.avatarUrl,
    this.statusMessage,
    this.joinedAt,
    this.friendCount,
    this.sentLetters,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      statusMessage: json['statusMessage'] as String?,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : null,
      friendCount: json['friendCount'] as int?,
      sentLetters: json['sentLetters'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'statusMessage': statusMessage,
      'joinedAt': joinedAt?.toIso8601String(),
      'friendCount': friendCount,
      'sentLetters': sentLetters,
    };
  }

  TabaUser toModel() {
    return TabaUser(
      id: id,
      username: username,
      nickname: nickname,
      avatarUrl: avatarUrl ?? '',
      statusMessage: statusMessage ?? '',
      joinedAt: joinedAt,
    );
  }
}
