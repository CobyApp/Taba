# CI/CD 설정 요약

## 📦 생성된 파일

다음 파일들이 생성되었습니다:

- `.github/workflows/develop.yml` - Develop 브랜치용 워크플로우
- `.github/workflows/release.yml` - Release 브랜치용 워크플로우
- `ios/ExportOptions-dev.plist` - iOS Dev 빌드 설정
- `ios/ExportOptions-prod.plist` - iOS Prod 빌드 설정
- `docs/CI_CD_SETUP.md` - 상세 설정 가이드
- `docs/CI_CD_CHECKLIST.md` - 설정 체크리스트
- `docs/QUICK_START.md` - 빠른 시작 가이드

## 🎯 브랜치 전략

- **`develop`** 브랜치에 push → Dev 빌드 → TestFlight (iOS) / Artifact (Android)
- **`release`** 브랜치에 push → Prod 빌드 → App Store (iOS) / Google Play Production (Android)

## 🔑 필요한 GitHub Secrets

### Android (5개)

1. `ANDROID_KEYSTORE_BASE64` - Keystore 파일 (base64 인코딩)
2. `ANDROID_KEYSTORE_PASSWORD` - Keystore 비밀번호
3. `ANDROID_KEY_ALIAS` - 키 별칭 (예: `taba-key`)
4. `ANDROID_KEY_PASSWORD` - 키 비밀번호
5. `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Google Play 서비스 계정 JSON

### iOS (6개)

1. `APP_STORE_CONNECT_API_KEY_ID` - API Key ID (10자리)
2. `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID (UUID)
3. `APP_STORE_CONNECT_API_KEY` - API Key (.p8 파일 내용)
4. `APPLE_CERTIFICATE_BASE64` - Distribution Certificate (.p12, base64)
5. `APPLE_CERTIFICATE_PASSWORD` - Certificate 비밀번호
6. `APPLE_PROVISIONING_PROFILE_BASE64` - Provisioning Profile (base64)

## ✅ 해야 할 일

### 1. Android 설정

- [ ] Keystore 파일 생성
- [ ] Keystore를 base64로 인코딩
- [ ] Google Play Console에서 서비스 계정 생성
- [ ] 서비스 계정 JSON 다운로드
- [ ] 서비스 계정에 앱 관리자 권한 부여

### 2. iOS 설정

- [ ] App Store Connect에서 API Key 생성
- [ ] API Key 다운로드 (.p8 파일)
- [ ] Apple Developer에서 Distribution Certificate 생성
- [ ] App Store Distribution Provisioning Profile 생성
- [ ] Certificate와 Profile을 base64로 인코딩

### 3. GitHub 설정

- [ ] GitHub Secrets에 모든 값 추가 (위의 11개)
- [ ] `develop` 브랜치 생성 및 push
- [ ] `release` 브랜치 생성 및 push

### 4. 테스트

- [ ] `develop` 브랜치에 push하여 빌드 테스트
- [ ] `release` 브랜치에 push하여 배포 테스트

## 📚 상세 가이드

- **빠른 시작**: [QUICK_START.md](./QUICK_START.md)
- **상세 설정**: [CI_CD_SETUP.md](./CI_CD_SETUP.md)
- **체크리스트**: [CI_CD_CHECKLIST.md](./CI_CD_CHECKLIST.md)

## ⚠️ 중요 사항

1. **Keystore, Certificate, API Key 등은 절대 Git에 커밋하지 마세요!**
2. 모든 민감한 정보는 GitHub Secrets에만 저장하세요.
3. `.gitignore`에 이미 필요한 파일들이 추가되어 있습니다.

## 🚀 시작하기

1. [QUICK_START.md](./QUICK_START.md)를 따라 빠르게 설정하거나
2. [CI_CD_SETUP.md](./CI_CD_SETUP.md)를 참고하여 상세하게 설정하세요.

