# Taba (타바)

떠다니는 씨앗을 잡아 꽃을 피워보세요. 🌸

Taba는 편지를 통해 감정을 나누는 모바일 애플리케이션입니다. 친구와 편지를 주고받으며 꽃다발을 키우고, 하늘에 떠다니는 편지 씨앗을 잡아 꽃을 피워보세요.

## 📱 주요 기능

### 편지 작성
- **풀스크린 에디터**: 집중할 수 있는 깔끔한 편지 작성 환경
- **템플릿 선택**: 6가지 레트로 스타일 템플릿 (네온 그리드, 레트로 페이퍼, 민트 터미널 등)
- **폰트 선택**: 언어별 레트로 폰트 지원 (영어, 한국어, 일본어)
- **사진 첨부**: 여러 장의 사진을 첨부하여 편지에 담기
- **예약 발송**: 원하는 시간에 편지를 보낼 수 있는 예약 기능

### 꽃다발
- **채팅형 UI**: 친구와 주고받은 편지를 채팅처럼 보기
- **읽지 않은 편지 표시**: 새로운 편지를 쉽게 확인
- **편지 상세 보기**: 통합된 편지 상세 화면으로 편지 읽기
- **사진 갤러리**: 첨부된 사진을 여러 장 넘기며 보기

### 네온 하늘
- **떠다니는 씨앗**: 공개된 편지 씨앗을 잡아 꽃 피우기
- **편지 탐색**: 다양한 편지들을 발견하고 읽기
- **알림 센터**: 새로운 알림 확인

### 인증
- **이메일 로그인**: 간단한 이메일 기반 로그인
- **회원가입**: 이용약관 및 개인정보처리방침 동의
- **비밀번호 찾기**: 비밀번호 재설정 기능

### 설정
- **프로필 관리**: 사용자 프로필 정보 확인
- **푸시 알림**: 새 편지와 반응 알림 설정
- **친구 초대**: 초대 코드 생성 및 공유
- **다국어 지원**: 한국어, 영어, 일본어
- **언어 변경**: 앱 내에서 언어 설정 변경
- **계정 관리**: 비밀번호 변경, 로그아웃

## 🛠 기술 스택

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Dart**: SDK 3.10.0 이상
- **주요 패키지**:
  - `google_fonts`: 다양한 폰트 지원
  - `flutter_svg`: SVG 이미지 처리
  - `image_picker`: 사진 선택 및 첨부
  - `flutter_localizations`: 다국어 지원

## 🎨 디자인 시스템

앱 전체에 일관된 디자인 시스템이 적용되어 있습니다:
- **간격 시스템**: xs(4), sm(8), md(12), lg(16), xl(20), xxl(24), xxxl(28)
- **BorderRadius**: sm(12), md(16), lg(20), xl(24), xxl(28), xxxl(32)
- **화면 패딩**: horizontal 20, vertical 16 (표준)
- **카드 패딩**: 20 (표준)
- **그림자 및 카드 스타일**: 통일된 디자인 토큰 사용

## 📦 프로젝트 구조

```
lib/
├── app.dart                    # 앱 진입점 및 라우팅
├── main.dart                   # 메인 함수
├── core/
│   ├── constants/
│   │   ├── app_colors.dart     # 앱 색상 상수
│   │   └── app_spacing.dart    # 디자인 시스템 (간격, 패딩, borderRadius)
│   ├── locale/
│   │   └── app_locale.dart     # 다국어 설정
│   └── theme/
│       └── app_theme.dart      # 앱 테마
├── data/
│   ├── mock/
│   │   └── mock_data.dart      # 목 데이터
│   └── models/
│       ├── bouquet.dart        # 꽃다발 모델
│       ├── friend.dart         # 친구 모델
│       ├── letter.dart         # 편지 모델
│       ├── notification.dart   # 알림 모델
│       └── user.dart           # 사용자 모델
└── presentation/
    ├── screens/
    │   ├── auth/               # 인증 화면
    │   │   ├── login_screen.dart
    │   │   ├── signup_screen.dart
    │   │   ├── forgot_password_screen.dart
    │   │   └── terms_screen.dart
    │   ├── bouquet/            # 꽃다발 화면
    │   │   └── bouquet_screen.dart
    │   ├── common/             # 공통 화면
    │   │   └── letter_detail_screen.dart
    │   ├── main/               # 메인 화면
    │   │   └── main_shell.dart
    │   ├── settings/           # 설정 화면
    │   │   └── settings_screen.dart
    │   ├── sky/                # 하늘 화면
    │   │   └── sky_screen.dart
    │   ├── splash/             # 스플래시 화면
    │   │   └── splash_screen.dart
    │   ├── tutorial/           # 온보딩 화면
    │   │   └── tutorial_screen.dart
    │   └── write/              # 편지 작성 화면
    │       └── write_letter_page.dart
    └── widgets/
        └── taba_notice.dart    # 공지 위젯
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK 3.10.0 이상
- Dart SDK 3.10.0 이상
- Android Studio / Xcode (플랫폼별 개발)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd taba_app
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   flutter run
   ```

