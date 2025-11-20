# CI/CD 빠른 시작 가이드

이 문서는 CI/CD 파이프라인을 빠르게 설정하는 방법을 설명합니다.

## 🚀 빠른 설정 (5분)

### 1단계: Keystore 생성 (Android)

```bash
cd android/app
keytool -genkey -v -keystore keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias taba-key \
  -storepass <원하는_비밀번호> \
  -keypass <원하는_비밀번호>
```

**중요**: 생성된 비밀번호를 안전하게 보관하세요!

### 2단계: Keystore를 Base64로 인코딩

```bash
# macOS
base64 -i android/app/keystore.jks | pbcopy

# Linux
base64 -i android/app/keystore.jks

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/keystore.jks"))
```

### 3단계: Google Play 서비스 계정 설정

1. [Google Play Console](https://play.google.com/console) 접속
2. **설정** → **API 액세스** → **서비스 계정** 생성
3. JSON 키 파일 다운로드
4. 서비스 계정에 **앱 관리자** 권한 부여

### 4단계: App Store Connect API Key 생성

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. **사용자 및 액세스** → **키** → **+** 버튼
3. 키 이름 입력 (예: "CI/CD Key")
4. **App Manager** 권한 선택
5. 키 다운로드 (`.p8` 파일) - **한 번만 다운로드 가능!**

### 5단계: iOS 인증서 및 프로파일 준비

1. [Apple Developer Portal](https://developer.apple.com) 접속
2. **Certificates, Identifiers & Profiles** → **Certificates**
3. **+** 버튼 → **Apple Distribution** 선택
4. 인증서 다운로드 및 `.p12`로 변환
5. **Profiles** → **+** 버튼 → **App Store** 선택
6. 프로파일 다운로드

### 6단계: GitHub Secrets 설정

GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

#### 필수 Secrets (Android)

| 이름 | 값 |
|------|-----|
| `ANDROID_KEYSTORE_BASE64` | 2단계에서 복사한 base64 문자열 |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 비밀번호 |
| `ANDROID_KEY_ALIAS` | `taba-key` |
| `ANDROID_KEY_PASSWORD` | 키 비밀번호 |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | 3단계에서 다운로드한 JSON 파일 전체 내용 |

#### 필수 Secrets (iOS)

| 이름 | 값 |
|------|-----|
| `APP_STORE_CONNECT_API_KEY_ID` | 4단계에서 생성한 Key ID (10자리) |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect → 사용자 및 액세스 → Issuer ID |
| `APP_STORE_CONNECT_API_KEY` | 4단계에서 다운로드한 `.p8` 파일 내용 |
| `APPLE_CERTIFICATE_BASE64` | 5단계 인증서를 base64 인코딩 |
| `APPLE_CERTIFICATE_PASSWORD` | 인증서 비밀번호 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | 5단계 프로파일을 base64 인코딩 |

### 7단계: 브랜치 생성

```bash
git checkout -b develop
git push -u origin develop

git checkout -b release
git push -u origin release
```

## ✅ 테스트

### Develop 브랜치 테스트

```bash
git checkout develop
# 코드 변경 후
git push origin develop
```

GitHub Actions에서 자동으로 빌드가 시작됩니다.

### Release 브랜치 테스트

```bash
git checkout release
# 코드 변경 후
git push origin release
```

프로덕션 빌드가 시작되고 자동으로 스토어에 업로드됩니다.

## 📝 다음 단계

- [상세 설정 가이드](./CI_CD_SETUP.md) 확인
- [체크리스트](./CI_CD_CHECKLIST.md)로 모든 설정 확인

## ⚠️ 주의사항

1. **Keystore 파일은 절대 Git에 커밋하지 마세요!**
2. **API Key와 인증서는 안전하게 보관하세요!**
3. **모든 민감한 정보는 GitHub Secrets에만 저장하세요!**

## 🆘 문제가 발생했나요?

- [체크리스트](./CI_CD_CHECKLIST.md)의 문제 해결 섹션 확인
- GitHub Actions 로그에서 에러 메시지 확인
- [상세 설정 가이드](./CI_CD_SETUP.md)의 문제 해결 섹션 참고

