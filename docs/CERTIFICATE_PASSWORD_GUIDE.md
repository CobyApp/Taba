# iOS Certificate 비밀번호 설정 가이드

## 🔑 비밀번호 오류 해결하기

Certificate import 시 "MAC verification failed during PKCS12 import (wrong password?)" 오류가 발생하면, 비밀번호가 잘못되었을 가능성이 높습니다.

## 📝 올바른 비밀번호 설정 방법

### 1단계: .p12 파일 내보내기 (비밀번호 설정)

1. **Keychain Access** 앱 열기
2. 왼쪽 사이드바에서 **login** 선택
3. **My Certificates** 또는 **Certificates** 카테고리 선택
4. **Apple Distribution: [Your Name]** 인증서 찾기
5. 인증서를 **우클릭** → **Export "Apple Distribution: [Your Name]"** 선택
6. 파일 저장 위치 선택 (예: Desktop)
7. **파일 형식**: `Personal Information Exchange (.p12)` 선택
8. **저장** 클릭
9. ⚠️ **중요**: 비밀번호 입력 창이 나타납니다
   - **비밀번호 입력**: 원하는 비밀번호 입력 (예: `MyPassword123!`)
   - **비밀번호 확인**: 동일한 비밀번호 다시 입력
   - **이 비밀번호를 반드시 기억하세요!** GitHub Secret에 사용합니다
10. **확인** 클릭
11. Keychain 비밀번호 입력 (macOS 로그인 비밀번호)
12. `.p12` 파일 생성 완료 ✅

### 2단계: Base64 인코딩

터미널에서 실행:

```bash
# .p12 파일을 base64로 인코딩
base64 -i ~/Desktop/AppleDistribution.p12 | pbcopy
```

또는 파일 경로를 직접 지정:

```bash
base64 -i /path/to/your/certificate.p12 | pbcopy
```

인코딩된 내용이 클립보드에 복사됩니다.

### 3단계: GitHub Secrets에 추가

1. GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** 클릭
3. 다음 3가지 Secret 추가:

#### Secret 1: APPLE_CERTIFICATE_BASE64
- **Name**: `APPLE_CERTIFICATE_BASE64`
- **Value**: 위에서 복사한 base64 인코딩된 내용 (전체 내용 붙여넣기)
- **Secret** 클릭

#### Secret 2: APPLE_CERTIFICATE_PASSWORD
- **Name**: `APPLE_CERTIFICATE_PASSWORD`
- **Value**: **1단계에서 설정한 비밀번호** (예: `MyPassword123!`)
  - ⚠️ **주의**: .p12 파일 내보낼 때 입력한 비밀번호와 정확히 일치해야 합니다!
  - 대소문자, 특수문자 모두 정확히 입력
- **Secret** 클릭

#### Secret 3: APPLE_PROVISIONING_PROFILE_BASE64
- **Name**: `APPLE_PROVISIONING_PROFILE_BASE64`
- **Value**: Provisioning Profile의 base64 인코딩된 내용
- **Secret** 클릭

## ✅ 비밀번호 확인 체크리스트

- [ ] .p12 파일 내보낼 때 설정한 비밀번호를 정확히 기억하고 있나요?
- [ ] GitHub Secret의 `APPLE_CERTIFICATE_PASSWORD`가 .p12 내보낼 때 설정한 비밀번호와 정확히 일치하나요?
- [ ] 대소문자를 정확히 입력했나요? (예: `MyPassword` ≠ `mypassword`)
- [ ] 특수문자를 정확히 입력했나요? (예: `!` ≠ `1`)
- [ ] 공백이나 줄바꿈이 포함되지 않았나요?

## 🔄 비밀번호를 잊어버렸다면?

비밀번호를 잊어버렸다면, **새로운 .p12 파일을 다시 내보내야 합니다**:

1. Keychain Access에서 기존 인증서 삭제 (선택사항)
2. Apple Developer Portal에서 인증서 다시 다운로드
3. Keychain Access에 설치
4. **새로운 비밀번호로 다시 내보내기**
5. 새로운 base64 인코딩
6. GitHub Secret 업데이트

## 🧪 비밀번호 테스트

로컬에서 비밀번호가 올바른지 테스트:

```bash
# .p12 파일이 있는 위치로 이동
cd ~/Desktop

# 비밀번호로 인증서 확인 (비밀번호 입력)
security import certificate.p12 -k ~/Library/Keychains/login.keychain-db -P "YOUR_PASSWORD"

# 성공하면 비밀번호가 올바른 것입니다
# 실패하면 "MAC verification failed" 오류 발생
```

## 💡 비밀번호 설정 팁

1. **간단한 비밀번호 사용**: 복잡한 비밀번호보다는 기억하기 쉬운 비밀번호 사용
2. **비밀번호 관리**: 1Password, LastPass 등 비밀번호 관리자에 저장
3. **문서화**: 팀 내부 문서에 비밀번호 저장 (안전한 곳에)
4. **일관성**: 팀원 모두가 동일한 비밀번호를 사용하도록 통일

## 🆘 여전히 문제가 있다면?

1. **새로운 .p12 파일 생성**: 기존 파일을 삭제하고 다시 내보내기
2. **인증서 재다운로드**: Apple Developer Portal에서 인증서 다시 다운로드
3. **Keychain 재설정**: Keychain Access에서 인증서 삭제 후 재설치
4. **비밀번호 재설정**: 새로운 비밀번호로 다시 내보내기

## 📞 추가 도움

- [Apple Developer Support](https://developer.apple.com/support/)
- [Keychain Access 가이드](https://support.apple.com/guide/keychain-access/)

