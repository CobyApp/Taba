class InviteCodeDto {
  final String code;
  final DateTime expiresAt;
  final int? remainingMinutes;

  InviteCodeDto({
    required this.code,
    required this.expiresAt,
    this.remainingMinutes,
  });

  factory InviteCodeDto.fromJson(Map<String, dynamic> json) {
    return InviteCodeDto(
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      remainingMinutes: json['remainingMinutes'] as int?,
    );
  }

  Duration? get remainingValidity {
    if (remainingMinutes != null) {
      return Duration(minutes: remainingMinutes!);
    }
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }
}

