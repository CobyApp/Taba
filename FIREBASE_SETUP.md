# Firebase 설정 가이드

FCM (Firebase Cloud Messaging)을 사용하기 위한 Firebase 프로젝트 설정 방법입니다.

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: "Taba")
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

## 2. Android 앱 추가

1. Firebase Console에서 프로젝트 선택
2. "앱 추가" → Android 선택
3. Android 패키지 이름 입력: `com.coby.taba`
4. 앱 닉네임 입력 (선택사항)
5. `google-services.json` 파일 다운로드
6. 다운로드한 `google-services.json` 파일을 다음 위치에 복사:
   ```
   android/app/google-services.json
   ```

## 3. iOS 앱 추가

1. Firebase Console에서 프로젝트 선택
2. "앱 추가" → iOS 선택
3. iOS 번들 ID 입력: Xcode 프로젝트의 Bundle Identifier 확인 필요
   - Xcode에서 `ios/Runner.xcodeproj` 열기
   - Runner 타겟 → General → Bundle Identifier 확인
4. 앱 닉네임 입력 (선택사항)
5. `GoogleService-Info.plist` 파일 다운로드
6. 다운로드한 `GoogleService-Info.plist` 파일을 다음 위치에 복사:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
7. Xcode에서 `ios/Runner.xcworkspace` 열기
8. Finder에서 `GoogleService-Info.plist` 파일을 Xcode의 `Runner` 폴더로 드래그
9. "Copy items if needed" 체크
10. "Add to targets: Runner" 체크

## 4. iOS APNs 인증 키 설정 (푸시 알림용)

iOS에서 FCM 푸시 알림을 받으려면 APNs (Apple Push Notification service) 인증 키가 필요합니다.

### Apple Developer Portal에서 APNs 인증 키 생성

1. [Apple Developer Portal](https://developer.apple.com/account) 접속
2. Apple ID로 로그인
3. 왼쪽 메뉴에서 **"Certificates, Identifiers & Profiles"** 클릭
4. **"Keys"** 섹션 클릭
5. 상단의 **"+"** 버튼 클릭
6. **Key Name** 입력 (예: "Taba App APNs Key")
7. **"Apple Push Notifications service (APNs)"** 체크박스 선택
8. **"Continue"** 클릭
9. **"Register"** 클릭하여 키 생성
10. 생성 완료 후:
    - **".p8" 파일 다운로드** (⚠️ 한 번만 다운로드 가능하므로 안전하게 보관!)
    - **Key ID** 기록 (예: "ABC123DEF4")
    - **Team ID** 기록 (페이지 상단 오른쪽에 표시됨)

### Firebase Console에 APNs 인증 키 등록

1. [Firebase Console](https://console.firebase.google.com/) 접속
2. 프로젝트 선택
3. 프로젝트 설정 (톱니바퀴 아이콘) 클릭
4. **"클라우드 메시징"** 탭 클릭
5. **"APNs 인증 키"** 섹션에서:
   - **"업로드"** 버튼 클릭
   - 다운로드한 **.p8 파일** 선택
   - **Key ID** 입력
   - **Team ID** 입력
   - **"업로드"** 클릭

### Xcode에서 Push Notifications Capability 추가

1. Xcode에서 `ios/Runner.xcworkspace` 열기
2. 프로젝트 네비게이터에서 **Runner** 타겟 선택
3. **"Signing & Capabilities"** 탭 클릭
4. 상단의 **"+ Capability"** 버튼 클릭
5. **"Push Notifications"** 검색 후 추가

## 5. iOS 추가 설정

### AppDelegate.swift 수정

`ios/Runner/AppDelegate.swift` 파일에 Firebase 초기화 코드가 추가되어 있습니다:

```swift
import Flutter
import UIKit
import FirebaseCore  // 추가됨

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // 추가됨
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Podfile 확인

`ios/Podfile`에 Firebase 관련 설정이 자동으로 추가됩니다. 다음 명령어 실행:

```bash
cd ios
pod install
```

## 6. 빌드 및 실행

설정이 완료되면 다음 명령어로 앱을 빌드하고 실행:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## 7. 확인 사항

- ✅ `android/app/google-services.json` 파일 존재
- ✅ `ios/Runner/GoogleService-Info.plist` 파일 존재
- ✅ Android build.gradle.kts에 Google Services 플러그인 적용됨
- ✅ iOS Podfile에서 pod install 실행 완료
- ✅ Firebase Console에 APNs 인증 키 등록됨
- ✅ Xcode에서 Push Notifications Capability 추가됨
- ✅ 앱 실행 시 FCM 토큰이 콘솔에 출력됨

## 문제 해결

### Android 빌드 에러
- `google-services.json` 파일이 `android/app/` 디렉토리에 있는지 확인
- `flutter clean` 후 다시 빌드

### iOS 빌드 에러
- `GoogleService-Info.plist` 파일이 Xcode 프로젝트에 추가되었는지 확인
- `pod install` 실행 확인
- Xcode에서 Clean Build Folder (Cmd+Shift+K)

### FCM 토큰이 출력되지 않음
- Firebase 프로젝트 설정이 올바른지 확인
- 앱 권한 설정 확인 (알림 권한)
- 로그인 후 FCM 토큰 등록 확인
- Firebase Console에 APNs 인증 키가 등록되었는지 확인
- Xcode에서 Push Notifications Capability가 추가되었는지 확인

### iOS APNS 토큰을 가져오지 못함
- Firebase Console에 APNs 인증 키가 등록되었는지 확인
- Xcode에서 Push Notifications Capability가 추가되었는지 확인
- 실제 iOS 기기에서 테스트 (시뮬레이터에서는 APNS 토큰을 가져올 수 없음)
- 앱을 완전히 종료 후 다시 실행
- 알림 권한을 허용했는지 확인

