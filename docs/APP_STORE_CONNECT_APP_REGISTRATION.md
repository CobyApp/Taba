# App Store Connect 앱 등록 가이드

이 가이드는 App Store Connect에 앱을 등록하는 방법을 설명합니다. CI/CD에서 자동 업로드를 사용하려면 먼저 앱을 등록해야 합니다.

## ⚠️ 중요

**앱을 등록하지 않으면 IPA 업로드가 실패합니다!**

오류 메시지:
```
No suitable application records were found. Verify your bundle identifier 'com.coby.taba' is correct...
```

## 📱 앱 등록 단계

### 1. App Store Connect 접속

1. [App Store Connect](https://appstoreconnect.apple.com)에 로그인
2. **내 앱** (My Apps) 클릭

### 2. 새 앱 만들기

1. **+** 버튼 클릭 → **새 앱** (New App) 선택

2. 앱 정보 입력:
   - **플랫폼**: iOS
   - **이름**: Taba (또는 원하는 앱 이름)
   - **기본 언어**: 한국어 (또는 원하는 언어)
   - **번들 ID**: `com.coby.taba` 선택
     - ⚠️ **중요**: 이 Bundle ID는 Apple Developer Portal에서 먼저 생성되어 있어야 합니다
     - 없으면 [App ID 생성 가이드](./IOS_CERTIFICATE_SETUP.md#3-1단계-app-id-생성-필요한-경우) 참고
   - **SKU**: 고유 식별자 (예: `taba-001`)
   - **사용자 액세스**: **전체 액세스** 또는 **제한된 액세스** 선택

3. **만들기** (Create) 클릭

### 3. 앱 정보 확인

앱이 생성되면 다음 정보를 확인할 수 있습니다:
- **앱 ID**: 자동 생성됨
- **Bundle ID**: `com.coby.taba`
- **이름**: Taba

## ✅ 등록 완료 확인

앱이 등록되면:
- App Store Connect → **내 앱** → **Taba** 클릭
- 앱 정보 페이지가 표시됨
- **앱 정보**, **가격 및 판매 범위** 등의 탭이 보임

## 🚀 다음 단계

앱이 등록되면 CI/CD에서 자동 업로드가 작동합니다:

1. **develop** 브랜치에 push → TestFlight에 자동 업로드
2. **release** 브랜치에 push → App Store Connect에 자동 업로드

## 📝 참고사항

### Bundle ID 확인

앱을 등록하기 전에 Bundle ID가 Apple Developer Portal에 등록되어 있는지 확인:

1. [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) 접속
2. **Identifiers** → **App IDs** 확인
3. `com.coby.taba`가 있는지 확인
4. 없으면 [App ID 생성 가이드](./IOS_CERTIFICATE_SETUP.md#3-1단계-app-id-생성-필요한-경우) 참고

### 앱 등록 후 CI/CD 동작

앱이 등록되면:
- ✅ IPA 파일이 자동으로 업로드됨
- ✅ TestFlight에 빌드가 표시됨
- ✅ 수동 업로드 불필요

앱이 등록되지 않으면:
- ⚠️ IPA 파일은 생성되지만 업로드 실패
- ✅ Artifact에서 IPA 파일 다운로드 가능
- 📝 수동으로 App Store Connect에 업로드 필요

## 🆘 문제 해결

### "Bundle ID를 찾을 수 없습니다"

**원인**: Apple Developer Portal에 App ID가 등록되지 않음

**해결**:
1. [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) 접속
2. **Identifiers** → **+** 버튼
3. **App IDs** → **App** 선택
4. Bundle ID: `com.coby.taba` 입력
5. **Register** 클릭
6. App Store Connect에서 다시 앱 등록 시도

### "이미 사용 중인 Bundle ID입니다"

**원인**: 다른 앱에서 이미 사용 중인 Bundle ID

**해결**:
- 다른 Bundle ID 사용
- 또는 기존 앱 삭제 후 재등록

### "권한이 없습니다"

**원인**: App Store Connect 계정 권한 부족

**해결**:
- **Admin** 또는 **App Manager** 권한이 필요
- 계정 관리자에게 권한 요청

## 📚 관련 문서

- [iOS 인증서 설정 가이드](./IOS_CERTIFICATE_SETUP.md)
- [App Store Connect API Key 생성](./APP_STORE_CONNECT_GUIDE.md)
- [환경변수 설정 가이드](./ENVIRONMENT_SETUP_GUIDE.md)

