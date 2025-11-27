# 빌드 환경 설정 가이드

## 환경 분리

앱은 개발 환경과 프로덕션 환경을 명확하게 분리합니다.

### ⚠️ 중요: 환경 분리 규칙

- **Release 빌드**: 항상 **프로덕션 서버** (`https://www.taba.asia/api/v1`) 사용
- **Debug/Profile 빌드**: 항상 **개발 서버** (`https://dev.taba.asia/api/v1`) 사용
- **CI/CD 빌드**: 
  - `release` 브랜치 → 프로덕션 서버
  - `develop` 브랜치 → 개발 서버

### 빠른 빌드 스크립트 (권장)

#### 프로덕션 빌드 (Release)
```bash
# Android + iOS 모두 빌드
./scripts/build_release.sh

# Android만 빌드
./scripts/build_release.sh android

# iOS만 빌드
./scripts/build_release.sh ios
```

#### 개발 빌드
```bash
# Android + iOS 모두 빌드
./scripts/build_dev.sh

# Android만 빌드
./scripts/build_dev.sh android

# iOS만 빌드
./scripts/build_dev.sh ios
```

### 수동 빌드 방법

#### 프로덕션 빌드 (Release)
```bash
# Android
flutter build appbundle --release --dart-define=API_ENV=prod

# iOS
flutter build ipa --release --dart-define=API_ENV=prod --export-options-plist=ios/ExportOptions-prod.plist
```

#### 개발 빌드
```bash
# Android
flutter build apk --release --dart-define=API_ENV=dev

# iOS
flutter build ipa --release --dart-define=API_ENV=dev --export-options-plist=ios/ExportOptions-dev.plist
```

#### 개발 실행 (Debug 모드)
```bash
# 개발 서버로 실행
flutter run

# 또는 명시적으로 지정
flutter run --dart-define=API_ENV=dev
```

## 환경별 API Base URL

| 환경 | Base URL |
|------|----------|
| 개발 (Development) | `https://dev.taba.asia/api/v1` |
| 프로덕션 (Production) | `https://www.taba.asia/api/v1` |

## 환경 확인

앱 실행 시 콘솔에 현재 환경 정보가 출력됩니다:

```
🌍 API Environment: Development
🔗 API Base URL: https://dev.taba.asia/api/v1
```

또는

```
🌍 API Environment: Production
🔗 API Base URL: https://www.taba.asia/api/v1
```

## 설정 파일 위치

환경 설정은 `lib/core/config/api_config.dart` 파일에서 관리됩니다.

## 환경 감지 우선순위

1. **`--dart-define=API_ENV`**: 명시적으로 지정한 경우 최우선 사용
2. **빌드 모드**: 
   - `kReleaseMode` (Release 빌드) → 프로덕션 서버
   - `kDebugMode` 또는 `kProfileMode` → 개발 서버

## CI/CD 환경 분리

### GitHub Actions

- **`release` 브랜치** (`release.yml`):
  - Android: `--dart-define=API_ENV=prod` → 프로덕션 서버
  - iOS: `--dart-define=API_ENV=prod` → 프로덕션 서버

- **`develop` 브랜치** (`develop.yml`):
  - Android: `--dart-define=API_ENV=dev` → 개발 서버
  - iOS: `--dart-define=API_ENV=dev` → 개발 서버

## 주의사항

1. **Release 빌드는 항상 프로덕션 서버 사용**: `kReleaseMode`일 때는 `--dart-define`이 없어도 프로덕션 서버를 사용합니다.
2. **명시적 지정 우선**: `--dart-define=API_ENV`로 환경을 지정하면 빌드 모드와 관계없이 지정한 환경을 사용합니다.
3. **프로덕션 배포**: App Store나 Play Store에 배포할 때는 반드시 프로덕션 환경을 사용해야 합니다.
4. **로컬 테스트**: 로컬에서 Release 빌드를 테스트할 때도 프로덕션 서버에 연결됩니다. 개발 서버로 테스트하려면 Debug 모드를 사용하세요.

