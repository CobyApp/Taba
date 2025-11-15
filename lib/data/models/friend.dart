import 'package:taba_app/data/models/user.dart';

class FriendProfile {
  const FriendProfile({
    required this.user,
    required this.lastLetterAt,
    required this.friendCount,
    required this.sentLetters,
    required this.inviteCode,
    this.group = '전체',
  });

  final TabaUser user;
  final DateTime lastLetterAt;
  final int friendCount;
  final int sentLetters;
  final String inviteCode;
  final String group;

  String get lastLetterAgo {
    final diff = DateTime.now().difference(lastLetterAt);
    if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    }
    return '${diff.inDays}일 전';
  }
}
