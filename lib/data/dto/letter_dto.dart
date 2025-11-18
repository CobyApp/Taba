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
    // API 명세서에 따르면:
    // - 공개 편지 목록에는 content가 없고 preview만 있음
    // - 편지 상세 조회에는 content와 preview 모두 있음
    // - sender는 {id, nickname}만 포함될 수 있음
    final preview = json['preview'] as String? ?? '';
    final content = json['content'] as String? ?? preview; // content가 없으면 preview 사용
    
    return LetterDto(
      id: json['id'] as String,
      title: json['title'] as String,
      content: content,
      preview: preview,
      sender: UserDto.fromJson(json['sender'] as Map<String, dynamic>),
      // flowerType은 더 이상 사용하지 않음 (API 응답에 있어도 무시)
      // API 명세서에 따르면 sentAt은 항상 포함되어야 함
      sentAt: json['sentAt'] != null 
          ? DateTime.parse(json['sentAt'] as String)
          : DateTime.now(), // 안전장치: sentAt이 없으면 현재 시간 사용
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      views: json['views'] as int? ?? 0,
      visibility: json['visibility'] as String? ?? 'PUBLIC',
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

  Color _parseColor(String colorString) {
    // hex 색상 코드 형식 (#RRGGBB 또는 RRGGBB)
    if (colorString.startsWith('#') || 
        (colorString.length == 6 && RegExp(r'^[0-9A-Fa-f]+$').hasMatch(colorString))) {
      final hexCode = colorString.replaceAll('#', '');
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      }
    }
    
    // 색상 이름 매핑 (API 명세서 예시: "pink", "black" 등)
    final colorMap = {
      'pink': const Color(0xFFFFC0CB),
      'black': Colors.black,
      'white': Colors.white,
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'purple': Colors.purple,
      'orange': Colors.orange,
    };
    
    final lowerColor = colorString.toLowerCase();
    if (colorMap.containsKey(lowerColor)) {
      return colorMap[lowerColor]!;
    }
    
    // 기본값: 검은색
    return Colors.black;
  }
}
