/// 웹 플랫폼용 FirebaseMessaging 스텁
/// 웹에서는 FCM이 지원되지 않으므로 스텁 클래스 제공

import 'dart:async';

class FirebaseMessaging {
  static final FirebaseMessaging _instance = FirebaseMessaging._();
  static FirebaseMessaging get instance => _instance;
  FirebaseMessaging._();
  
  static void onBackgroundMessage(Function handler) {
    // 웹에서는 지원되지 않음
  }
  
  // 웹에서 사용되지 않는 스트림 (빈 스트림 반환)
  static Stream<RemoteMessage> get onMessage => const Stream.empty();
  static Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();
  
  Stream<String> get onTokenRefresh => const Stream.empty();
  
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    return NotificationSettings(authorizationStatus: AuthorizationStatus.denied);
  }
  
  Future<String?> getToken() async => null;
  Future<String?> getAPNSToken() async => null;
  Future<RemoteMessage?> getInitialMessage() async => null;
  Future<void> deleteToken() async {}
  Future<NotificationSettings> getNotificationSettings() async {
    return NotificationSettings(authorizationStatus: AuthorizationStatus.notDetermined);
  }
}

class RemoteMessage {
  final String? messageId;
  final RemoteNotification? notification;
  final Map<String, dynamic> data;
  
  RemoteMessage({
    this.messageId,
    this.notification,
    this.data = const {},
  });
}

class RemoteNotification {
  final String? title;
  final String? body;
  
  RemoteNotification({this.title, this.body});
}

class NotificationSettings {
  final AuthorizationStatus authorizationStatus;
  
  NotificationSettings({required this.authorizationStatus});
}

enum AuthorizationStatus {
  authorized,
  denied,
  notDetermined,
  provisional,
}
