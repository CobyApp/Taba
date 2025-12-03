/// 차단한 사용자 DTO
/// API 명세서: GET /blocks 응답
class BlockedUserDto {
  const BlockedUserDto({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.blockedAt,
  });

  final String id;
  final String nickname;
  final String? avatarUrl;
  final DateTime blockedAt;

  factory BlockedUserDto.fromJson(Map<String, dynamic> json) {
    return BlockedUserDto(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'blockedAt': blockedAt.toIso8601String(),
    };
  }
}

