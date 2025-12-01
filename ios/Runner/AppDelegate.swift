import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase 초기화
    FirebaseApp.configure()
    
    // 앱 아이콘 배지 제거 (기존에 설정된 배지가 남아있을 수 있음)
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
