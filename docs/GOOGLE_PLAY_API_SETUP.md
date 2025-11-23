# Google Play Android Publisher API 설정 가이드

이 가이드는 Google Play에 자동 업로드를 위해 필요한 Android Publisher API를 Google Cloud Console에서 활성화하는 방법을 설명합니다.

## ⚠️ 일반적인 오류

다음과 같은 오류가 발생하는 경우:
```
Google Play Android Developer API has not been used in project [PROJECT_ID] before or it is disabled.
```

이는 Google Cloud 프로젝트에서 Android Publisher API를 활성화해야 한다는 의미입니다.

## 🔧 해결 방법

### 1단계: Google Cloud Console 접속

1. [Google Cloud Console](https://console.cloud.google.com)에 접속
2. Google Play Console에 사용한 것과 동일한 Google 계정으로 로그인

### 2단계: 프로젝트 선택 또는 생성

1. 상단의 프로젝트 드롭다운 클릭
2. 다음 중 선택:
   - **기존 프로젝트 선택**: 서비스 계정과 연결된 프로젝트 선택
   - **새 프로젝트 생성**: "새 프로젝트" 클릭하여 생성

### 3단계: Android Publisher API 활성화

**방법 1: 직접 URL 접속 (권장)**

1. 다음 URL로 직접 이동: `https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview?project=[YOUR_PROJECT_ID]`
   - `[YOUR_PROJECT_ID]`를 실제 프로젝트 ID로 교체
   - 프로젝트 ID는 오류 메시지나 Google Cloud Console에서 확인 가능

2. **"사용 설정"** (Enable) 버튼 클릭

**방법 2: API 라이브러리를 통한 접근**

1. [Google Cloud Console APIs & Services](https://console.cloud.google.com/apis/library)로 이동
2. "Google Play Android Developer API" 또는 "Android Publisher API" 검색
3. API 클릭
4. **"사용 설정"** (Enable) 버튼 클릭

### 4단계: 전파 대기

API를 활성화한 후:
- API가 전파될 때까지 2-5분 대기
- 업로드가 작동하려면 API가 완전히 활성화되어야 함

### 5단계: API 활성화 확인

1. [활성화된 API](https://console.cloud.google.com/apis/dashboard)로 이동
2. "Android Publisher API" 검색
3. "사용 설정됨" (Enabled)으로 표시되는지 확인

## 🔍 프로젝트 ID 찾기

프로젝트 ID를 모르는 경우:

1. **오류 메시지에서**: 오류에 프로젝트 ID가 표시됨 (예: `551445714018`)
2. **Google Cloud Console에서**: 
   - [Google Cloud Console](https://console.cloud.google.com)로 이동
   - 프로젝트 드롭다운에 프로젝트 ID가 표시됨
3. **서비스 계정 JSON에서**:
   - 서비스 계정 JSON 파일 열기
   - `project_id` 필드 확인

## ✅ 확인

API를 활성화한 후 다시 업로드를 시도하세요:

1. `release` 브랜치에 push (또는 워크플로우 수동 실행)
2. 이제 업로드가 성공해야 합니다

여전히 실패하는 경우:
- 몇 분 더 대기
- 서비스 계정에 올바른 권한이 있는지 확인
- Google Play Console에 앱이 존재하는지 확인

## 📝 관련 단계

API를 활성화하기 전에 다음을 확인하세요:

1. ✅ Google Cloud Console에서 서비스 계정 생성
2. ✅ 서비스 계정 JSON 키 다운로드
3. ✅ Google Play Console에 서비스 계정 추가
4. ✅ 서비스 계정에 "앱 관리자" 역할 부여
5. ✅ Google Play Console에 패키지 이름 `com.coby.taba`로 앱 생성
6. ✅ GitHub에 `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret 추가

## 🆘 문제 해결

### "API를 찾을 수 없습니다"

- 올바른 Google Cloud 프로젝트에 있는지 확인
- 프로젝트는 서비스 계정이 생성된 것과 동일해야 함

### "권한이 거부되었습니다"

- Google Cloud 프로젝트에서 "소유자" 또는 "편집자" 역할이 있는지 확인
- 또는 접근 권한이 있는 사람에게 API 활성화 요청

### "활성화 후에도 여전히 오류 발생"

- 완전한 전파를 위해 5-10분 대기
- 브라우저 캐시 삭제 시도
- 서비스 계정 JSON이 올바른지 확인
- Google Play Console 권한 확인

## 🔗 빠른 링크

- [Android Publisher API 활성화](https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview)
- [Google Cloud Console](https://console.cloud.google.com)
- [Google Play Console](https://play.google.com/console)
- [API 라이브러리](https://console.cloud.google.com/apis/library)

