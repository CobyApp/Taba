# iOS 인증서 및 프로비저닝 프로파일 생성 가이드

이 가이드는 Apple Developer에서 Distribution Certificate와 Provisioning Profile을 생성하는 상세한 방법을 설명합니다.

## 📋 사전 준비

- Apple Developer 계정 (유료 멤버십 필요)
- macOS 컴퓨터 (Keychain Access 사용)
- Xcode가 설치되어 있으면 더 편리합니다

## 🔐 1단계: Distribution Certificate 생성

### 방법 1: Keychain Access로 CSR 파일 생성 (권장)

#### macOS에서 CSR 파일 생성

1. **Keychain Access** 앱 열기
   - Spotlight 검색 (Cmd + Space) → "Keychain Access" 입력
   - 또는 Applications → Utilities → Keychain Access

2. 상단 메뉴에서 **Keychain Access** → **인증서 지원** → **인증 기관에 인증서 요청...** 클릭

3. 인증서 정보 입력:
   - **사용자 이메일 주소**: Apple Developer 계정 이메일
   - **일반 이름**: 이름 또는 회사명 (예: "Taba Developer")
   - **CA 이메일 주소**: 비워두기
   - **요청 대상**: **디스크에 저장됨** 선택
   - **키 쌍 정보**: **2048비트 RSA** 선택

4. **계속** 클릭

5. 파일 저장 위치 선택:
   - 파일 이름: `CertificateSigningRequest.certSigningRequest` (기본값)
   - 저장 위치: Desktop 또는 원하는 위치
   - **저장** 클릭

6. CSR 파일이 생성됨 ✅
   - 파일 위치를 기억해두세요!

### 방법 2: Xcode로 자동 생성 (더 쉬움)

1. **Xcode** 열기
2. **Xcode** → **Settings** (또는 Preferences) → **Accounts** 탭
3. Apple ID 추가 (이미 있으면 스킵)
4. Apple ID 선택 → **Manage Certificates...** 클릭
5. **+** 버튼 클릭 → **Apple Distribution** 선택
6. Xcode가 자동으로 인증서 생성 및 다운로드 ✅

**참고**: Xcode를 사용하면 CSR 파일을 수동으로 만들 필요가 없습니다!

## 📱 2단계: Apple Developer에서 인증서 생성

