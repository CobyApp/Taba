enum NotificationCategory { letter, reaction, friend, system }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    this.isUnread = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final NotificationCategory category;
  final bool isUnread;

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}
