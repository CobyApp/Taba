# 환경변수 및 인증서 설정 완전 가이드

이 문서는 CI/CD를 위한 모든 환경변수와 인증서를 설정하는 상세한 가이드를 제공합니다.

## 🚀 빠른 시작

### 자동화 스크립트 사용 (권장)

```bash
# iOS 인증서 및 프로비저닝 프로파일 설정
./scripts/setup_ios_certificates.sh

# GitHub Secrets 설정 (GitHub CLI 사용 시)
./scripts/setup_github_secrets.sh
```

## 📋 필요한 항목 체크리스트

### Android (5개)
- [ ] Keystore 파일 생성
- [ ] Keystore Base64 인코딩
- [ ] Google Play 서비스 계정 생성
- [ ] 서비스 계정 JSON 다운로드
- [ ] GitHub Secrets 설정

### iOS (6개)
- [ ] App Store Connect API Key 생성
- [ ] Distribution Certificate 생성
- [ ] Provisioning Profile 생성
- [ ] Certificate Base64 인코딩
- [ ] Profile Base64 인코딩
- [ ] GitHub Secrets 설정

## 🔐 1. Android 설정

### 1.1 Keystore 생성

```bash
cd android/app
keytool -genkey -v -keystore keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias taba-key \
  -storepass <KEYSTORE_PASSWORD> \
  -keypass <KEY_PASSWORD>
```

**중요 정보 기록:**
- Keystore 비밀번호: `_________________`
- 키 별칭: `taba-key`
- 키 비밀번호: `_________________`

### 1.2 Keystore Base64 인코딩

```bash
# macOS
base64 -i android/app/keystore.jks | pbcopy

# Linux
base64 -i android/app/keystore.jks

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/keystore.jks"))
```

**결과를 복사하여 GitHub Secret `ANDROID_KEYSTORE_BASE64`에 저장**

### 1.3 Google Play 서비스 계정 생성

