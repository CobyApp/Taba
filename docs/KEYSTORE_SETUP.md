# Keystore 생성 가이드

Android 앱을 배포하기 위해서는 서명용 Keystore 파일이 필요합니다.

## 방법 1: 스크립트 사용 (권장)

```bash
./scripts/create_keystore.sh
```

스크립트가 비밀번호를 안전하게 입력받아 keystore를 생성합니다.

## 방법 2: 직접 명령어 실행

### macOS/Linux

```bash
keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias taba-key \
  -storepass <비밀번호> \
  -keypass <비밀번호> \
  -dname "CN=Taba, OU=Development, O=Taba, L=Seoul, ST=Seoul, C=KR"
```

**중요**: `<비밀번호>` 부분을 실제 비밀번호로 교체하세요.  
**주의**: zsh에서는 백슬래시(`\`)로 줄바꿈을 하면 에러가 발생할 수 있습니다. 한 줄로 입력하거나 스크립트를 사용하세요.

### 한 줄 명령어 (zsh 호환)

```bash
keytool -genkey -v -keystore android/app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias taba-key -storepass <비밀번호> -keypass <비밀번호> -dname "CN=Taba, OU=Development, O=Taba, L=Seoul, ST=Seoul, C=KR"
```

## Keystore 정보

- **파일 위치**: `android/app/keystore.jks`
- **별칭 (Alias)**: `taba-key`
- **유효기간**: 10000일 (약 27년)
- **알고리즘**: RSA 2048비트

## 비밀번호 설정

- Keystore 비밀번호와 Key 비밀번호를 동일하게 설정하는 것을 권장합니다.
- **안전한 비밀번호**를 사용하세요 (최소 8자, 대소문자, 숫자, 특수문자 포함).
- 비밀번호를 **안전하게 보관**하세요. 분실하면 앱 업데이트가 불가능합니다.

## 다음 단계

1. **Keystore를 base64로 인코딩**:
   ```bash
   base64 -i android/app/keystore.jks | pbcopy  # macOS
   base64 -i android/app/keystore.jks            # Linux
   ```

2. **GitHub Secrets에 추가**:
   - `ANDROID_KEYSTORE_BASE64`: 위에서 복사한 base64 문자열
   - `ANDROID_KEYSTORE_PASSWORD`: Keystore 비밀번호
   - `ANDROID_KEY_ALIAS`: `taba-key`
   - `ANDROID_KEY_PASSWORD`: Key 비밀번호 (보통 Keystore 비밀번호와 동일)

## 보안 주의사항

⚠️ **중요**: 
- Keystore 파일(`keystore.jks`)은 **절대 Git에 커밋하지 마세요!**
- 비밀번호를 코드나 문서에 직접 작성하지 마세요!
- Keystore 파일을 안전한 곳에 백업하세요!

## 문제 해결

### "zsh: parse error near '\n'" 에러

zsh에서 백슬래시로 줄바꿈을 하면 발생할 수 있습니다. 해결 방법:

1. **스크립트 사용**: `./scripts/create_keystore.sh`
2. **한 줄로 입력**: 위의 "한 줄 명령어" 사용
3. **다른 쉘 사용**: `bash` 또는 `sh`로 실행

### "keystore.jks already exists" 에러

기존 keystore 파일이 있는 경우:

```bash
# 기존 파일 백업 (선택사항)
mv android/app/keystore.jks android/app/keystore.jks.backup

# 새로 생성
./scripts/create_keystore.sh
```

