import 'package:taba_app/data/models/notification.dart';

class NotificationDto {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime createdAt;
  final DateTime? readAt;
  final String category;
  final bool isRead;
  final String? relatedId;

  NotificationDto({
    required this.id,
    required this.title,
    this.subtitle,
    required this.createdAt,
    this.readAt,
    required this.category,
    this.isRead = false,
    this.relatedId,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String)
          : null,
      category: json['category'] as String,
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as String?,
    );
  }

  NotificationItem toModel() {
    return NotificationItem(
      id: id,
      title: title,
      subtitle: subtitle ?? '',
      time: createdAt, // createdAt을 time으로 매핑
      category: _parseCategory(category),
      isUnread: !isRead, // isRead를 isUnread로 변환
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
