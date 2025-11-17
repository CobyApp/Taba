import 'package:taba_app/data/models/notification.dart';

class NotificationDto {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime time;
  final String category;
  final bool isUnread;
  final String? relatedId;

  NotificationDto({
    required this.id,
    required this.title,
    this.subtitle,
    required this.time,
    required this.category,
    this.isUnread = true,
    this.relatedId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      time: DateTime.parse(json['time'] as String),
      category: json['category'] as String,
      isUnread: json['isUnread'] as bool? ?? true,
      relatedId: json['relatedId'] as String?,
    );
  }

  NotificationItem toModel() {
    return NotificationItem(
      id: id,
      title: title,
      subtitle: subtitle ?? '',
      time: time,
      category: _parseCategory(category),
      isUnread: isUnread,
    );
  }

  NotificationCategory _parseCategory(String category) {
    switch (category.toUpperCase()) {
      case 'LETTER':
        return NotificationCategory.letter;
      case 'REACTION':
        return NotificationCategory.reaction;
      case 'FRIEND':
        return NotificationCategory.friend;
      case 'SYSTEM':
        return NotificationCategory.system;
      default:
        return NotificationCategory.system;
    }
  }
}
