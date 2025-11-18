import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/core/storage/token_storage.dart';
import 'package:taba_app/data/dto/api_response.dart';

class FcmService {
  final ApiClient _apiClient = ApiClient();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _currentToken;

  /// FCM 토큰 초기화 및 등록
  Future<void> initialize() async {
    try {
      // 알림 권한 요청
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 토큰 가져오기
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          _currentToken = token;
          print('📱 FCM Token: $token');
        }

        // 토큰 갱신 리스너
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          print('📱 FCM Token refreshed: $newToken');
          // 토큰이 갱신되면 서버에 업데이트
          _registerTokenToServer(newToken);
        });
      } else {
        print('⚠️ FCM 권한이 거부되었습니다: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ FCM 초기화 실패: $e');
    }
  }

  /// 현재 FCM 토큰 가져오기
  Future<String?> getToken() async {
    if (_currentToken == null) {
      _currentToken = await _firebaseMessaging.getToken();
    }
    return _currentToken;
  }

  /// 서버에 FCM 토큰 등록
  Future<bool> registerTokenToServer(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ FCM 토큰이 없습니다.');
        return false;
      }

      return await _registerTokenToServer(token, userId);
    } catch (e) {
      print('❌ FCM 토큰 등록 실패: $e');
      return false;
    }
  }

  Future<bool> _registerTokenToServer(String token, [String? userId]) async {
    try {
      // userId가 없으면 토큰에서 가져오기
      String? targetUserId = userId;
      if (targetUserId == null) {
        final tokenStorage = TokenStorage();
        targetUserId = await tokenStorage.getUserId();
      }

      if (targetUserId == null) {
        print('⚠️ 사용자 ID가 없어 FCM 토큰을 등록할 수 없습니다.');
        return false;
      }

      final response = await _apiClient.dio.put(
        '/users/$targetUserId/fcm-token',
        data: {'fcmToken': token},
      );

      if (response.data is! Map<String, dynamic>) {
        return false;
      }

      final apiResponse = ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );

      if (apiResponse.isSuccess) {
        print('✅ FCM 토큰이 서버에 등록되었습니다.');
        return true;
      } else {
        print('❌ FCM 토큰 등록 실패: ${apiResponse.error?.message}');
        return false;
      }
    } catch (e) {
      print('❌ FCM 토큰 등록 예외: $e');
      return false;
    }
  }

  /// FCM 토큰 삭제 (로그아웃 시)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _currentToken = null;
      print('🗑️ FCM 토큰이 삭제되었습니다.');
    } catch (e) {
      print('❌ FCM 토큰 삭제 실패: $e');
    }
  }
}

