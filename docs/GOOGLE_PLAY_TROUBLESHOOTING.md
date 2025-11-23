# Google Play 업로드 문제 해결 가이드

앱이 이미 Google Play Console에 생성되어 있는데도 업로드가 실패하는 경우, 다음을 확인하세요.

## 🔍 단계별 확인 사항

### 1. Android Publisher API 활성화 확인

**가장 흔한 원인입니다!**

1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. 프로젝트 선택 (서비스 계정이 생성된 프로젝트)
3. [API 라이브러리](https://console.cloud.google.com/apis/library)로 이동
4. "Android Publisher API" 또는 "Google Play Android Developer API" 검색
5. API 클릭 → "사용 설정" 버튼 클릭
6. 2-5분 대기

**직접 URL**:
```
https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview?project=[YOUR_PROJECT_ID]
```

상세 가이드: [GOOGLE_PLAY_API_SETUP.md](./GOOGLE_PLAY_API_SETUP.md)

### 2. 서비스 계정 권한 확인

1. [Google Play Console](https://play.google.com/console) 접속
2. **설정** → **API 액세스** (또는 Settings → API access)
3. 서비스 계정 찾기 (서비스 계정 이메일 확인)
4. **권한 부여** 또는 **관리** 클릭
5. 다음 확인:
   - ✅ **앱 관리자** (App Manager) 역할이 부여되어 있는지
   - ✅ 앱이 선택되어 있는지 (com.coby.taba)
   - ✅ 권한이 활성화되어 있는지

**서비스 계정 이메일 확인 방법**:
- GitHub Secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`의 내용에서 `client_email` 필드 확인

### 3. 패키지 이름 확인

**Google Play Console에서**:
1. 앱 대시보드로 이동
2. **앱 정보** (App information) 확인
3. 패키지 이름이 `com.coby.taba`인지 확인

**프로젝트에서**:
1. `android/app/build.gradle.kts` 파일 열기
2. `applicationId` 확인:
   ```kotlin
   android {
       defaultConfig {
           applicationId "com.coby.taba"
       }
   }
   ```

### 4. 앱 상태 확인

Google Play Console에서 앱 상태 확인:
- ✅ **초안** (Draft) 상태여야 업로드 가능
- ✅ **검토 중** (In review) 상태도 가능
- ❌ **거부됨** (Rejected) 상태는 문제 해결 필요

### 5. 첫 릴리스 요구사항 확인

앱이 처음 업로드되는 경우:
- ✅ 앱 정보가 최소한으로 입력되어 있어야 함
- ✅ 스토어 등록 정보가 완료되어 있어야 함 (최소한 기본 정보)
- ✅ 콘텐츠 등급이 설정되어 있어야 함

## 🆘 일반적인 오류 메시지와 해결 방법

### "Google Play Android Developer API has not been used"

**원인**: Android Publisher API가 활성화되지 않음

**해결**:
1. 위의 "1. Android Publisher API 활성화 확인" 참고
2. API 활성화 후 2-5분 대기
3. 다시 빌드 시도

### "Application not found" 또는 "Package not found"

**원인**: 패키지 이름 불일치 또는 앱이 생성되지 않음

**해결**:
1. Google Play Console에서 패키지 이름 확인
2. `android/app/build.gradle.kts`에서 `applicationId` 확인
3. 일치하지 않으면 수정하거나 새 앱 생성

### "Permission denied" 또는 "Authentication failed"

**원인**: 서비스 계정 권한 문제

**해결**:
1. 위의 "2. 서비스 계정 권한 확인" 참고
2. 서비스 계정에 "앱 관리자" 역할 부여
3. 서비스 계정 JSON 파일이 올바른지 확인

### "Edit not found" 또는 "No releases"

**원인**: 앱 설정이 완료되지 않음

**해결**:
1. Google Play Console에서 앱 설정 완료
2. 최소한의 스토어 등록 정보 입력
3. 콘텐츠 등급 설정

## 🔧 디버깅 방법

### 1. 서비스 계정 JSON 확인

GitHub Secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`의 내용 확인:
- `project_id`: Google Cloud 프로젝트 ID
- `client_email`: 서비스 계정 이메일
- `private_key`: 개인 키 (올바른 형식인지 확인)

### 2. 로컬에서 테스트 (선택사항)

```bash
# 서비스 계정 JSON 파일 준비
echo "$GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" > service-account.json

# gcloud CLI로 인증 테스트
gcloud auth activate-service-account --key-file=service-account.json

# API 활성화 확인
gcloud services list --enabled | grep androidpublisher
```

### 3. Google Play Console 로그 확인

1. Google Play Console → **설정** → **API 액세스**
2. 서비스 계정 클릭
3. **활동 로그** (Activity log) 확인
4. 최근 API 호출 기록 확인

## ✅ 체크리스트

업로드 전 확인 사항:

- [ ] Android Publisher API가 활성화되어 있음
- [ ] 서비스 계정이 Google Play Console에 추가되어 있음
- [ ] 서비스 계정에 "앱 관리자" 역할이 부여되어 있음
- [ ] 패키지 이름이 일치함 (com.coby.taba)
- [ ] 앱이 Google Play Console에 생성되어 있음
- [ ] 앱 상태가 "초안" 또는 "검토 중"임
- [ ] GitHub Secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`이 설정되어 있음
- [ ] 서비스 계정 JSON 파일이 올바른 형식임

## 📚 관련 문서

- [Android Publisher API 설정 가이드](./GOOGLE_PLAY_API_SETUP.md)
- [환경변수 설정 가이드](./ENVIRONMENT_SETUP_GUIDE.md)
- [CI/CD 설정 가이드](./CI_CD_SETUP.md)

## 🔗 유용한 링크

- [Google Play Console](https://play.google.com/console)
- [Google Cloud Console](https://console.cloud.google.com)
- [API 라이브러리](https://console.cloud.google.com/apis/library)
- [Android Publisher API](https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview)

