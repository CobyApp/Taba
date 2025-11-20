import 'package:firebase_messaging/firebase_messaging.dart';

/// 백그라운드 메시지 핸들러 (top-level 함수로 선언되어야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 백그라운드 메시지 수신: ${message.messageId}');
  print('   제목: ${message.notification?.title}');
  print('   본문: ${message.notification?.body}');
  print('   데이터: ${message.data}');
  
  // 백그라운드에서는 시스템이 자동으로 알림을 표시하므로
  // 여기서는 로깅만 수행
}

