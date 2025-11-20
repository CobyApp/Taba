# Google Play Console 서비스 계정 설정 가이드

이 가이드는 Google Play Console에서 서비스 계정을 생성하고 CI/CD에 사용하는 방법을 설명합니다.

## ⚠️ 중요 공지

**Google Play Console의 API 액세스 서비스가 중단된 경우**, 아래 **대안 방법**을 사용하세요:
- [대안 방법: Google Cloud Console에서 직접 생성](./GOOGLE_PLAY_ALTERNATIVE.md)

## 📍 접근 경로

### 방법 1: 직접 URL 접근 (개발자 ID 포함)

**현재 URL을 보면 개발자 ID가 `8677267942546809805`입니다.**

1. 현재 브라우저 주소창에 다음 URL을 **정확히** 입력:
   ```
   https://play.google.com/console/u/0/developers/8677267942546809805/api-access
   ```
2. Enter 키를 눌러 이동
3. **여전히 안 되면**: 아래 다른 방법 시도

### 방법 2: 설정 페이지에서 찾기

1. 현재 페이지에서 왼쪽 사이드바의 **설정** (Settings) 클릭
2. 설정 페이지로 이동
3. **페이지 상단의 탭 메뉴**를 자세히 확인:
   - "설정" (Settings)
   - **"API 액세스"** 또는 **"API access"** ← 여기 있을 수 있음
   - "사용자 및 권한" (Users and permissions)
   - 기타 탭들
4. **API 액세스** 탭을 찾아 클릭

**참고**: 설정 페이지 상단에 여러 탭이 가로로 나열되어 있을 수 있습니다.

### 방법 3: 현재 페이지에서 직접 이동

**현재 "사용자 및 권한" 페이지에 있으므로:**

1. 현재 페이지 상단의 **"← 사용자 및 권한"** 옆의 뒤로가기 화살표 클릭
   - 또는 왼쪽 사이드바에서 **"사용자 및 권한"** 다시 클릭
2. **사용자 및 권한 목록 페이지**로 이동
3. 페이지 상단에 **"API 액세스"** 탭이 있는지 확인
4. 또는 왼쪽 사이드바에서 **"설정"** 클릭 후 상단 탭 확인

### 방법 4: 개발자 계정 메뉴에서

1. Google Play Console에 로그인
2. 왼쪽 사이드바에서 **개발자 계정** (Developer Account) 클릭
3. **API 액세스** 섹션 찾기

### 방법 5: 검색 기능 사용

1. Google Play Console에 로그인
2. 상단 검색창에 **"API"** 또는 **"서비스 계정"** 입력
3. 검색 결과에서 **API 액세스** 선택

## ⚠️ 사전 확인 사항

API 액세스 페이지에 접근하기 전에 다음을 확인하세요:

1. **계정 권한**: 소유자 또는 관리자 권한이 있어야 합니다 ✅ (확인됨)
2. **앱 등록**: 최소 1개 이상의 앱이 등록되어 있어야 합니다 ⚠️
3. **Google Cloud 프로젝트**: Google Cloud 프로젝트가 연결되어 있어야 할 수 있습니다

### 앱이 등록되지 않은 경우

**앱을 먼저 등록해야 API 액세스 페이지에 접근할 수 있습니다.**

#### 앱 등록 방법 (간단 버전):

1. Google Play Console 메인 페이지로 이동
2. **앱 만들기** 또는 **Create app** 버튼 클릭
3. 앱 정보 입력:
   - 앱 이름: "Taba" (또는 원하는 이름)
   - 기본 언어: 한국어
   - 앱 또는 게임: 앱
   - 무료 또는 유료: 무료
4. **앱 만들기** 클릭
5. 앱이 생성되면 API 액세스 페이지 접근 시도

**참고**: 앱을 실제로 배포할 필요는 없습니다. 등록만 하면 됩니다.

## 📱 앱 등록이 필요한 경우

**⚠️ 중요**: 앱이 등록되지 않았다면 먼저 앱을 등록해야 합니다.

### 빠른 확인

1. Google Play Console 메인 페이지로 이동
2. 앱 목록이 있는지 확인
3. 앱이 없다면: [앱 등록 가이드](./GOOGLE_PLAY_APP_REGISTRATION.md) 참고

**앱 등록은 간단합니다**:
- 앱 이름만 입력하면 됩니다
- 실제 배포할 필요는 없습니다
- 등록만 하면 API 액세스 기능을 사용할 수 있습니다

## 🔑 서비스 계정 생성 단계

### 1단계: API 액세스 페이지로 이동

**⚠️ 중요**: 설정 페이지에서 "API 액세스"가 보이지 않는다면, **직접 URL로 접근**하세요!

#### 가장 확실한 방법: 직접 URL 접근

1. Google Play Console에 로그인한 상태에서
2. 브라우저 주소창에 다음 URL을 입력하고 Enter:
   ```
   https://play.google.com/console/u/0/developers/api-access
   ```
