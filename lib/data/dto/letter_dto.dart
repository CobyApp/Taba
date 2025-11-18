import 'package:flutter/material.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/dto/user_dto.dart';

class LetterDto {
  final String id;
  final String title;
  final String content;
  final String preview;
  final UserDto sender;
  final DateTime sentAt;
  final bool isAnonymous;
  final int views;
  final String visibility;
  final List<String>? tags;
  final LetterTemplateDto? template;
  final List<String>? attachedImages;
  final Map<String, double>? position; // 하늘 화면용 좌표

  LetterDto({
    required this.id,
    required this.title,
    required this.content,
    required this.preview,
    required this.sender,
    required this.sentAt,
    this.isAnonymous = false,
    this.views = 0,
    required this.visibility,
    this.tags,
    this.template,
    this.attachedImages,
    this.position,
  });

  factory LetterDto.fromJson(Map<String, dynamic> json) {
    return LetterDto(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      preview: json['preview'] as String,
      sender: UserDto.fromJson(json['sender'] as Map<String, dynamic>),
      // flowerType은 더 이상 사용하지 않음 (API 응답에 있어도 무시)
      sentAt: DateTime.parse(json['sentAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      visibility: json['visibility'] as String,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      template: json['template'] != null
          ? LetterTemplateDto.fromJson(json['template'] as Map<String, dynamic>)
          : null,
      attachedImages: json['attachedImages'] != null
          ? List<String>.from(json['attachedImages'] as List)
          : null,
      position: json['position'] != null
          ? Map<String, double>.from(
              (json['position'] as Map).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'preview': preview,
      // flowerType 제거됨
      'visibility': visibility,
      'isAnonymous': isAnonymous,
      'template': template?.toJson(),
      'attachedImages': attachedImages,
      'scheduledAt': null, // 필요시 추가
      'recipientId': null, // 필요시 추가
    };
  }

  Letter toModel() {
    return Letter(
      id: id,
      title: title,
      preview: preview,
      content: content,
      sentAt: sentAt,
      sender: sender.toModel(),
      // flower 필드 제거됨
      isAnonymous: isAnonymous,
      views: views,
      visibility: _parseVisibility(visibility),
      tags: tags ?? [],
      template: template?.toModel(),
      attachedImages: attachedImages ?? [],
    );
  }

  VisibilityScope _parseVisibility(String visibility) {
    switch (visibility.toUpperCase()) {
      case 'PUBLIC':
        return VisibilityScope.public;
      case 'FRIENDS':
        return VisibilityScope.friends;
      case 'DIRECT':
        return VisibilityScope.direct;
      case 'PRIVATE':
        return VisibilityScope.private;
      default:
        return VisibilityScope.public;
    }
  }
}

class LetterTemplateDto {
  final String? background;
  final String? textColor;
  final String? fontFamily;
  final double? fontSize;

  LetterTemplateDto({
    this.background,
    this.textColor,
    this.fontFamily,
    this.fontSize,
  });

  factory LetterTemplateDto.fromJson(Map<String, dynamic> json) {
    return LetterTemplateDto(
      background: json['background'] as String?,
      textColor: json['textColor'] as String?,
      fontFamily: json['fontFamily'] as String?,
      fontSize: json['fontSize'] != null
          ? (json['fontSize'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background': background,
      'textColor': textColor,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }

  LetterStyle? toModel() {
    if (background == null || textColor == null) return null;
    return LetterStyle(
      background: _parseColor(background!),
      textColor: _parseColor(textColor!),
      fontFamily: fontFamily ?? 'Poppins',
      fontSize: fontSize ?? 16.0,
    );
  }

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
