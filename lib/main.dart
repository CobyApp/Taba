import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:taba_app/app.dart';

// 웹이 아닐 때만 FCM 관련 import
import 'package:taba_app/data/services/fcm_background_handler.dart'
    if (dart.library.html) 'package:taba_app/data/services/fcm_background_handler_stub.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.html) 'package:taba_app/data/services/firebase_messaging_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 웹이 아닐 때만 백그라운드 메시지 핸들러 등록
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  
  runApp(const TabaApp());
}
