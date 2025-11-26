# CI/CD 설정 가이드

이 문서는 GitHub Actions를 사용한 자동 빌드 및 배포 파이프라인 설정 방법을 설명합니다.

## 📦 생성된 파일

- `.github/workflows/develop.yml` - Develop 브랜치용 워크플로우
- `.github/workflows/release.yml` - Release 브랜치용 워크플로우
- `ios/ExportOptions-dev.plist` - iOS Dev 빌드 설정
- `ios/ExportOptions-prod.plist` - iOS Prod 빌드 설정

## 🎯 브랜치 전략

- **`develop`**: 개발 빌드 → TestFlight (iOS) / Internal Testing (Android)
- **`release`**: 프로덕션 빌드 → App Store (iOS) / Production (Android)

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

## 필요한 준비 사항

### 1. Android 설정

#### 1.1 Keystore 생성

```bash
keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias taba-key \
  -storepass <KEYSTORE_PASSWORD> \
  -keypass <KEY_PASSWORD>
```

**중요**: `keystore.jks` 파일은 절대 Git에 커밋하지 마세요!

#### 1.2 Android Signing 설정

`android/app/build.gradle.kts` 파일에 signing config 추가:

```kotlin
android {
    // ... 기존 설정 ...

    signingConfigs {
        create("release") {
            storeFile = file("../keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

#### 1.3 Google Play Console 설정

**⚠️ 중요**: Google Play Console의 API 액세스 서비스가 중단된 경우:
- [대안 방법: Google Cloud Console에서 직접 생성](./GOOGLE_PLAY_ALTERNATIVE.md) 참고

**⚠️ 사전 확인**: 앱이 등록되지 않았다면 먼저 앱을 등록해야 합니다!
- [앱 등록 가이드](./GOOGLE_PLAY_APP_REGISTRATION.md) 참고
- 앱 등록은 간단하며, 실제 배포할 필요는 없습니다

**⚠️ 빠른 접근**: 
1. **직접 URL 입력** (개발자 ID 포함):
   ```
   https://play.google.com/console/u/0/developers/8677267942546809805/api-access
   ```
   - 현재 URL의 개발자 ID를 사용하여 접근
2. **또는 현재 URL 수정**: 
   - 현재 URL에서 `/users-and-permissions/...` 부분을 `/api-access`로 변경

**단계별 방법**:

1. [Google Play Console](https://play.google.com/console)에 로그인
2. **방법 1 (직접 URL)**: 브라우저 주소창에 위 URL 입력
3. **방법 2 (메뉴에서)**:
   - 왼쪽 사이드바에서 **설정** (Settings) 클릭
   - 설정 페이지 **상단 탭 메뉴**에서 **API 액세스** 찾기
   - 또는 **사용자 및 권한** 메뉴에서 찾기
4. **서비스 계정 만들기** 또는 **CREATE SERVICE ACCOUNT** 버튼 클릭
   - ⚠️ **중요**: 이 버튼을 클릭하면 자동으로 Google Cloud Console로 이동합니다
   - Google Cloud Platform에 별도로 접속할 필요 없습니다!
5. Google Cloud Console에서:
   - 프로젝트 선택 (자동으로 연결된 프로젝트 사용 또는 기존 프로젝트 선택)
   - 서비스 계정 이름 입력 (예: "Taba CI/CD")
   - 서비스 계정 생성
   - **키** 탭에서 **새 키 만들기** → **JSON** 형식 선택 → 다운로드
6. Google Play Console로 돌아가서 **권한 부여** 클릭
7. 앱 선택 후 **앱 관리자** 권한 부여

**참고**: [FAQ](./GOOGLE_PLAY_FAQ.md) - Google Cloud Platform 관련 질문

**상세 가이드**: 
- [Google Play Console 서비스 계정 설정 가이드](./GOOGLE_PLAY_SETUP.md)
- [대안 방법: Google Cloud Console에서 직접 생성](./GOOGLE_PLAY_ALTERNATIVE.md) - API 액세스 서비스 중단 시
- [문제 해결 가이드](./GOOGLE_PLAY_TROUBLESHOOTING.md) - API 액세스 페이지 접근이 안 되는 경우

### 2. iOS 설정

#### 2.1 App Store Connect API Key 생성

1. [App Store Connect](https://appstoreconnect.apple.com)에 로그인
2. **우측 상단의 사용자 아이콘(프로필 아이콘)** 클릭
3. 드롭다운 메뉴에서 **사용자 및 액세스** 선택
   - 또는 상단 메뉴에서 **사용자 및 액세스** 직접 클릭
4. 왼쪽 사이드바에서 **키** 메뉴 클릭
   - 메뉴 경로: **사용자 및 액세스** → **키**
   - ⚠️ **참고**: Admin 또는 App Manager 권한이 있어야 키 메뉴가 보입니다
5. 우측 상단의 **+** 버튼 또는 **생성** 버튼 클릭
6. 키 이름 입력 (예: "CI/CD Key" 또는 "GitHub Actions")
7. **액세스** 드롭다운에서 **App Manager** 또는 **Admin** 선택
8. **생성** 버튼 클릭
9. **키 ID**와 **Issuer ID**를 복사하여 안전하게 보관
   - 키 ID: 10자리 영문+숫자 (예: `ABC123DEF4`)
   - Issuer ID: 페이지 상단에 표시되는 UUID 형식 (예: `12345678-1234-1234-1234-123456789012`)
10. **다운로드** 버튼 클릭하여 `.p8` 파일 다운로드
    - ⚠️ **경고**: 이 파일은 **한 번만 다운로드 가능**합니다! 안전하게 보관하세요.

**상세 가이드**: [App Store Connect API Key 생성 가이드](./APP_STORE_CONNECT_GUIDE.md) 참고

#### 2.2 인증서 및 프로비저닝 프로파일

1. [Apple Developer Portal](https://developer.apple.com/account)에 로그인
2. 왼쪽 사이드바에서 **Certificates, Identifiers & Profiles** 클릭
   - 또는 직접 URL: https://developer.apple.com/account/resources/certificates/list
3. **Certificates (인증서)** 섹션:
   - **+** 버튼 클릭
   - **Apple Distribution** 선택 → **Continue**
   - **CSR 파일 생성** (두 가지 방법):
     - **방법 1**: Keychain Access → 인증서 지원 → 인증 기관에 인증서 요청
     - **방법 2**: Xcode → Settings → Accounts → Manage Certificates (더 쉬움)
   - CSR 파일 업로드 (방법 1 사용 시) 또는 Xcode 자동 생성 (방법 2)
   - 인증서 다운로드 후 더블클릭하여 Keychain에 추가
   - Keychain Access에서 인증서를 `.p12` 형식으로 내보내기 (비밀번호 설정)

**상세 가이드**: [iOS 인증서 및 프로비저닝 프로파일 생성 가이드](./IOS_CERTIFICATE_SETUP.md) 참고
4. **Profiles (프로비저닝 프로파일)** 섹션:
   - **+** 버튼 클릭
   - **App Store** 선택 → **Continue**
   - 앱 선택 (App ID)
   - 위에서 생성한 Distribution Certificate 선택
   - 프로파일 이름 입력 (예: "Taba App Store Distribution")
   - **Generate** 클릭
   - 프로파일 다운로드 (`.mobileprovision` 파일)

#### 2.3 ExportOptions 파일 생성

`ios/ExportOptions-dev.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

