# 앱 아이콘 이미지

이 폴더에 앱 아이콘 이미지를 준비하세요.

## 필요한 파일

1. **app_icon.png** (필수)
   - 크기: 1024x1024 픽셀
   - 형식: PNG (투명 배경 가능)
   - 용도: Android 및 iOS 앱 아이콘 생성의 기본 이미지

2. **app_icon_foreground.png** (선택사항)
   - 크기: 1024x1024 픽셀
   - 형식: PNG (투명 배경)
   - 용도: Android Adaptive Icon의 foreground 이미지
   - 없으면 app_icon.png를 사용합니다

## 아이콘 생성 방법

1. 이미지 파일 준비
   ```bash
   # assets/images/app_icon.png 파일을 준비하세요
   ```

2. 패키지 설치
   ```bash
   flutter pub get
   ```

3. 아이콘 생성
   ```bash
   flutter pub run flutter_launcher_icons
   ```

이 명령어를 실행하면:
- Android: 모든 mipmap 폴더에 적절한 크기의 아이콘이 생성됩니다
- iOS: AppIcon.appiconset 폴더에 모든 필요한 크기의 아이콘이 생성됩니다

## 참고

- 아이콘은 네온 스타일의 꽃 이미지를 사용하는 것을 권장합니다
- Android Adaptive Icon의 배경색은 `#0A0024` (네온 그리드 템플릿 배경색)로 설정되어 있습니다
- iOS는 투명도가 제거된 버전이 생성됩니다

