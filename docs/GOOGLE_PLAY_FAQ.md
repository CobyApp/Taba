# Google Play Console 서비스 계정 FAQ

## ❓ 자주 묻는 질문

### Q1: Google Cloud Platform에서 별도로 프로젝트를 만들어야 하나요?

**A: 아니요, 필요 없습니다!**

- Google Play Console에서 "서비스 계정 만들기" 버튼을 클릭하면
- 자동으로 Google Cloud Console로 이동합니다
- 프로젝트는 자동으로 연결되거나 기존 프로젝트를 선택하면 됩니다
- **새 프로젝트를 만들 필요는 없습니다**

### Q2: Google Cloud Platform에 직접 접속해야 하나요?

**A: 아니요, 필요 없습니다!**

- Google Play Console에서 버튼을 클릭하면 자동으로 이동합니다
- 별도로 Google Cloud Platform에 로그인할 필요 없습니다
- Google Play Console 계정으로 자동 로그인됩니다

### Q3: 프로젝트 선택이 나오는데 뭘 선택해야 하나요?

**A: 기존 프로젝트를 선택하거나 자동으로 선택된 것을 사용하세요**

- Google Play Console과 연결된 프로젝트가 자동으로 선택될 수 있습니다
- 드롭다운에서 프로젝트를 선택할 수 있다면 아무거나 선택해도 됩니다
- **새 프로젝트를 만들 필요는 없습니다**

### Q4: Google Cloud Console에서 뭘 해야 하나요?

**A: 서비스 계정만 만들면 됩니다**

1. 서비스 계정 이름 입력 (예: "Taba CI/CD")
2. 서비스 계정 만들기
3. 키 탭에서 JSON 키 다운로드
4. Google Play Console로 돌아가기

**역할 부여는 건너뛰어도 됩니다** (Google Play Console에서 나중에 권한 부여)

### Q5: JSON 키를 다운로드한 후 뭘 해야 하나요?

**A: Google Play Console로 돌아가서 권한을 부여해야 합니다**

1. Google Play Console → API 액세스 페이지로 이동
2. 생성한 서비스 계정 옆의 "권한 부여" 버튼 클릭
3. 앱 선택
4. "앱 관리자" 권한 부여

### Q6: JSON 키 파일은 어디에 저장하나요?

**A: 안전한 곳에 저장하세요**

- 로컬 컴퓨터의 안전한 폴더에 저장
- GitHub Secrets에 추가할 때는 파일 내용 전체를 복사
- **절대 Git에 커밋하지 마세요!**

### Q7: JSON 키를 잃어버렸어요

**A: 새 키를 만들 수 있습니다**

- Google Cloud Console → 서비스 계정 → 키 탭
- "키 추가" → "새 키 만들기" → JSON 선택
- 새 JSON 파일 다운로드
- GitHub Secrets 업데이트

### Q8: 서비스 계정을 삭제할 수 있나요?

**A: 네, 가능합니다**

- Google Cloud Console에서 서비스 계정 삭제 가능
- 또는 Google Play Console에서 권한만 제거 가능

## 📋 전체 프로세스 요약

1. **Google Play Console** → API 액세스 페이지
2. "서비스 계정 만들기" 클릭 → **자동으로 Google Cloud Console 이동**
3. **Google Cloud Console**에서 서비스 계정 생성
4. JSON 키 다운로드
5. **Google Play Console**로 돌아가기
6. 서비스 계정에 권한 부여

**핵심**: Google Cloud Platform에 별도로 접속하거나 프로젝트를 만들 필요 없습니다!

