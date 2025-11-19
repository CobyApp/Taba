import 'package:shared_preferences/shared_preferences.dart';

/// 답장한 편지의 원본 편지 ID를 저장하는 스토리지
class ReplyStorage {
  static const String _replyPrefix = 'reply_original_';
  
  /// 답장한 편지 ID와 원본 편지 ID를 저장
  /// replyLetterId: 답장한 편지 ID
  /// originalLetterId: 원본 공개 편지 ID
  static Future<void> saveReplyOriginal({
    required String replyLetterId,
    required String originalLetterId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_replyPrefix$replyLetterId', originalLetterId);
  }
  
  /// 답장한 편지 ID로 원본 편지 ID 조회
  static Future<String?> getOriginalLetterId(String replyLetterId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_replyPrefix$replyLetterId');
  }
  
  /// 답장한 편지 ID와 원본 편지 ID 매핑 삭제
  static Future<void> removeReplyOriginal(String replyLetterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_replyPrefix$replyLetterId');
  }
  
  /// 모든 답장-원본 편지 매핑 삭제
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_replyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}

