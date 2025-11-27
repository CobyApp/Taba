# CI/CD 설정 가이드

## 브랜치 전략

- **`develop`**: 개발 빌드 → TestFlight (iOS) / Artifact (Android)
- **`release`**: 프로덕션 빌드 → App Store (iOS) / Google Play Production (Android)

## 필요한 GitHub Secrets

### Android (5개)
- `ANDROID_KEYSTORE_BASE64` - Keystore 파일 (base64)
- `ANDROID_KEYSTORE_PASSWORD` - Keystore 비밀번호
- `ANDROID_KEY_ALIAS` - 키 별칭
- `ANDROID_KEY_PASSWORD` - 키 비밀번호
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Google Play 서비스 계정 JSON

### iOS (6개)
- `APP_STORE_CONNECT_API_KEY_ID` - API Key ID
- `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID
- `APP_STORE_CONNECT_API_KEY` - API Key (.p8 파일 내용)
- `APPLE_CERTIFICATE_BASE64` - Distribution Certificate (.p12, base64)
- `APPLE_CERTIFICATE_PASSWORD` - Certificate 비밀번호
- `APPLE_PROVISIONING_PROFILE_BASE64` - Provisioning Profile (base64)

## 설정 방법

### Android

1. **Keystore 생성**:
```bash
keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
     -alias taba-key
   ```

2. **Base64 인코딩**:
   ```bash
   base64 -i android/app/keystore.jks | pbcopy
   ```

3. **Google Play 서비스 계정**:
   - [Google Play Console](https://play.google.com/console) → 설정 → API 액세스
   - 서비스 계정 생성 → JSON 다운로드

### iOS

1. **App Store Connect API Key**:
   - [App Store Connect](https://appstoreconnect.apple.com) → 사용자 및 액세스 → 키
   - 키 생성 → `.p8` 파일 다운로드

2. **인증서 및 프로파일**:
   - [Apple Developer Portal](https://developer.apple.com/account)
   - Distribution Certificate 생성 → `.p12`로 내보내기
   - App Store Provisioning Profile 생성 → `.mobileprovision` 다운로드

3. **Base64 인코딩**:
```bash
base64 -i certificate.p12 | pbcopy
base64 -i profile.mobileprovision | pbcopy
```

## 워크플로우 동작

- **develop 브랜치**: 개발 서버 (`dev.taba.asia`) 연결
- **release 브랜치**: 프로덕션 서버 (`www.taba.asia`) 연결

## 보안 주의사항

⚠️ 다음 파일들은 절대 Git에 커밋하지 마세요:
- `keystore.jks`
- `*.p12`, `*.mobileprovision`
- Service Account JSON
- API Key `.p8`

모든 민감한 정보는 GitHub Secrets에 저장하세요.

## 상세 가이드

- [Google Play 설정](./GOOGLE_PLAY_SETUP.md)
- [App Store Connect 설정](./APP_STORE_CONNECT_GUIDE.md)
- [iOS 인증서 설정](./IOS_CERTIFICATE_SETUP.md)
- [빌드 환경 설정](./BUILD_ENVIRONMENTS.md)
