# 앱 아이콘 설정 가이드

안드로이드와 iOS 앱 아이콘을 자동으로 생성하는 설정이 완료되었습니다.

## 📋 사전 준비

1. **아이콘 이미지 준비**
   - `assets/images/app_icon.png` 파일을 준비하세요
   - 권장 크기: **1024x1024 픽셀**
   - 형식: PNG (투명 배경 가능)
   - 네온 스타일의 꽃 이미지를 사용하는 것을 권장합니다

## 🚀 아이콘 생성 방법

### 1단계: 패키지 설치
```bash
flutter pub get
```

### 2단계: 아이콘 생성
```bash
flutter pub run flutter_launcher_icons
```

이 명령어를 실행하면:
- ✅ **Android**: 모든 mipmap 폴더에 적절한 크기의 아이콘이 자동 생성됩니다
  - `mipmap-mdpi/ic_launcher.png` (48x48)
  - `mipmap-hdpi/ic_launcher.png` (72x72)
  - `mipmap-xhdpi/ic_launcher.png` (96x96)
  - `mipmap-xxhdpi/ic_launcher.png` (144x144)
  - `mipmap-xxxhdpi/ic_launcher.png` (192x192)
  - Adaptive Icon (foreground + background)

- ✅ **iOS**: AppIcon.appiconset 폴더에 모든 필요한 크기의 아이콘이 자동 생성됩니다
  - 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024 등

## ⚙️ 설정 내용

현재 `pubspec.yaml`에 다음과 같이 설정되어 있습니다:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#0A0024"  # 네온 그리드 템플릿 배경색
  remove_alpha_ios: true
```

### 설정 설명

- **android: true**: Android 아이콘 생성 활성화
- **ios: true**: iOS 아이콘 생성 활성화
- **image_path**: 기본 아이콘 이미지 경로
- **adaptive_icon_background**: Android Adaptive Icon의 배경색 (#0A0024 = 어두운 보라색)
- **remove_alpha_ios**: iOS 아이콘에서 투명도 제거 (App Store 요구사항)

## 📱 Android Adaptive Icon

Android 8.0 (API 26) 이상에서는 Adaptive Icon을 사용합니다:
- **Foreground**: `app_icon.png` 이미지 사용
- **Background**: `#0A0024` 색상 (네온 그리드 템플릿 배경색)

## 🔄 아이콘 업데이트

아이콘을 변경하려면:
1. `assets/images/app_icon.png` 파일을 새 이미지로 교체
2. `flutter pub run flutter_launcher_icons` 실행

## 📝 참고사항

- 아이콘 이미지는 정사각형이어야 합니다
- iOS는 투명 배경을 지원하지만, App Store 제출 시 투명도가 제거됩니다
- Android Adaptive Icon은 원형, 사각형, 둥근 사각형 등 다양한 형태로 표시될 수 있습니다
- 아이콘 생성 후 앱을 다시 빌드해야 변경사항이 반영됩니다

## 🎨 아이콘 디자인 권장사항

- 네온 스타일의 꽃 이미지 사용
- 밝고 대비가 뚜렷한 색상 사용
- 작은 크기에서도 식별 가능한 디자인
- 배경과 대비되는 색상 사용

## ❓ 문제 해결

### 아이콘이 생성되지 않는 경우
1. `assets/images/app_icon.png` 파일이 존재하는지 확인
2. 이미지 파일이 손상되지 않았는지 확인
3. `flutter pub get`을 다시 실행
4. `flutter clean` 후 다시 시도

### 아이콘이 표시되지 않는 경우
1. 앱을 완전히 종료하고 다시 실행
2. `flutter clean` 후 다시 빌드
3. Android: `android/app/src/main/res` 폴더 확인
4. iOS: Xcode에서 Assets.xcassets 확인

