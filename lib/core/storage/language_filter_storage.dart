import 'package:shared_preferences/shared_preferences.dart';

/// 공개 편지 언어 필터 설정을 저장하는 스토리지
class LanguageFilterStorage {
  static const String _key = 'public_letter_language_filters';
  
  /// 선택된 언어 필터 저장
  /// languages: 선택된 언어 코드 리스트 (예: ['ko', 'en'])
  /// 빈 리스트이면 모든 언어를 의미 (기본값)
  static Future<void> saveLanguages(List<String> languages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, languages);
  }
  
  /// 저장된 언어 필터 조회
  /// null이면 저장된 값이 없음 (기본값: 모든 언어)
  /// 빈 리스트이면 모든 언어를 의미
  static Future<List<String>?> getLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key);
  }
  
  /// 언어 필터 설정 초기화 (모든 언어 표시)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