`ios/ExportOptions-prod.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

### 3. GitHub Secrets 설정

GitHub 저장소의 **Settings** → **Secrets and variables** → **Actions**에서 다음 secrets를 추가하세요:

#### Android Secrets

| Secret 이름 | 설명 | 예시 |
|------------|------|------|
| `ANDROID_KEYSTORE_BASE64` | Keystore 파일을 base64로 인코딩한 값 | `base64 -i keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 비밀번호 | `your-keystore-password` |
| `ANDROID_KEY_ALIAS` | 키 별칭 | `taba-key` |
| `ANDROID_KEY_PASSWORD` | 키 비밀번호 | `your-key-password` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play 서비스 계정 JSON (전체 내용) | `{"type":"service_account",...}` |

#### iOS Secrets

| Secret 이름 | 설명 | 예시 |
|------------|------|------|
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | `ABC123DEF4` |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID | `12345678-1234-1234-1234-123456789012` |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect API Key (.p8 파일 내용) | `-----BEGIN PRIVATE KEY-----...` |
| `APPLE_CERTIFICATE_BASE64` | Distribution Certificate (.p12)를 base64로 인코딩 | `base64 -i certificate.p12` |
| `APPLE_CERTIFICATE_PASSWORD` | Certificate 비밀번호 | `your-certificate-password` |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Provisioning Profile을 base64로 인코딩 | `base64 -i profile.mobileprovision` |

### 4. Keystore Base64 인코딩 방법

```bash
# macOS/Linux
base64 -i android/app/keystore.jks | pbcopy  # macOS
base64 -i android/app/keystore.jks            # Linux

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/keystore.jks"))
```

### 5. Certificate 및 Provisioning Profile Base64 인코딩

```bash
# Certificate
base64 -i certificate.p12 | pbcopy

# Provisioning Profile
base64 -i profile.mobileprovision | pbcopy
```

## 워크플로우 동작

### Develop 브랜치

1. `develop` 브랜치에 push하면 자동으로 트리거됩니다
2. Android APK와 iOS IPA를 빌드합니다
3. iOS는 TestFlight에 자동 업로드됩니다
4. Android는 Artifact로 저장됩니다 (수동으로 Play Console에 업로드 가능)

### Release 브랜치

1. `release` 브랜치에 push하면 자동으로 트리거됩니다
2. Android App Bundle과 iOS IPA를 빌드합니다
3. iOS는 App Store Connect에 자동 업로드됩니다 (심사 제출은 수동)
4. Android는 Google Play Production 트랙에 자동 업로드됩니다

## 수동 트리거

GitHub Actions 탭에서 **Run workflow** 버튼을 클릭하여 수동으로 실행할 수 있습니다.

## 문제 해결

### Android 빌드 실패

- Keystore 파일이 올바르게 인코딩되었는지 확인
- 비밀번호가 정확한지 확인
- `build.gradle.kts`의 signing config가 올바른지 확인

### iOS 빌드 실패

- 인증서와 프로비저닝 프로파일이 유효한지 확인
- App Store Connect API Key 권한이 올바른지 확인
- ExportOptions.plist 파일이 올바른지 확인

### 업로드 실패

- Google Play: 서비스 계정 권한 확인
- App Store: API Key 권한 및 인증서 유효성 확인

## 보안 주의사항

⚠️ **중요**: 다음 파일들은 절대 Git에 커밋하지 마세요:

- `android/app/keystore.jks`
- `*.p12` (인증서 파일)
- `*.mobileprovision` (프로비저닝 프로파일)
- Google Play Service Account JSON
- App Store Connect API Key (.p8)

모든 민감한 정보는 GitHub Secrets에 저장하세요.

