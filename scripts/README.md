# 스크립트 가이드

이 디렉토리에는 CI/CD 설정을 자동화하는 스크립트들이 포함되어 있습니다.

## 📋 사용 가능한 스크립트

### 1. `setup_ios_certificates.sh`

iOS 인증서와 프로비저닝 프로파일을 확인하고 base64로 인코딩합니다.

**사용법:**
```bash
./scripts/setup_ios_certificates.sh
```

**기능:**
- Keychain에서 Distribution 인증서 확인
- .p12 파일 인코딩 및 검증
- Provisioning Profile 정보 추출 및 인코딩
- 클립보드에 자동 복사 (macOS)

**필요한 것:**
- .p12 파일 (Keychain Access에서 내보낸 파일)
- .mobileprovision 파일 (Apple Developer Portal에서 다운로드)

### 2. `setup_github_secrets.sh`

GitHub Secrets 설정 가이드를 표시하고, GitHub CLI가 설치된 경우 자동으로 설정합니다.

**사용법:**
```bash
./scripts/setup_github_secrets.sh
```

**기능:**
- 필요한 모든 GitHub Secrets 목록 표시
- GitHub CLI를 통한 자동 설정 (선택적)
- 수동 설정 가이드 제공

**필요한 것:**
- GitHub CLI (`gh`) 설치 (선택적, 자동 설정을 원하는 경우)
- 또는 GitHub 웹 인터페이스에서 수동 설정

## 🚀 빠른 시작

### iOS 인증서 설정

```bash
# 1. 스크립트 실행
./scripts/setup_ios_certificates.sh

# 2. .p12 파일 경로 입력
# 3. 비밀번호 입력
# 4. Provisioning Profile 경로 입력
# 5. 생성된 Base64 값을 GitHub Secrets에 복사
```

### GitHub Secrets 설정

```bash
# 방법 1: GitHub CLI 사용 (자동)
./scripts/setup_github_secrets.sh

# 방법 2: 웹 인터페이스 사용
# GitHub 저장소 → Settings → Secrets and variables → Actions
```

## 📚 상세 가이드

더 자세한 내용은 다음 문서를 참고하세요:

- [환경변수 및 인증서 설정 완전 가이드](../docs/ENVIRONMENT_SETUP_GUIDE.md)
- [CI/CD 설정 가이드](../docs/CI_CD_SETUP.md)
- [iOS 인증서 설정 가이드](../docs/IOS_CERTIFICATE_SETUP.md)

## ⚠️ 주의사항

1. **보안**: 인증서와 프로파일은 절대 Git에 커밋하지 마세요
2. **비밀번호**: 모든 비밀번호를 안전하게 보관하세요
3. **백업**: 인증서와 프로파일을 안전한 곳에 백업하세요

