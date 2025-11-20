# App Store Connect API Key 생성 가이드

이 가이드는 App Store Connect에서 API Key를 생성하는 상세한 단계를 설명합니다.

## 📍 접근 경로

### 방법 1: 프로필 메뉴에서 접근 (권장)

1. [App Store Connect](https://appstoreconnect.apple.com)에 로그인
2. **우측 상단의 사용자 아이콘** 클릭 (프로필 사진 또는 이니셜)
3. 드롭다운 메뉴에서 **사용자 및 액세스** 선택
4. 왼쪽 사이드바에서 **키** 탭 클릭

### 방법 2: 직접 메뉴에서 접근

1. [App Store Connect](https://appstoreconnect.apple.com)에 로그인
2. 상단 메뉴에서 **사용자 및 액세스** 클릭
   - 또는 앱 목록 페이지에서 **사용자 및 액세스** 메뉴 찾기
3. 왼쪽 사이드바에서 **키** 탭 클릭

### 방법 3: 검색으로 찾기

1. App Store Connect에 로그인
2. 상단 검색창에 "키" 또는 "API" 검색
3. **키** 또는 **API 키** 메뉴 선택

## 🔑 API 키 생성 단계

### 1단계: 키 페이지로 이동

**사용자 및 액세스** 페이지에 접근한 후:

1. 왼쪽 사이드바에서 **키** 메뉴 클릭
   - 또는 상단 탭 메뉴에서 **키** 선택
   - 메뉴 구조: **사용자 및 액세스** → **키**

**참고**: 
- 계정에 **Admin** 또는 **App Manager** 권한이 있어야 키 메뉴가 보입니다
- 권한이 없다면 계정 소유자에게 권한 요청이 필요합니다

### 2단계: 새 키 생성

1. 우측 상단의 **+** 버튼 또는 **생성** 버튼 클릭
2. 다음 정보 입력:
   - **이름**: 키를 식별할 이름 (예: "CI/CD Key", "GitHub Actions")
   - **액세스**: 드롭다운에서 선택
     - **App Manager**: 앱 관리 권한 (권장)
     - **Admin**: 전체 관리 권한

### 3단계: 키 정보 저장

생성 후 다음 정보가 표시됩니다:

- **키 ID**: 10자리 영문+숫자 (예: `ABC123DEF4`)
  - 이 값은 나중에 볼 수 있으므로 복사해서 보관
- **Issuer ID**: UUID 형식 (예: `12345678-1234-1234-1234-123456789012`)
  - 페이지 상단에 표시됨

### 4단계: 키 파일 다운로드

1. **다운로드** 버튼 클릭
2. `.p8` 파일이 다운로드됨
3. 파일 이름 형식: `AuthKey_<KEY_ID>.p8`

⚠️ **중요**: 이 파일은 **한 번만 다운로드 가능**합니다!
- 다운로드 후에는 다시 다운로드할 수 없습니다
- 파일을 안전한 곳에 백업하세요
- GitHub Secrets에 저장할 때는 파일 내용 전체를 복사하세요

## 📋 필요한 정보 정리

API 키 생성 후 다음 3가지 정보가 필요합니다:

1. **Key ID** (키 ID)
   - 형식: 10자리 영문+숫자
   - 예: `ABC123DEF4`
   - GitHub Secret: `APP_STORE_CONNECT_API_KEY_ID`

2. **Issuer ID** (발급자 ID)
   - 형식: UUID
   - 예: `12345678-1234-1234-1234-123456789012`
   - 위치: 키 페이지 상단에 표시
   - GitHub Secret: `APP_STORE_CONNECT_ISSUER_ID`

3. **API Key** (.p8 파일 내용)
   - 파일: `AuthKey_<KEY_ID>.p8`
   - 내용: `-----BEGIN PRIVATE KEY-----`로 시작하는 텍스트
   - GitHub Secret: `APP_STORE_CONNECT_API_KEY`

## 🔍 Issuer ID 찾기

Issuer ID는 다음 위치에서 찾을 수 있습니다:

1. **키 페이지 상단**: "Issuer ID" 레이블 옆
2. **사용자 및 액세스 페이지**: 상단에 표시
3. **앱 정보 페이지**: 일부 앱 정보에도 표시됨

## ✅ 확인 사항

API 키 생성 후 다음을 확인하세요:

- [ ] Key ID를 복사하여 저장했는가?
- [ ] Issuer ID를 복사하여 저장했는가?
- [ ] `.p8` 파일을 다운로드했는가?
- [ ] `.p8` 파일 내용을 확인했는가? (`-----BEGIN PRIVATE KEY-----`로 시작)
- [ ] GitHub Secrets에 3가지 정보를 모두 추가했는가?

## 🆘 문제 해결

### "키" 탭이 보이지 않아요

- 계정에 **Admin** 또는 **App Manager** 권한이 있는지 확인
- 계정 소유자에게 권한 요청

### 키를 다운로드하지 못했어요

- 이미 다운로드한 경우 다시 다운로드 불가
- 새 키를 생성해야 함
- 기존 키는 삭제할 수 있지만, 삭제 후에는 복구 불가

### Issuer ID를 찾을 수 없어요

- **키 페이지 상단**에 "Issuer ID" 레이블과 함께 표시됨
- **사용자 및 액세스 페이지 상단**에도 표시될 수 있음
- 계정 소유자에게 문의하여 확인

### "사용자 및 액세스" 메뉴가 보이지 않아요

- 계정에 **Admin** 권한이 있는지 확인
- 계정 소유자에게 권한 요청
- 일부 계정은 제한된 권한만 가질 수 있음

## 📚 참고 자료

- [App Store Connect API 공식 문서](https://developer.apple.com/documentation/appstoreconnectapi)
- [API 키 생성 가이드](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)

