/// 웹 플랫폼용 FirebaseMessaging 스텁
/// 웹에서는 FCM이 제한적으로 지원되므로 스텁 클래스 제공

class FirebaseMessaging {
  static final FirebaseMessaging _instance = FirebaseMessaging._();
  static FirebaseMessaging get instance => _instance;
  FirebaseMessaging._();
  
  static void onBackgroundMessage(Function handler) {
    // 웹에서는 지원되지 않음
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

enum AuthorizationStatus {
  authorized,
  denied,
  notDetermined,
  provisional,
}