1. [Apple Developer Portal](https://developer.apple.com/account)에 로그인

2. **Certificates, Identifiers & Profiles** 클릭
   - 또는 직접 URL: https://developer.apple.com/account/resources/certificates/list

3. **Certificates** 섹션에서 **+** 버튼 클릭

4. 인증서 유형 선택:
   - **Apple Distribution** 선택
   - **Continue** 클릭

5. CSR 파일 업로드:
   - **방법 1 사용한 경우**: 
     - "Choose File" 클릭
     - 위에서 저장한 `CertificateSigningRequest.certSigningRequest` 파일 선택
     - **Continue** 클릭
   - **방법 2 사용한 경우 (Xcode)**:
     - Xcode가 이미 인증서를 생성했으므로 이 단계 스킵 가능
     - 또는 Xcode에서 생성된 인증서를 사용

6. 인증서 다운로드:
   - **Download** 버튼 클릭
   - `distribution.cer` 파일이 다운로드됨

7. 인증서 설치:
   - 다운로드한 `.cer` 파일 더블클릭
   - Keychain Access에 자동으로 추가됨

## 📦 3단계: 인증서를 .p12 파일로 내보내기

CI/CD에 사용하려면 인증서를 `.p12` 형식으로 내보내야 합니다.

1. **Keychain Access** 앱 열기

2. 왼쪽 사이드바에서 **로그인** → **인증서** 선택

3. **Apple Distribution: [이름]** 인증서 찾기
   - 인증서를 클릭하면 아래에 **개인 키**가 표시됨
   - 개인 키가 함께 있어야 함

4. 인증서를 **우클릭** → **내보내기 "Apple Distribution..."** 선택
   - 또는 인증서 선택 후 **File** → **Export Items...**

5. 파일 저장:
   - 파일 이름: `distribution.p12` (또는 원하는 이름)
   - 파일 형식: **Personal Information Exchange (.p12)** 선택
   - **저장** 클릭

6. 비밀번호 설정:
   - **비밀번호** 입력 (나중에 사용할 비밀번호)
   - **비밀번호 확인** 입력
   - **확인** 클릭
   - ⚠️ **이 비밀번호를 기억하세요!** GitHub Secret에 사용합니다
   - ⚠️ **중요**: 이 비밀번호는 GitHub Secret `APPLE_CERTIFICATE_PASSWORD`에 정확히 입력해야 합니다
   - 대소문자, 특수문자 모두 정확히 입력해야 합니다

7. `.p12` 파일이 생성됨 ✅

## 📱 3-1단계: App ID 생성 (필요한 경우)

Provisioning Profile을 만들기 전에 App ID가 필요합니다.

### App ID 생성 방법

1. [Apple Developer Portal](https://developer.apple.com/account)에서
2. **Certificates, Identifiers & Profiles** 클릭
3. 왼쪽 사이드바에서 **Identifiers** 클릭
   - 또는 직접 URL: https://developer.apple.com/account/resources/identifiers/list
4. **+** 버튼 클릭
5. **App IDs** 선택 → **Continue** 클릭
6. **App** 선택 → **Continue** 클릭
7. App ID 정보 입력:
   - **Description**: 앱 설명 (예: "Taba App")
   - **Bundle ID**: 
     - **Explicit**: 선택
     - **Bundle ID**: `com.coby.taba` (앱의 실제 Bundle ID 입력)
       - ⚠️ **중요**: 이 값은 Xcode 프로젝트의 Bundle Identifier와 정확히 일치해야 합니다!
8. **Capabilities** 선택 (필요한 기능):
   - Push Notifications (푸시 알림 사용 시)
   - Associated Domains (필요한 경우)
   - 기타 필요한 기능 선택
9. **Continue** 클릭
10. 정보 확인 후 **Register** 클릭
11. App ID 생성 완료 ✅

### Bundle ID 확인 방법

Xcode에서 확인:
1. Xcode에서 프로젝트 열기
2. 프로젝트 네비게이터에서 프로젝트 선택
3. **TARGETS** → **Runner** 선택
4. **General** 탭에서 **Bundle Identifier** 확인
   - 예: `com.coby.taba`

## 📄 4단계: Provisioning Profile 생성

1. [Apple Developer Portal](https://developer.apple.com/account)에서
2. **Profiles** 섹션으로 이동
   - 또는 직접 URL: https://developer.apple.com/account/resources/profiles/list
3. **+** 버튼 클릭

4. 프로파일 유형 선택:
   - **App Store** 선택
   - **Continue** 클릭

5. App ID 선택:
   - 위에서 생성한 **App ID** 선택
   - 또는 기존 App ID 선택
   - **Continue** 클릭

6. 인증서 선택:
   - 위에서 생성한 **Apple Distribution** 인증서 선택
   - **Continue** 클릭

7. 프로파일 이름 입력:
   - 예: "Taba App Store Distribution"
   - **Generate** 클릭

8. 프로파일 다운로드:
   - **Download** 버튼 클릭
   - `.mobileprovision` 파일이 다운로드됨

## ✅ App ID 확인 사항

App ID 생성 후 다음을 확인하세요:

- [ ] Bundle ID가 Xcode 프로젝트의 Bundle Identifier와 일치하는가?
- [ ] 필요한 Capabilities가 모두 선택되었는가? (Push Notifications 등)
- [ ] App ID가 정상적으로 등록되었는가?

## 🔄 5단계: Base64 인코딩

CI/CD에 사용하려면 인증서와 프로파일을 base64로 인코딩해야 합니다.

### .p12 파일 인코딩

```bash
# macOS
base64 -i distribution.p12 | pbcopy

# Linux
base64 -i distribution.p12

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("distribution.p12"))
```

### .mobileprovision 파일 인코딩

```bash
# macOS
base64 -i profile.mobileprovision | pbcopy

# Linux
base64 -i profile.mobileprovision

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision"))
```

## 📋 GitHub Secrets에 추가

다음 3가지 정보를 GitHub Secrets에 추가:

1. **APPLE_CERTIFICATE_BASE64**: 위에서 인코딩한 .p12 파일 내용
2. **APPLE_CERTIFICATE_PASSWORD**: .p12 파일 내보낼 때 설정한 비밀번호
3. **APPLE_PROVISIONING_PROFILE_BASE64**: 위에서 인코딩한 .mobileprovision 파일 내용

## ✅ 확인 사항

- [ ] Distribution Certificate 생성 완료
- [ ] .p12 파일로 내보내기 완료
- [ ] Provisioning Profile 생성 완료
- [ ] Base64 인코딩 완료
- [ ] GitHub Secrets에 3가지 정보 추가 완료

## 🔑 비밀번호 오류 해결

Certificate import 시 "MAC verification failed during PKCS12 import (wrong password?)" 오류가 발생하면:

1. **비밀번호 확인**: .p12 파일 내보낼 때 설정한 비밀번호를 정확히 기억하고 있는지 확인
2. **GitHub Secret 확인**: `APPLE_CERTIFICATE_PASSWORD`가 .p12 내보낼 때 설정한 비밀번호와 정확히 일치하는지 확인
3. **대소문자 확인**: 비밀번호의 대소문자가 정확한지 확인 (예: `MyPassword` ≠ `mypassword`)
4. **특수문자 확인**: 특수문자가 정확한지 확인 (예: `!` ≠ `1`)
5. **새로 내보내기**: 비밀번호를 잊어버렸다면 새로운 비밀번호로 다시 내보내기

### 비밀번호 테스트 (로컬)

```bash
# .p12 파일이 있는 위치로 이동
cd ~/Desktop

# 비밀번호로 인증서 확인
security import certificate.p12 -k ~/Library/Keychains/login.keychain-db -P "YOUR_PASSWORD"

# 성공하면 비밀번호가 올바른 것입니다
# 실패하면 "MAC verification failed" 오류 발생
```

## 🆘 문제 해결

### CSR 파일을 만들 수 없어요

- **Xcode 사용**: Xcode → Settings → Accounts → Manage Certificates에서 자동 생성
- **macOS가 아닌 경우**: 다른 macOS 컴퓨터를 사용하거나, 팀원에게 CSR 파일 생성 요청

### 인증서를 .p12로 내보낼 수 없어요

- Keychain Access에서 인증서와 개인 키가 함께 있는지 확인
- 인증서를 삭제하고 다시 다운로드 후 설치
- Xcode를 사용한 경우, Xcode에서 직접 내보내기 가능

### App ID를 찾을 수 없어요

- Apple Developer Portal → Identifiers에서 확인
- Bundle ID가 정확한지 확인 (대소문자 구분)
- Xcode 프로젝트의 Bundle Identifier와 일치하는지 확인

### Provisioning Profile을 만들 수 없어요

- App ID가 생성되어 있는지 확인
- Distribution Certificate가 생성되어 있는지 확인
- 앱이 App Store Connect에 등록되어 있는지 확인
- App ID의 Bundle ID가 정확한지 확인

## 💡 팁

- **Xcode 사용 권장**: Xcode를 사용하면 대부분의 과정이 자동화됩니다
- **비밀번호 관리**: .p12 비밀번호를 안전하게 보관하세요 (1Password, LastPass 등 사용)
- **백업**: 인증서와 프로파일을 안전한 곳에 백업하세요

