# CI/CD 설정 체크리스트

이 문서는 CI/CD 파이프라인을 설정하기 위해 필요한 모든 단계를 체크리스트 형태로 정리했습니다.

## 📋 사전 준비 사항

### Android

- [ ] Google Play Console 계정 생성 및 앱 등록
- [ ] Keystore 파일 생성 (`android/app/keystore.jks`)
- [ ] Google Play 서비스 계정 생성 및 JSON 키 다운로드
- [ ] 서비스 계정에 앱 관리자 권한 부여

### iOS

- [ ] Apple Developer 계정 활성화
- [ ] App Store Connect에서 앱 등록
- [ ] App Store Connect API Key 생성
- [ ] Distribution Certificate 생성
- [ ] App Store Distribution Provisioning Profile 생성

## 🔐 GitHub Secrets 설정

GitHub 저장소 → Settings → Secrets and variables → Actions

### Android Secrets

- [ ] `ANDROID_KEYSTORE_BASE64` - Keystore 파일 (base64 인코딩)
- [ ] `ANDROID_KEYSTORE_PASSWORD` - Keystore 비밀번호
- [ ] `ANDROID_KEY_ALIAS` - 키 별칭 (예: `taba-key`)
- [ ] `ANDROID_KEY_PASSWORD` - 키 비밀번호
- [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - 서비스 계정 JSON (전체 내용)

### iOS Secrets

- [ ] `APP_STORE_CONNECT_API_KEY_ID` - API Key ID (10자리)
- [ ] `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID (UUID 형식)
- [ ] `APP_STORE_CONNECT_API_KEY` - API Key (.p8 파일 내용)
- [ ] `APPLE_CERTIFICATE_BASE64` - Distribution Certificate (.p12, base64)
- [ ] `APPLE_CERTIFICATE_PASSWORD` - Certificate 비밀번호
- [ ] `APPLE_PROVISIONING_PROFILE_BASE64` - Provisioning Profile (base64)

## 📝 파일 생성 및 설정

### Android

- [ ] `android/app/build.gradle.kts` - Signing config 확인
- [ ] Keystore 파일이 `.gitignore`에 포함되어 있는지 확인

### iOS

- [ ] `ios/ExportOptions-dev.plist` 생성 확인
- [ ] `ios/ExportOptions-prod.plist` 생성 확인
- [ ] Certificate 및 Provisioning Profile이 `.gitignore`에 포함되어 있는지 확인

## 🌿 브랜치 생성

- [ ] `develop` 브랜치 생성
- [ ] `release` 브랜치 생성

## ✅ 테스트

### Develop 브랜치 테스트

- [ ] `develop` 브랜치에 push
- [ ] GitHub Actions 워크플로우 실행 확인
- [ ] Android APK 빌드 성공 확인
- [ ] iOS IPA 빌드 성공 확인
- [ ] TestFlight 업로드 확인 (iOS)

### Release 브랜치 테스트

- [ ] `release` 브랜치에 push
- [ ] GitHub Actions 워크플로우 실행 확인
- [ ] Android AAB 빌드 성공 확인
- [ ] iOS IPA 빌드 성공 확인
- [ ] Google Play Production 업로드 확인
- [ ] App Store Connect 업로드 확인

## 🔧 문제 해결

### 일반적인 문제

- [ ] Keystore 비밀번호가 정확한지 확인
- [ ] API Key 권한이 올바른지 확인
- [ ] Certificate가 만료되지 않았는지 확인
- [ ] Provisioning Profile이 유효한지 확인

### 로그 확인

- [ ] GitHub Actions 로그에서 에러 메시지 확인
- [ ] 빌드 단계별 성공/실패 확인
- [ ] 업로드 단계 에러 확인

## 📚 참고 문서

- [CI/CD 설정 가이드](./CI_CD_SETUP.md)
- [Flutter 공식 문서](https://docs.flutter.dev/deployment)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)

