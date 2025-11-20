# CI/CD 설정 가이드

이 문서는 GitHub Actions를 사용한 자동 빌드 및 배포 파이프라인 설정 방법을 설명합니다.

## 브랜치 전략

- **`develop`**: 개발 빌드 → TestFlight (iOS) / Internal Testing (Android)
- **`release`**: 프로덕션 빌드 → App Store (iOS) / Production (Android)

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

1. Google Play Console에 로그인
2. **설정** → **API 액세스**로 이동
3. **서비스 계정** 생성 또는 기존 계정 사용
4. 서비스 계정에 **앱 관리자** 권한 부여
5. JSON 키 파일 다운로드

### 2. iOS 설정

#### 2.1 App Store Connect API Key 생성

1. [App Store Connect](https://appstoreconnect.apple.com)에 로그인
2. **사용자 및 액세스** → **키** 탭으로 이동
3. **+** 버튼 클릭하여 새 API 키 생성
4. **App Manager** 또는 **Admin** 권한 부여
5. 키 다운로드 (`.p8` 파일) - **한 번만 다운로드 가능**

#### 2.2 인증서 및 프로비저닝 프로파일

1. [Apple Developer Portal](https://developer.apple.com)에 로그인
2. **Certificates, Identifiers & Profiles**로 이동
3. **Distribution Certificate** 생성 (또는 기존 사용)
4. **App Store Distribution Provisioning Profile** 생성
5. 인증서와 프로파일을 다운로드

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

