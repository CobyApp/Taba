import 'package:shared_preferences/shared_preferences.dart';

/// 공개 편지를 읽었는지 추적하는 스토리지
class ReadLetterStorage {
  static const String _key = 'read_public_letters';
  
  /// 편지 ID를 읽은 목록에 추가
  static Future<void> markAsRead(String letterId) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_key) ?? [];
    if (!readIds.contains(letterId)) {
      readIds.add(letterId);
      await prefs.setStringList(_key, readIds);
    }
  }
  
  /// 편지 ID가 읽은 목록에 있는지 확인
  static Future<bool> isRead(String letterId) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_key) ?? [];
    return readIds.contains(letterId);
  }
  
  /// 읽은 편지 ID 목록 조회
  static Future<Set<String>> getReadLetterIds() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_key) ?? [];
    return readIds.toSet();
  }
  
  /// 읽은 편지 목록 초기화
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

