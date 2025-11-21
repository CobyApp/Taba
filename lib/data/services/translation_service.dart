import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// 번역 서비스
/// Google Translate API를 사용하여 텍스트를 번역합니다.
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  /// 언어 코드를 Google Translate API 언어 코드로 변환
  String _getLanguageCode(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return 'ko';
      case 'ja':
        return 'ja';
      case 'en':
      default:
        return 'en';
    }
  }

  /// 텍스트를 번역합니다.
  /// 
  /// [text] 번역할 텍스트
  /// [targetLocale] 목표 언어
  /// [sourceLocale] 원본 언어 (null이면 자동 감지)
  /// 
  /// Returns: 번역된 텍스트 또는 null (실패 시)
  Future<String?> translateText({
    required String text,
    required Locale targetLocale,
    Locale? sourceLocale,
  }) async {
    if (text.trim().isEmpty) {
      return text;
    }

    try {
      final targetLang = _getLanguageCode(targetLocale);
      final sourceLang = sourceLocale != null ? _getLanguageCode(sourceLocale) : 'auto';

      // Google Translate API (무료 버전) 사용
      // 참고: 이 방법은 공개 API를 사용하므로 제한이 있을 수 있습니다.
      // 프로덕션에서는 서버를 통해 번역하거나 공식 API를 사용하는 것을 권장합니다.
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?'
        'client=gtx&'
        'sl=$sourceLang&'
        'tl=$targetLang&'
        'dt=t&'
        'q=${Uri.encodeComponent(text)}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Translation timeout');
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result is List && result.isNotEmpty && result[0] is List) {
          final translations = result[0] as List;
          final translatedText = translations
              .map((item) => item is List && item.isNotEmpty ? item[0] : '')
              .where((text) => text.toString().isNotEmpty)
              .join('');
          return translatedText.isNotEmpty ? translatedText : text;
        }
      }

      return null;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }

  /// 여러 텍스트를 한 번에 번역합니다.
  Future<Map<String, String?>> translateMultiple({
    required Map<String, String> texts,
    required Locale targetLocale,
    Locale? sourceLocale,
  }) async {
    final results = <String, String?>{};
    
    for (final entry in texts.entries) {
      final translated = await translateText(
        text: entry.value,
        targetLocale: targetLocale,
        sourceLocale: sourceLocale,
      );
      results[entry.key] = translated ?? entry.value;
    }
    
    return results;
  }
}