### 빌드

#### ⚠️ 중요: 환경 분리

- **Release 빌드**: 프로덕션 서버 (`https://www.taba.asia/api/v1`) 사용
- **개발 빌드**: 개발 서버 (`https://dev.taba.asia/api/v1`) 사용

#### 빠른 빌드 스크립트 (권장)

**프로덕션 빌드 (Release)**
```bash
# Android + iOS 모두 빌드
./scripts/build_release.sh

# Android만 빌드
./scripts/build_release.sh android

# iOS만 빌드
./scripts/build_release.sh ios
```

**개발 빌드**
```bash
# Android + iOS 모두 빌드
./scripts/build_dev.sh

# Android만 빌드
./scripts/build_dev.sh android

# iOS만 빌드
./scripts/build_dev.sh ios
```

#### 수동 빌드

**프로덕션 빌드 (Release)**
```bash
# Android
flutter build appbundle --release --dart-define=API_ENV=prod

# iOS
flutter build ipa --release --dart-define=API_ENV=prod --export-options-plist=ios/ExportOptions-prod.plist
```

**개발 빌드**
```bash
# Android
flutter build apk --release --dart-define=API_ENV=dev

# iOS
flutter build ipa --release --dart-define=API_ENV=dev --export-options-plist=ios/ExportOptions-dev.plist
```

자세한 내용은 [빌드 환경 설정 가이드](./docs/BUILD_ENVIRONMENTS.md)를 참고하세요.

## 🔄 CI/CD

이 프로젝트는 GitHub Actions를 사용한 자동 빌드 및 배포 파이프라인을 지원합니다.

### 브랜치 전략

- **`develop`**: 개발 빌드 → TestFlight (iOS) / Artifact (Android)
- **`release`**: 프로덕션 빌드 → App Store (iOS) / Google Play Production (Android)

### 설정 가이드

- [환경변수 및 인증서 설정 완전 가이드](./docs/ENVIRONMENT_SETUP_GUIDE.md) ⭐ **시작하기** - 모든 환경변수와 인증서 설정
- [빠른 시작 가이드](./docs/QUICK_START.md) - 5분 안에 설정하기
- [상세 설정 가이드](./docs/CI_CD_SETUP.md) - 전체 설정 방법
- [설정 체크리스트](./docs/CI_CD_CHECKLIST.md) - 단계별 확인 사항
- [설정 요약](./docs/CI_CD_SUMMARY.md) - 필요한 환경 변수 및 준비 사항

### 자동화 스크립트

환경변수와 인증서 설정을 자동화하는 스크립트가 제공됩니다:

```bash
# iOS 인증서 및 프로비저닝 프로파일 설정
./scripts/setup_ios_certificates.sh

# GitHub Secrets 설정 (GitHub CLI 사용 시)
./scripts/setup_github_secrets.sh
```

자세한 내용은 [스크립트 가이드](./scripts/README.md)를 참고하세요.

## 📝 앱 정보

- **패키지명**: `com.coby.taba`
- **앱 이름**: Taba
- **버전**: 1.0.0+1

## 🌍 지원 언어

- 한국어 (기본)
- 영어
- 일본어

## 📄 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 👨‍💻 개발자

Coby

---

**떠다니는 씨앗을 잡아 꽃을 피워보세요** 🌸✨
