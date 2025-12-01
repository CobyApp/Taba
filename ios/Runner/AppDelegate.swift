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
    
    // 앱 시작 시 배지 초기화 (앱을 새로 깔 때나 재시작 시)
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // Method Channel 설정 (앱 뱃지용)
    let controller = window?.rootViewController as! FlutterViewController
    let badgeChannel = FlutterMethodChannel(
      name: "com.coby.taba/app_badge",
      binaryMessenger: controller.binaryMessenger
    )
    
    badgeChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "updateBadge" {
        if let args = call.arguments as? [String: Any],
           let count = args["count"] as? Int {
          DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
            print("✅ iOS 배지 업데이트: \(count)")
            result(nil)
          }
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Count argument is required", details: nil))
        }
      } else if call.method == "removeBadge" {
        DispatchQueue.main.async {
          UIApplication.shared.applicationIconBadgeNumber = 0
          print("✅ iOS 배지 제거")
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
