/// 웹 플랫폼용 FCM 백그라운드 핸들러 스텁
/// 웹에서는 FCM 백그라운드 핸들러가 지원되지 않으므로 빈 구현 제공

Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {
  // 웹에서는 백그라운드 메시지 핸들러가 지원되지 않음
}

