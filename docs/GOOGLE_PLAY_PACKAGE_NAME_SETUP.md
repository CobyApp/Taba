# Google Play Console 패키지 이름 설정 가이드

앱을 만들었지만 패키지 이름을 설정하지 못한 경우 해결 방법입니다.

## ⚠️ 중요 사항

**Google Play Console에서 앱을 만들 때 패키지 이름은 반드시 설정해야 합니다!**

패키지 이름은:
- 앱을 만든 후에는 **변경할 수 없습니다**
- 앱을 삭제하고 다시 만들어야 패키지 이름을 변경할 수 있습니다
- 패키지 이름은 앱의 고유 식별자입니다

## 🔍 현재 상황 확인

### 1. 앱 대시보드에서 패키지 이름 확인

1. [Google Play Console](https://play.google.com/console) 접속
2. 앱 선택
3. 왼쪽 사이드바에서 **앱 정보** (App information) 또는 **정책** (Policy) 클릭
4. **앱 ID** 또는 **Package name** 확인

### 2. 패키지 이름이 없는 경우

앱을 만들 때 패키지 이름 입력 단계를 건너뛴 경우:
- 앱이 "초안" 상태일 수 있습니다
- 패키지 이름을 설정하려면 앱을 완전히 생성해야 합니다

## ✅ 해결 방법

### ⚠️ 중요: Google Play Console의 최신 프로세스

**Google Play Console에서는 앱을 만들 때 패키지 이름을 직접 입력하지 않습니다!**

대신:
- 앱을 만들 때는 **앱 이름, 언어, 유형**만 입력합니다
- **첫 번째 AAB/APK 파일을 업로드할 때** 패키지 이름이 자동으로 결정됩니다
- 업로드한 AAB/APK 파일의 `applicationId`가 패키지 이름이 됩니다

### 방법 1: 앱 생성 후 AAB 업로드로 패키지 이름 설정 (권장)

1. [Google Play Console](https://play.google.com/console) 접속
2. **앱 만들기** (Create app) 클릭
3. 앱 정보 입력:
   - **앱 이름**: Taba
   - **기본 언어**: English (또는 원하는 언어)
   - **앱 유형**: App
   - **무료 또는 유료**: 무료
4. **만들기** (Create) 클릭
5. 앱이 생성되면:
   - 왼쪽 사이드바에서 **프로덕션** (Production) 또는 **테스트** (Testing) 선택
   - **새 버전 만들기** (Create new release) 클릭
   - **AAB 파일 업로드** 또는 **APK 파일 업로드** 클릭
   - 프로젝트에서 빌드한 AAB 파일 업로드
   - ⚠️ **중요**: 업로드한 AAB 파일의 `applicationId`가 패키지 이름이 됩니다!
   - 현재 프로젝트의 `applicationId`는 `com.coby.taba`이므로, 이 값이 패키지 이름으로 설정됩니다

### 방법 2: 기존 앱이 있는 경우

#### 2-1. 패키지 이름이 다른 경우

기존 앱의 패키지 이름이 `com.coby.taba`가 아닌 경우:

**옵션 A: 새 앱 만들기 (권장)**
1. 기존 앱 삭제 (또는 그대로 두고 새로 만들기)
2. 위의 "방법 1" 따라 새 앱 만들기
3. 패키지 이름: `com.coby.taba` 입력

**옵션 B: 프로젝트 패키지 이름 변경**
1. `android/app/build.gradle.kts` 파일 열기
2. `applicationId`를 Google Play Console의 패키지 이름과 일치시키기:
   ```kotlin
   android {
       defaultConfig {
           applicationId "com.coby.taba"  // Google Play Console의 패키지 이름으로 변경
       }
   }
   ```
3. 앱 재빌드

#### 2-2. 패키지 이름이 없는 경우

앱이 만들어졌지만 패키지 이름이 설정되지 않은 경우:

1. Google Play Console에서 앱 대시보드 확인
2. **앱 정보** (App information) → **앱 ID** 확인
3. 패키지 이름이 표시되지 않으면:
   - 앱이 아직 완전히 생성되지 않은 상태일 수 있습니다
   - 앱을 삭제하고 다시 만들기 (방법 1 참고)

## 📝 앱 생성 단계별 가이드

### 1단계: 앱 만들기 시작

1. [Google Play Console](https://play.google.com/console) 접속
2. 왼쪽 상단 **앱 만들기** (Create app) 또는 **+** 버튼 클릭

### 2단계: 앱 기본 정보 입력

- **앱 이름**: Taba
- **기본 언어**: English
- **앱 유형**: App
- **무료 또는 유료**: 무료

### 3단계: 앱 만들기

**만들기** (Create) 버튼 클릭

### 4단계: 첫 번째 릴리스 업로드 (패키지 이름 설정)

앱이 생성되면 패키지 이름은 아직 설정되지 않았습니다. 첫 번째 AAB 파일을 업로드해야 합니다:

1. 왼쪽 사이드바에서 **프로덕션** (Production) 또는 **테스트** (Testing) 선택
2. **새 버전 만들기** (Create new release) 클릭
3. **AAB 파일 업로드** 클릭
4. 프로젝트에서 빌드한 AAB 파일 선택:
   - 파일 위치: `build/app/outputs/bundle/release/app-release.aab`
   - 또는 GitHub Actions Artifact에서 다운로드
5. 파일 업로드
6. ⚠️ **중요**: 
   - 업로드한 AAB 파일의 `applicationId`가 패키지 이름으로 설정됩니다
   - 현재 프로젝트의 `applicationId`는 `com.coby.taba`입니다
   - 패키지 이름은 한 번 설정하면 변경할 수 없습니다!

### 5단계: 패키지 이름 확인

AAB 파일을 업로드한 후:

1. **앱 정보** (App information) 또는 **정책** (Policy) 메뉴로 이동
2. **앱 ID** 또는 **Package name** 확인
3. `com.coby.taba`로 표시되는지 확인

## 🔍 패키지 이름 확인 방법

### Google Play Console에서

1. 앱 대시보드 접속
2. 왼쪽 사이드바 **앱 정보** (App information) 클릭
3. **앱 ID** 또는 **Package name** 확인

### 프로젝트에서

1. `android/app/build.gradle.kts` 파일 열기
2. `applicationId` 확인:
   ```kotlin
   android {
       defaultConfig {
           applicationId "com.coby.taba"  // 이 값 확인
       }
   }
   ```

## ⚠️ 주의사항

1. **패키지 이름은 변경 불가**: 앱을 만든 후 패키지 이름을 변경할 수 없습니다
2. **일치해야 함**: Google Play Console의 패키지 이름과 프로젝트의 `applicationId`가 정확히 일치해야 합니다
3. **대소문자 구분**: 패키지 이름은 대소문자를 구분합니다
4. **고유성**: 패키지 이름은 Google Play 전체에서 고유해야 합니다

## 🆘 문제 해결

### "앱을 만들 때 패키지 이름을 입력할 수 없어요"

**정상입니다!** Google Play Console의 최신 프로세스에서는:
- 앱을 만들 때 패키지 이름을 입력하지 않습니다
- 첫 번째 AAB/APK 파일을 업로드할 때 패키지 이름이 자동으로 설정됩니다
- 해결 방법: AAB 파일을 업로드하세요 (위의 "방법 1" 참고)

### "AAB 파일을 업로드했는데 패키지 이름이 다릅니다"

- 업로드한 AAB 파일의 `applicationId`가 패키지 이름이 됩니다
- `android/app/build.gradle.kts`에서 `applicationId` 확인:
  ```kotlin
  android {
      defaultConfig {
          applicationId "com.coby.taba"  // 이 값이 패키지 이름이 됩니다
      }
  }
  ```
- `applicationId`가 `com.coby.taba`가 아니라면 수정 후 재빌드

### "이미 사용 중인 패키지 이름입니다"

- 다른 앱에서 이미 사용 중인 패키지 이름입니다
- 다른 패키지 이름 사용하거나 기존 앱 삭제

### "패키지 이름이 표시되지 않아요"

- 앱이 아직 완전히 생성되지 않았을 수 있습니다
- 앱을 삭제하고 다시 만들기

## ✅ 체크리스트

앱 생성 전 확인:

- [ ] Google Play Console에 로그인됨
- [ ] 개발자 계정이 활성화됨
- [ ] 앱 이름 결정됨 (Taba)
- [ ] 패키지 이름 결정됨 (com.coby.taba)
- [ ] 프로젝트의 `applicationId`가 `com.coby.taba`로 설정됨

앱 생성 후 확인:

- [ ] 패키지 이름이 `com.coby.taba`로 설정됨
- [ ] Google Play Console에서 패키지 이름 확인 가능
- [ ] 프로젝트의 `applicationId`와 일치함

## 🔗 관련 문서

- [Google Play 업로드 문제 해결](./GOOGLE_PLAY_TROUBLESHOOTING.md)
- [Android Publisher API 설정](./GOOGLE_PLAY_API_SETUP.md)
- [환경변수 설정 가이드](./ENVIRONMENT_SETUP_GUIDE.md)