1. [Google Play Console](https://play.google.com/console) 접속
2. **설정** → **API 액세스** (또는 직접 URL: `https://play.google.com/console/u/0/developers/[YOUR_DEVELOPER_ID]/api-access`)
3. **서비스 계정 만들기** 클릭
4. Google Cloud Console에서:
   - 프로젝트 선택
   - 서비스 계정 이름 입력 (예: "Taba CI/CD")
   - **키** 탭 → **새 키 만들기** → **JSON** 선택 → 다운로드
5. Google Play Console로 돌아가서:
   - **권한 부여** 클릭
   - 앱 선택 → **앱 관리자** 권한 부여

**다운로드한 JSON 파일 내용을 GitHub Secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`에 저장**

## 🍎 2. iOS 설정

### 2.1 App Store Connect API Key 생성

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 우측 상단 **프로필 아이콘** 클릭 → **사용자 및 액세스**
3. 왼쪽 사이드바 **키** 클릭
4. **+** 버튼 클릭
5. 키 이름 입력 (예: "CI/CD Key")
6. **액세스** → **App Manager** 또는 **Admin** 선택
7. **생성** 클릭
8. **키 ID**와 **Issuer ID** 복사
   - 키 ID: `_________________` (10자리)
   - Issuer ID: `_________________` (UUID)
9. **다운로드** 버튼 클릭하여 `.p8` 파일 다운로드
   - ⚠️ **한 번만 다운로드 가능!** 안전하게 보관

**GitHub Secrets 설정:**
- `APP_STORE_CONNECT_API_KEY_ID`: 키 ID
- `APP_STORE_CONNECT_ISSUER_ID`: Issuer ID
- `APP_STORE_CONNECT_API_KEY`: `.p8` 파일 전체 내용

### 2.2 Distribution Certificate 생성

#### 방법 1: Xcode 사용 (가장 쉬움)

1. **Xcode** 열기
2. **Xcode** → **Settings** → **Accounts** 탭
3. Apple ID 선택 → **Manage Certificates...** 클릭
4. **+** 버튼 → **Apple Distribution** 선택
5. Xcode가 자동으로 인증서 생성 및 다운로드 ✅

#### 방법 2: Keychain Access 사용

1. **Keychain Access** 앱 열기
2. **Keychain Access** → **인증서 지원** → **인증 기관에 인증서 요청...**
3. 정보 입력:
   - 사용자 이메일: Apple Developer 계정 이메일
   - 일반 이름: 이름 또는 회사명
   - 요청 대상: **디스크에 저장됨** 선택
4. **계속** → 파일 저장
5. [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list) 접속
6. **Certificates** → **+** → **Apple Distribution** 선택
7. CSR 파일 업로드 → **Continue** → **Download**
8. 다운로드한 `.cer` 파일 더블클릭하여 Keychain에 추가

### 2.3 Certificate를 .p12로 내보내기

1. **Keychain Access** 앱 열기
2. 왼쪽 사이드바: **로그인** → **인증서**
3. **Apple Distribution: [이름]** 인증서 찾기
4. 우클릭 → **내보내기 "Apple Distribution..."**
5. 파일 형식: **Personal Information Exchange (.p12)**
6. 비밀번호 설정 (기억하세요!)
   - 비밀번호: `_________________`

### 2.4 App ID 생성 (필요한 경우)

1. [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) 접속
2. **Identifiers** → **+** 버튼
3. **App IDs** → **App** 선택
4. 정보 입력:
   - Description: "Taba App"
   - Bundle ID: **Explicit** → `com.coby.taba`
   - Capabilities: 필요한 기능 선택 (Push Notifications 등)
5. **Continue** → **Register**

### 2.5 Provisioning Profile 생성

1. [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list) 접속
2. **Profiles** → **+** 버튼
3. **App Store** 선택 → **Continue**
4. App ID 선택 (위에서 생성한 것)
5. Certificate 선택 (위에서 생성한 Distribution Certificate)
6. 프로파일 이름 입력 (예: "Taba App Store Distribution")
7. **Generate** → **Download**

### 2.6 Base64 인코딩

#### 자동화 스크립트 사용 (권장)

```bash
./scripts/setup_ios_certificates.sh
```

스크립트가 자동으로:
- 인증서 확인
- .p12 파일 인코딩
- Provisioning Profile 인코딩
- 클립보드에 복사

#### 수동 인코딩

```bash
# Certificate
base64 -i distribution.p12 | pbcopy

# Provisioning Profile
base64 -i profile.mobileprovision | pbcopy
```

**GitHub Secrets 설정:**
- `APPLE_CERTIFICATE_BASE64`: Certificate Base64 값
- `APPLE_CERTIFICATE_PASSWORD`: .p12 비밀번호
- `APPLE_PROVISIONING_PROFILE_BASE64`: Profile Base64 값

## 🔑 3. GitHub Secrets 설정

### 3.1 웹 인터페이스 사용

1. GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** 클릭
3. 다음 11개 Secret 추가:

#### Android Secrets (5개)

| Secret 이름 | 값 |
|------------|-----|
| `ANDROID_KEYSTORE_BASE64` | Keystore Base64 인코딩 값 |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 비밀번호 |
| `ANDROID_KEY_ALIAS` | `taba-key` |
| `ANDROID_KEY_PASSWORD` | 키 비밀번호 |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | 서비스 계정 JSON 전체 내용 |

#### iOS Secrets (6개)

| Secret 이름 | 값 |
|------------|-----|
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID (10자리) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (UUID) |
| `APP_STORE_CONNECT_API_KEY` | .p8 파일 전체 내용 |
| `APPLE_CERTIFICATE_BASE64` | Certificate Base64 값 |
| `APPLE_CERTIFICATE_PASSWORD` | .p12 비밀번호 |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Profile Base64 값 |

### 3.2 GitHub CLI 사용

```bash
# GitHub CLI 설치 (없는 경우)
brew install gh

# 로그인
gh auth login

# Secrets 설정
gh secret set ANDROID_KEYSTORE_BASE64 --body "$(base64 -i android/app/keystore.jks)"
gh secret set ANDROID_KEYSTORE_PASSWORD --body "your-password"
# ... 나머지도 동일하게
```

또는 자동화 스크립트 사용:

```bash
./scripts/setup_github_secrets.sh
```

## ✅ 4. 검증

### 4.1 Secrets 확인

GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**에서 모든 Secret이 설정되었는지 확인

### 4.2 테스트 빌드

```bash
# develop 브랜치에 push하여 테스트
git checkout develop
git push origin develop
```

GitHub Actions에서 빌드가 성공하는지 확인

## 🆘 문제 해결

### Certificate 비밀번호 오류

```
MAC verification failed during PKCS12 import (wrong password?)
```

**해결:**
1. .p12 파일 내보낼 때 설정한 비밀번호 확인
2. GitHub Secret `APPLE_CERTIFICATE_PASSWORD`가 정확한지 확인
3. 대소문자, 특수문자 정확히 입력
4. 필요시 새로 내보내기

### Provisioning Profile 오류

```
Failed to Use Accounts
```

**해결:**
1. ExportOptions plist에 `provisioningProfiles` 딕셔너리 확인
2. Bundle ID가 일치하는지 확인
3. Profile이 만료되지 않았는지 확인
4. Certificate와 Profile이 매칭되는지 확인

### Keystore 오류

```
Keystore was tampered with, or password was incorrect
```

**해결:**
1. Keystore 비밀번호 확인
2. Base64 인코딩이 올바른지 확인
3. 키 별칭이 정확한지 확인

## 📝 체크리스트

모든 설정이 완료되었는지 확인:

### Android
- [ ] Keystore 파일 생성 완료
- [ ] `ANDROID_KEYSTORE_BASE64` 설정
- [ ] `ANDROID_KEYSTORE_PASSWORD` 설정
- [ ] `ANDROID_KEY_ALIAS` 설정
- [ ] `ANDROID_KEY_PASSWORD` 설정
- [ ] Google Play 서비스 계정 생성
- [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` 설정

### iOS
- [ ] App Store Connect API Key 생성
- [ ] `APP_STORE_CONNECT_API_KEY_ID` 설정
- [ ] `APP_STORE_CONNECT_ISSUER_ID` 설정
- [ ] `APP_STORE_CONNECT_API_KEY` 설정
- [ ] Distribution Certificate 생성
- [ ] Certificate를 .p12로 내보내기
- [ ] `APPLE_CERTIFICATE_BASE64` 설정
- [ ] `APPLE_CERTIFICATE_PASSWORD` 설정
- [ ] Provisioning Profile 생성
- [ ] `APPLE_PROVISIONING_PROFILE_BASE64` 설정

### 테스트
- [ ] develop 브랜치에 push하여 빌드 테스트
- [ ] 빌드 성공 확인
- [ ] iOS IPA 생성 확인
- [ ] Android APK/AAB 생성 확인

## 💡 팁

1. **비밀번호 관리**: 모든 비밀번호를 안전하게 보관하세요 (1Password, LastPass 등)
2. **백업**: 인증서와 프로파일을 안전한 곳에 백업하세요
3. **만료 확인**: 인증서와 프로파일은 만료되므로 정기적으로 확인하세요
4. **자동화 스크립트**: `./scripts/setup_ios_certificates.sh`를 사용하면 실수를 줄일 수 있습니다

## 📚 관련 문서

- [CI/CD 설정 가이드](./CI_CD_SETUP.md)
- [iOS 인증서 설정 가이드](./IOS_CERTIFICATE_SETUP.md)
- [App Store Connect 가이드](./APP_STORE_CONNECT_GUIDE.md)
- [Google Play 설정 가이드](./GOOGLE_PLAY_SETUP.md)