3. 또는 현재 URL의 `/settings` 부분을 `/api-access`로 변경:
   - 현재: `play.google.com/console/u/0/developers/.../settings`
   - 변경: `play.google.com/console/u/0/developers/.../api-access`

#### 다른 방법들:

1. **설정 페이지 상단 탭 확인**:
   - 설정 페이지 상단에 여러 탭이 있을 수 있음
   - "API 액세스" 탭 찾기

2. **사용자 및 권한 메뉴**:
   - 왼쪽 사이드바의 **사용자 및 권한** 클릭
   - 상단 탭에서 "API 액세스" 찾기

3. **검색 기능**:
   - Google Play Console 상단 검색창에 "API" 입력
   - "API 액세스" 선택

### 2단계: 서비스 계정 생성

1. **서비스 계정** 섹션에서 **서비스 계정 만들기** 또는 **CREATE SERVICE ACCOUNT** 버튼 클릭
2. **Google Cloud Console 페이지로 자동 이동됨** ⚠️
   - 별도로 Google Cloud Platform에 접속할 필요 없음
   - Google Play Console에서 버튼 클릭하면 자동으로 이동

3. Google Cloud Console에서:
   - **프로젝트 선택**: 
     - Google Play Console과 **자동으로 연결된 프로젝트**가 있을 수 있음
     - 또는 드롭다운에서 프로젝트 선택
     - **새 프로젝트를 만들 필요는 없습니다!** (기존 프로젝트 사용)

### 3단계: Google Cloud Console에서 서비스 계정 생성

**⚠️ 중요**: Google Cloud Platform에 별도로 접속하거나 프로젝트를 만들 필요 없습니다!
- Google Play Console에서 버튼 클릭하면 자동으로 이동합니다
- 프로젝트는 자동으로 연결되거나 기존 프로젝트를 선택하면 됩니다

1. Google Cloud Console 페이지에서 **서비스 계정 만들기** 클릭
2. 다음 정보 입력:
   - **서비스 계정 이름**: 예) "Taba CI/CD" 또는 "GitHub Actions"
   - **서비스 계정 ID**: 자동 생성됨 (수정 가능)
   - **설명** (선택사항): "CI/CD 자동 배포용"
3. **만들고 계속하기** 클릭

### 4단계: 역할 부여 (선택사항)

- 이 단계는 **건너뛰어도 됩니다**
- Google Play Console에서 나중에 권한을 부여할 예정이므로
- **완료** 또는 **건너뛰기** 클릭

### 5단계: JSON 키 생성

1. 생성된 서비스 계정 목록에서 방금 만든 계정 찾기
2. 계정을 클릭하여 상세 페이지로 이동
3. **키** (Keys) 탭 클릭
4. **키 추가** (Add Key) → **새 키 만들기** (Create new key) 클릭
5. **JSON** 형식 선택
6. **만들기** 클릭
7. JSON 파일이 자동으로 다운로드됨
   - 파일 이름: `프로젝트명-xxxxx.json`
   - ⚠️ **중요**: 이 파일은 한 번만 다운로드 가능합니다!

### 6단계: Google Play Console로 돌아가기

**JSON 키를 다운로드한 후**:

