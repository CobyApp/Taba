# 빌드 환경 설정 가이드

## 환경 분리

앱은 개발 환경과 프로덕션 환경을 자동으로 구분합니다.

### 자동 환경 감지

- **Debug 모드** (`flutter run`): 자동으로 **개발 환경** (`https://dev.taba.asia/api/v1`) 사용
- **Release 모드** (`flutter run --release`, `flutter build`): 자동으로 **프로덕션 환경** (`https://www.taba.asia/api/v1`) 사용

### 수동 환경 지정

`--dart-define` 플래그를 사용하여 환경을 명시적으로 지정할 수 있습니다:

#### 개발 환경으로 실행
```bash
flutter run --dart-define=API_ENV=dev
```

#### 프로덕션 환경으로 실행 (Debug 모드에서도)
```bash
flutter run --dart-define=API_ENV=prod
```

#### 빌드 시 환경 지정
```bash
# 개발 환경으로 빌드
flutter build apk --dart-define=API_ENV=dev

# 프로덕션 환경으로 빌드 (기본값)
flutter build apk --dart-define=API_ENV=prod
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

## 주의사항

1. **기본 동작**: Debug 모드는 개발 환경, Release 모드는 프로덕션 환경을 사용합니다.
2. **명시적 지정**: `--dart-define=API_ENV`로 환경을 지정하면 빌드 모드와 관계없이 지정한 환경을 사용합니다.
3. **프로덕션 빌드**: App Store나 Play Store에 배포할 때는 반드시 프로덕션 환경을 사용해야 합니다.

