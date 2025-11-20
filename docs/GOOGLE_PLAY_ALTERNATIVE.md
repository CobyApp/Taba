# Google Play Console API 액세스 대안 방법

Google Play Console의 API 액세스 서비스가 중단된 경우, Google Cloud Console에서 직접 서비스 계정을 생성할 수 있습니다.

## 🔄 대안 방법: Google Cloud Console에서 직접 생성

### 1단계: Google Cloud Console 접속

1. [Google Cloud Console](https://console.cloud.google.com)에 로그인
2. Google Play Console과 같은 Google 계정으로 로그인

### 2단계: 프로젝트 선택 또는 생성

1. 상단의 **프로젝트 선택** 드롭다운 클릭
2. 다음 중 선택:
   - **기존 프로젝트 선택**: Google Play Console과 연결된 프로젝트가 있다면 선택
   - **새 프로젝트 생성**: 없다면 새로 생성
     - 프로젝트 이름: "Taba App" (또는 원하는 이름)
     - 생성 클릭

### 3단계: 서비스 계정 생성

1. 왼쪽 사이드바에서 **IAM 및 관리자** → **서비스 계정** 클릭
   - 또는 직접 URL: https://console.cloud.google.com/iam-admin/serviceaccounts
2. 상단의 **서비스 계정 만들기** 클릭
3. 다음 정보 입력:
   - **서비스 계정 이름**: "Taba CI/CD" (또는 원하는 이름)
   - **서비스 계정 ID**: 자동 생성됨 (수정 가능)
   - **설명**: "CI/CD 자동 배포용" (선택사항)
4. **만들고 계속하기** 클릭
5. **역할 부여** 단계는 **건너뛰기** (나중에 Google Play Console에서 권한 부여)
6. **완료** 클릭

### 4단계: JSON 키 생성

1. 생성된 서비스 계정 목록에서 방금 만든 계정 찾기
2. 계정을 클릭하여 상세 페이지로 이동
3. 상단 탭에서 **키** 탭 클릭
4. **키 추가** → **새 키 만들기** 클릭
5. **JSON** 형식 선택
6. **만들기** 클릭
7. JSON 파일이 자동으로 다운로드됨
   - ⚠️ **중요**: 이 파일은 한 번만 다운로드 가능합니다!
   - 파일을 안전한 곳에 저장하세요

### 5단계: Google Play Console에 연결

1. [Google Play Console](https://play.google.com/console)로 이동
2. 왼쪽 사이드바에서 **설정** 클릭
3. **API 액세스** 탭 찾기 (또는 직접 URL 접근)
4. **서비스 계정** 섹션에서:
   - **서비스 계정 연결** 또는 **Link service account** 버튼 클릭
   - 또는 다운로드한 JSON 파일의 `client_email` 값을 사용하여 연결
5. 연결된 서비스 계정에 **권한 부여**:
   - **권한 부여** (Grant access) 버튼 클릭
   - 앱 선택
   - **앱 관리자** 권한 부여

## 📋 필요한 정보

### JSON 파일에서 필요한 정보

다운로드한 JSON 파일을 열어서 다음 정보 확인:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "xxxxx@xxxxx.iam.gserviceaccount.com",  ← 이 이메일 주소
  "client_id": "xxxxx",
  ...
}
```

- **client_email**: 서비스 계정 이메일 주소 (Google Play Console 연결 시 필요)

### GitHub Secret에 추가

- Secret 이름: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- 값: JSON 파일 **전체 내용** (중괄호 포함)

## ✅ 확인 사항

- [ ] Google Cloud Console에서 서비스 계정 생성 완료
- [ ] JSON 키 파일 다운로드 완료
- [ ] Google Play Console에 서비스 계정 연결 완료
- [ ] 서비스 계정에 앱 관리자 권한 부여 완료
- [ ] GitHub Secrets에 JSON 파일 내용 추가 완료

## 🆘 문제 해결

### Google Play Console에 서비스 계정을 연결할 수 없어요

- 서비스 계정 이메일 주소(`client_email`)를 확인하세요
- Google Play Console의 API 액세스 페이지에서 "서비스 계정 추가" 옵션 찾기
- 또는 Google Play Console 지원팀에 문의

### 프로젝트를 찾을 수 없어요

- 새 프로젝트를 생성해도 됩니다
- 프로젝트 이름은 아무거나 상관없습니다
- Google Play Console과 연결할 때 서비스 계정 이메일만 필요합니다

### 권한 부여가 안 돼요

- 서비스 계정이 Google Play Console에 연결되어 있는지 확인
- 계정 소유자 권한이 있는지 확인
- 앱이 등록되어 있는지 확인

## 📚 참고 자료

- [Google Cloud Console 서비스 계정 가이드](https://cloud.google.com/iam/docs/service-accounts)
- [Google Play Developer API 문서](https://developers.google.com/android-publisher)

