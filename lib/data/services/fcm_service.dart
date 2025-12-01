import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/core/storage/token_storage.dart';
import 'package:taba_app/data/dto/api_response.dart';

/// 푸시 알림 메시지 핸들러 콜백 타입
typedef PushMessageHandler = void Function(RemoteMessage message);

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();
  
  final ApiClient _apiClient = ApiClient.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _currentToken;
  bool _isInitialized = false;
  PushMessageHandler? _onMessageHandler;
  PushMessageHandler? _onMessageOpenedAppHandler;

  /// FCM 토큰 초기화 및 등록
  Future<void> initialize() async {
    try {
      // 알림 권한 요청 (iOS에서는 권한 요청 후 APNS 토큰이 설정됨)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // iOS인 경우 APNS 토큰을 기다림 (비동기로 설정되므로)
        bool apnsTokenReady = false;
        if (Platform.isIOS) {
          // APNS 토큰 가져오기 시도 (최대 5초 대기)
          for (int i = 0; i < 5; i++) {
            try {
              final apnsToken = await _firebaseMessaging.getAPNSToken();
              if (apnsToken != null) {
                print('📱 APNS Token: $apnsToken');
                apnsTokenReady = true;
                break;
              }
            } catch (e) {
              // APNS 토큰이 아직 없을 수 있음
            }
            await Future.delayed(const Duration(seconds: 1));
          }

          if (!apnsTokenReady) {
            print('⚠️ APNS Token을 아직 가져오지 못했습니다. FCM 토큰 가져오기를 시도합니다.');
            // APNS 토큰이 없어도 FCM 토큰 가져오기 시도
          }
        }

        // FCM 토큰 가져오기 시도 (APNS 토큰이 있거나 Android인 경우)
        try {
          final token = await _firebaseMessaging.getToken();
          if (token != null) {
            _currentToken = token;
            print('📱 FCM Token: $token');
          } else {
            print('⚠️ FCM Token을 가져올 수 없습니다.');
          }
        } catch (e) {
          print('⚠️ FCM Token 가져오기 실패: $e');
          // 에러가 발생해도 계속 진행
        }

        // 토큰 갱신 리스너
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          print('📱 FCM Token refreshed: $newToken');
          // 토큰이 갱신되면 서버에 업데이트
          _registerTokenToServer(newToken);
        });

        // iOS에서 APNS 토큰이 나중에 설정될 수 있으므로 백그라운드에서 주기적으로 확인
        if (Platform.isIOS && !apnsTokenReady) {
          _waitForApnsTokenAndGetFcmToken();
        }

        // 포그라운드 메시지 핸들러 설정
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('📬 포그라운드 메시지 수신: ${message.messageId}');
          print('   제목: ${message.notification?.title}');
          print('   본문: ${message.notification?.body}');
          print('   데이터: ${message.data}');
          _onMessageHandler?.call(message);
        });

        // 백그라운드에서 알림 탭 시 핸들러 설정
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('📬 백그라운드에서 알림 탭: ${message.messageId}');
          print('   제목: ${message.notification?.title}');
          print('   데이터: ${message.data}');
          _onMessageOpenedAppHandler?.call(message);
        });

        // 앱이 종료된 상태에서 알림 탭 시 처리
        final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          print('📬 앱 종료 상태에서 알림 탭: ${initialMessage.messageId}');
          // 앱이 완전히 초기화된 후 처리하도록 약간의 지연
          Future.delayed(const Duration(seconds: 2), () {
            _onMessageOpenedAppHandler?.call(initialMessage);
          });
        }
      } else {
        print('⚠️ FCM 권한이 거부되었습니다: ${settings.authorizationStatus}');
      }
      
      _isInitialized = true;
    } catch (e) {
      print('❌ FCM 초기화 실패: $e');
      // 에러가 발생해도 앱은 계속 진행
      _isInitialized = true;
    }
  }

  /// iOS에서 APNS 토큰이 설정될 때까지 기다리고 FCM 토큰 가져오기
  Future<void> _waitForApnsTokenAndGetFcmToken() async {
    // 백그라운드에서 최대 30초 동안 APNS 토큰을 기다림
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          print('📱 APNS Token이 설정되었습니다: $apnsToken');
          // APNS 토큰이 설정되었으므로 FCM 토큰 가져오기 시도
          try {
            final fcmToken = await _firebaseMessaging.getToken();
            if (fcmToken != null) {
              _currentToken = fcmToken;
              print('📱 FCM Token: $fcmToken');
              // 서버에 등록 시도
              final tokenStorage = TokenStorage();
              final userId = await tokenStorage.getUserId();
              if (userId != null) {
                await _registerTokenToServer(fcmToken, userId);
              }
            }
          } catch (e) {
            print('⚠️ FCM Token 가져오기 실패: $e');
          }
          return; // 성공했으므로 종료
        }
      } catch (e) {
        // APNS 토큰이 아직 없음
      }
    }
    print('⚠️ APNS Token을 30초 동안 기다렸지만 설정되지 않았습니다.');
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

  /// 포그라운드 메시지 핸들러 설정
  void setOnMessageHandler(PushMessageHandler? handler) {
    _onMessageHandler = handler;
  }

  /// 백그라운드에서 알림 탭 시 핸들러 설정
  void setOnMessageOpenedAppHandler(PushMessageHandler? handler) {
    _onMessageOpenedAppHandler = handler;
  }

  /// 현재 알림 권한 상태 확인
  Future<AuthorizationStatus> getNotificationPermissionStatus() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      print('❌ 알림 권한 상태 확인 실패: $e');
      return AuthorizationStatus.notDetermined;
    }
  }

  /// 알림 권한이 허용되었는지 확인
  Future<bool> isNotificationPermissionGranted() async {
    final status = await getNotificationPermissionStatus();
    return status == AuthorizationStatus.authorized ||
           status == AuthorizationStatus.provisional;
  }
}

