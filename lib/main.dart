import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:taba_app/app.dart';
import 'package:taba_app/data/services/fcm_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 백그라운드 메시지 핸들러 등록 (앱이 백그라운드에 있을 때)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(const TabaApp());
}
