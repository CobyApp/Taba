import 'package:flutter/services.dart';

/// 앱 아이콘 뱃지 관리 서비스
/// API 명세서: GET /notifications/unread-count를 사용하여 읽지 않은 알림 개수로 뱃지 설정
class AppBadgeService {
  AppBadgeService._();
  static final AppBadgeService instance = AppBadgeService._();

  static const MethodChannel _channel = MethodChannel('com.coby.taba/app_badge');

  /// 앱 아이콘 뱃지 숫자 업데이트
  /// [count] 뱃지에 표시할 숫자 (0이면 뱃지 제거)
  /// API 명세서: GET /notifications/unread-count의 unreadCount 값 사용
  Future<void> updateBadge(int count) async {
    try {
      await _channel.invokeMethod('updateBadge', {'count': count});
    } catch (e) {
      print('앱 뱃지 업데이트 실패: $e');
    }
  }

  /// 앱 아이콘 뱃지 제거
  Future<void> removeBadge() async {
    try {
      await _channel.invokeMethod('removeBadge');
    } catch (e) {
      print('앱 뱃지 제거 실패: $e');
    }
  }
}

