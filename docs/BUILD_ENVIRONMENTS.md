# 빌드 환경 설정

## 환경 분리

- **Release 빌드**: 프로덕션 서버 (`https://www.taba.asia/api/v1`)
- **Debug/Profile 빌드**: 개발 서버 (`https://dev.taba.asia/api/v1`)

## 빠른 빌드

### 프로덕션 빌드
```bash
./scripts/build_release.sh          # Android + iOS
./scripts/build_release.sh android  # Android만
./scripts/build_release.sh ios      # iOS만
```

### 개발 빌드
```bash
./scripts/build_dev.sh              # Android + iOS
./scripts/build_dev.sh android      # Android만
./scripts/build_dev.sh ios          # iOS만
```

## 수동 빌드

### 프로덕션
```bash
# Android
flutter build appbundle --release --dart-define=API_ENV=prod

# iOS
flutter build ipa --release --dart-define=API_ENV=prod --export-options-plist=ios/ExportOptions-prod.plist
```

### 개발
```bash
# Android
flutter build apk --release --dart-define=API_ENV=dev

# iOS
flutter build ipa --release --dart-define=API_ENV=dev --export-options-plist=ios/ExportOptions-dev.plist
```

## 환경 확인

앱 실행 시 콘솔에 환경 정보가 출력됩니다:
```
🌍 API Environment: Development
🔗 API Base URL: https://dev.taba.asia/api/v1
```

## CI/CD 환경 분리

- **`release` 브랜치**: `--dart-define=API_ENV=prod` → 프로덕션 서버
- **`develop` 브랜치**: `--dart-define=API_ENV=dev` → 개발 서버

## 주의사항

1. Release 빌드는 항상 프로덕션 서버 사용
2. `--dart-define=API_ENV`로 명시적 지정 가능
3. 프로덕션 배포 시 반드시 프로덕션 환경 사용