1. 브라우저에서 **Google Play Console 탭으로 돌아가기**
   - 또는 새 탭에서 [Google Play Console](https://play.google.com/console) 열기
2. **API 액세스** 페이지로 이동
   - 왼쪽 사이드바 → **설정** → **API 액세스** 탭
   - 또는 직접 URL: `https://play.google.com/console/u/0/developers/[YOUR_DEVELOPER_ID]/api-access`
3. **서비스 계정** 섹션에서 방금 생성한 계정 확인
4. 계정 옆의 **권한 부여** (Grant access) 또는 **Grant access** 버튼 클릭

### 7단계: 앱 권한 부여

1. **앱 선택** 드롭다운에서 앱 선택
   - 또는 **모든 앱** 선택
2. **역할** (Role) 선택:
   - **앱 관리자** (Admin) 권한 권장
   - 또는 필요한 최소 권한 선택
3. **사용자 추가** 또는 **Invite user** 클릭
4. 권한이 부여되었는지 확인

## 📋 필요한 정보

서비스 계정 생성 후 다음 정보가 필요합니다:

### JSON 키 파일 내용

다운로드한 JSON 파일을 열어서 **전체 내용**을 복사하세요:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "xxxxx@xxxxx.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/xxxxx"
}
```

**GitHub Secret**: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- 값: 위 JSON 파일의 **전체 내용** (중괄호 포함)

## ✅ 확인 사항

서비스 계정 설정 후 다음을 확인하세요:

- [ ] 서비스 계정이 Google Cloud Console에 생성되었는가?
- [ ] JSON 키 파일을 다운로드했는가?
- [ ] Google Play Console에서 서비스 계정에 권한을 부여했는가?
- [ ] 앱 관리자 권한이 부여되었는가?
- [ ] GitHub Secrets에 JSON 파일 전체 내용을 추가했는가?

## 🔄 대안 방법: Google Cloud Console에서 직접 생성

Google Play Console의 API 액세스 서비스가 중단되었거나 접근할 수 없는 경우:

1. [Google Cloud Console](https://console.cloud.google.com)에 로그인
2. **IAM 및 관리자** → **서비스 계정** → **서비스 계정 만들기**
3. 서비스 계정 생성 후 **키** 탭에서 **JSON 키 생성**
4. 다운로드한 JSON 파일의 `client_email`을 사용하여 Google Play Console에 연결
5. Google Play Console → **API 액세스** → 서비스 계정 연결 → 권한 부여

## 🆘 문제 해결

### "API 액세스" 메뉴를 찾을 수 없어요 / URL 접근이 안 돼요

이 문제는 주로 **권한 문제**입니다. 다음을 확인하세요:

#### 1. 계정 권한 확인

- Google Play Console 계정에 **소유자 (Owner)** 또는 **관리자 (Admin)** 권한이 필요합니다
- 현재 계정의 권한 확인 방법:
  1. 왼쪽 사이드바에서 **사용자 및 권한** 클릭
  2. 자신의 이메일 찾기
  3. 권한 레벨 확인 (소유자/관리자/개발자 등)

#### 2. 권한이 없는 경우

- **계정 소유자에게 연락**하여 다음 권한 요청:
  - "API 액세스 페이지에 접근할 수 있는 권한을 부여해주세요"
  - 또는 "소유자/관리자 권한을 부여해주세요"

#### 3. 대안: 계정 소유자가 직접 생성

권한이 없다면, 계정 소유자가 다음을 수행:
1. API 액세스 페이지 접근
2. 서비스 계정 생성
3. JSON 키 다운로드
4. JSON 파일을 안전하게 전달

#### 4. 앱 등록 확인

- Google Play Console에 **최소 1개 이상의 앱이 등록**되어 있어야 할 수 있습니다
- 앱이 없다면 먼저 앱을 등록하세요

#### 5. 다른 접근 방법 시도

1. **사용자 및 권한** 메뉴에서 API 관련 옵션 찾기
2. **개발자 계정** 메뉴에서 API 설정 찾기
3. Google Play Console 상단 검색창에 "API" 또는 "service account" 검색

### "서비스 계정 만들기" 버튼이 보이지 않아요

- Google Play Console 계정에 **소유자** 또는 **관리자** 권한이 있는지 확인
- 계정 소유자에게 권한 요청
- **API 액세스** 페이지에 접근할 수 있어야 서비스 계정을 생성할 수 있습니다

### Google Cloud Console 프로젝트를 찾을 수 없어요

- Google Play Console과 연결된 프로젝트가 자동으로 생성됨
- 또는 새 프로젝트를 생성할 수 있음
- 프로젝트 이름은 Google Play Console 앱 이름과 다를 수 있음

### JSON 키 파일을 다운로드하지 못했어요

- Google Cloud Console에서 다시 다운로드 가능
- 서비스 계정 → 키 탭 → 키 추가 → 새 키 만들기

### "권한 부여" 버튼이 보이지 않아요

- 서비스 계정이 Google Play Console에 연결되지 않았을 수 있음
- Google Cloud Console에서 서비스 계정을 다시 확인
- 또는 Google Play Console API 액세스 페이지를 새로고침

### 앱 업로드 권한이 없어요

- 서비스 계정에 **앱 관리자** 권한이 부여되었는지 확인
- Google Play Console → API 액세스 → 서비스 계정 → 권한 확인

### 앱이 등록되지 않았어요

API 액세스 페이지에 접근하려면 최소 1개 이상의 앱이 등록되어 있어야 합니다:

1. Google Play Console → **앱 만들기**
2. 앱 이름, 기본 언어, 앱/게임 선택
3. **무료** 선택
4. 앱 만들기 완료
5. 앱 등록 후 API 액세스 페이지 접근 시도

**참고**: 앱을 실제로 배포할 필요는 없습니다. 등록만 하면 됩니다.

## 📚 참고 자료

- [Google Play Console API 문서](https://developers.google.com/android-publisher)
- [서비스 계정 생성 가이드](https://developers.google.com/android-publisher/getting_started#using_a_service_account)
- [Google Cloud Console](https://console.cloud.google.com)

## 🔒 보안 주의사항

⚠️ **중요**:
- JSON 키 파일은 **절대 Git에 커밋하지 마세요!**
- JSON 파일 내용을 코드나 문서에 직접 작성하지 마세요!
- GitHub Secrets에만 저장하세요!
- JSON 파일을 안전한 곳에 백업하세요!

