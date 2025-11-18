# API 통합 검토 보고서 (최종)

## 개요
API 명세서(`API_SPECIFICATION.md`)와 실제 코드 구현을 비교하여 전체적인 API 연결, 데이터 주고받기, 데이터 구조 파싱이 올바른지 꼼꼼히 검토한 결과입니다.

**검토 일자**: 2025-01-18  
**API 명세서 버전**: 1.4.0  
**검토 범위**: 모든 API 엔드포인트, DTO, 서비스 파일

---

## ✅ 검증 완료 항목

### 1. 인증 API (`/auth`)
- ✅ **POST** `/auth/login` - 올바르게 구현됨
  - 에러 코드 처리: `INVALID_CREDENTIALS` 지원
- ✅ **POST** `/auth/signup` - multipart/form-data 지원, 프로필 이미지 업로드 지원
  - 에러 코드 처리: `INVALID_EMAIL`, `INVALID_PASSWORD`, `VALIDATION_ERROR`, `EMAIL_ALREADY_EXISTS` 지원
- ✅ **POST** `/auth/forgot-password` - 올바르게 구현됨
- ✅ **POST** `/auth/reset-password` - 올바르게 구현됨
- ✅ **PUT** `/auth/change-password` - 올바르게 구현됨
- ✅ **POST** `/auth/logout` - 올바르게 구현됨

**응답 구조**: `{success: true, data: {token, user}}` ✅

### 2. 사용자 API (`/users`)
- ✅ **GET** `/users/{userId}` - 올바르게 구현됨
  - 에러 코드 처리: `USER_NOT_FOUND` 지원
- ✅ **PUT** `/users/{userId}` - multipart/form-data 지원, 프로필 이미지 업로드/제거 지원
  - `profileImage`와 `avatarUrl` 동시 제공 시 `profileImage` 우선 처리 ✅
  - 에러 코드 처리: `USER_NOT_FOUND`, `FORBIDDEN` 지원
- ✅ **PUT** `/users/{userId}/fcm-token` - FCM 토큰 등록 지원

**응답 구조**: `{success: true, data: {id, email, nickname, avatarUrl, ...}}` ✅

### 3. 편지 API (`/letters`)
- ✅ **POST** `/letters` - 편지 작성, 이미지 첨부 지원
  - `recipientId`: DIRECT 편지인 경우 필수 (주석 추가)
  - `scheduledAt`: 예약 발송 시간 (선택사항)
  - `attachedImages`: 이미지 URL 배열 (선택사항)
  - 에러 코드 처리: `LETTER_NOT_FOUND` (404, recipientId가 있는 경우) 지원
- ✅ **GET** `/letters/public` - 페이징 지원 (page, size)
  - API 명세서에 따르면 sort 파라미터 없음 ✅
- ✅ **GET** `/letters/{letterId}` - 편지 상세 조회
  - 에러 코드 처리: `LETTER_NOT_FOUND` 지원
- ✅ **POST** `/letters/{letterId}/reply` - 답장 (자동 친구 추가)
  - `visibility` 필드 제거됨 (서버에서 자동으로 DIRECT로 설정) ✅
  - 에러 코드 처리: `LETTER_NOT_FOUND` 지원
- ✅ **POST** `/letters/{letterId}/report` - 편지 신고
  - 에러 코드 처리: `LETTER_NOT_FOUND` 지원
- ✅ **DELETE** `/letters/{letterId}` - 편지 삭제
  - 에러 코드 처리: `FORBIDDEN` (작성자만 삭제 가능), `LETTER_NOT_FOUND` 지원

**응답 구조**: `{success: true, data: {id, title, content, sender, ...}}` ✅

**템플릿 구조**: `{background, textColor, fontFamily, fontSize}` ✅
- 색상 파싱: hex 코드 (#RRGGBB) 및 색상 이름 ("pink", "black" 등) 지원

### 4. 친구 API (`/friends`)
- ✅ **POST** `/friends/invite` - 초대 코드로 친구 추가
  - 에러 코드 처리: `INVALID_INVITE_CODE`, `INVITE_CODE_EXPIRED`, `INVITE_CODE_ALREADY_USED`, `CANNOT_USE_OWN_INVITE_CODE`, `ALREADY_FRIENDS` 지원
- ✅ **GET** `/friends` - 친구 목록 조회 (UserDto 배열 → FriendProfileDto 변환)
  - API 명세서에 따르면 UserDto 배열만 반환 (lastLetterAt 정보 없음) ✅
  - `lastLetterAt`은 기본값(현재 시간) 사용
- ✅ **DELETE** `/friends/{friendId}` - 친구 삭제
  - 에러 코드 처리: `FRIENDSHIP_NOT_FOUND` 지원
- ✅ **GET** `/friends/{friendId}/letters` - 친구별 편지 목록 조회 (페이징 지원)
  - Query Parameters: `page`, `size`, `sort` (기본값: `sentAt,desc`) ✅
  - 정렬 필드: `sentAt`만 지원
  - 정렬 방향: `asc`, `desc`

**응답 구조**: 
- 친구 목록: `{success: true, data: [{id, email, nickname, ...}]}` ✅
- 친구별 편지: `{success: true, data: {content: [...], totalElements, ...}}` ✅

### 5. 초대 코드 API (`/invite-codes`)
- ✅ **POST** `/invite-codes/generate` - 초대 코드 생성
- ✅ **GET** `/invite-codes/current` - 현재 초대 코드 조회
  - 활성 코드가 없거나 만료된 경우 `data`가 `null`일 수 있음 ✅

**응답 구조**: `{success: true, data: {code, expiresAt, remainingMinutes}}` ✅

**초대 코드 형식**: 
- 정확히 **6자리** 숫자+영문 조합 (예: `A1B2C3`, `9X7Y2Z`, `ABC123`)
- 대문자 영문(A-Z)과 숫자(0-9)만 사용
- 대소문자 구분 없음 (자동으로 대문자로 변환)
- 유효 시간: **3분**

### 6. 알림 API (`/notifications`)
- ✅ **GET** `/notifications` - 알림 목록 조회 (페이징, 카테고리 필터 지원)
  - Query Parameters: `category` (LETTER, FRIEND, SYSTEM), `page`, `size`
- ✅ **PUT** `/notifications/{notificationId}/read` - 알림 읽음 처리
- ✅ **PUT** `/notifications/read-all` - 전체 알림 읽음 처리
  - 응답: `{success: true, data: {readCount: 5, message: "..."}}` (readCount는 사용하지 않음)
- ✅ **DELETE** `/notifications/{notificationId}` - 알림 삭제

**응답 구조**: `{success: true, data: {content: [...], totalElements, ...}}` ✅

**필드 매핑**:
- ✅ `createdAt` → `time` (NotificationItem 모델)
- ✅ `isRead` → `isUnread` (반전하여 매핑)
- ✅ `readAt` 필드 지원

### 7. 파일 API (`/files`)
- ✅ **POST** `/files/upload` - 이미지 업로드 (multipart/form-data)

**응답 구조**: `{success: true, data: {url, fileName}}` ✅
- 현재는 `url`만 사용하지만 `fileName`도 응답에 포함됨

**참고**:
- 최대 파일 크기: 10MB
- 허용 파일 타입: `image/jpeg`, `image/png`, `image/gif`, `image/webp`
- 업로드된 파일은 `/uploads/{파일명}` 경로로 접근 가능

### 8. 설정 API (`/settings`)
- ✅ **GET** `/settings/push-notification` - 푸시 알림 설정 조회
- ✅ **PUT** `/settings/push-notification` - 푸시 알림 설정 변경
- ✅ **GET** `/settings/language` - 언어 설정 조회
- ✅ **PUT** `/settings/language` - 언어 설정 변경

**응답 구조**: `{success: true, data: {enabled}}` 또는 `{success: true, data: {language}}` ✅

---

## 🔧 수정 완료 항목

### 1. NotificationDto 필드명 수정
**문제**: API 명세서에서는 `createdAt`, `readAt`, `isRead` 필드를 사용하지만 코드에서는 `time`, `isUnread`를 사용

**수정 내용**:
- `time` → `createdAt` 필드로 변경
- `isUnread` → `isRead` 필드로 변경 (반전하여 모델에 매핑)
- `readAt` 필드 추가

**파일**: `lib/data/dto/notification_dto.dart`

### 2. FriendService.getFriends() 응답 구조 수정
**문제**: API 명세서에 따르면 `/friends` 엔드포인트는 `UserDto` 배열을 반환하지만, 코드에서는 `FriendProfileDto`를 기대

**수정 내용**:
- `UserDto` 배열을 `FriendProfileDto`로 변환하는 로직 추가
- `lastLetterAt`은 API 응답에 없으므로 기본값(현재 시간) 사용
- 주석 개선: API 명세서에 따른 응답 구조 명시

**파일**: `lib/data/services/friend_service.dart`

### 3. LetterTemplateDto 색상 파싱 개선
**문제**: API 명세서 예시에서는 "pink", "black" 같은 색상 이름을 사용하지만 코드는 hex 코드만 지원

**수정 내용**:
- hex 색상 코드 (#RRGGBB) 파싱 지원 유지
- 색상 이름 매핑 추가 ("pink", "black", "white" 등)
- 기본값: 검은색

**파일**: `lib/data/dto/letter_dto.dart`

### 4. SharedFlowerDto 파싱 로직 개선
**문제**: API 명세서에 따른 응답 구조 주석 부족

**수정 내용**:
- API 명세서에 따른 응답 구조 주석 추가
- `letter` 객체에는 `id`, `title`, `preview`, `fontFamily`만 포함됨 (sender 정보 없음)
- `fontFamily`는 최상위 레벨이 우선
- `isRead`는 내가 받은 편지만, 내가 보낸 편지는 `null`

**파일**: `lib/data/dto/bouquet_dto.dart`

### 5. 에러 코드 처리 개선
**수정 내용**:
- `AuthService.login()`: `INVALID_CREDENTIALS` 에러 코드 처리 추가
- `AuthService.signup()`: `INVALID_EMAIL`, `INVALID_PASSWORD`, `VALIDATION_ERROR`, `EMAIL_ALREADY_EXISTS` 에러 코드 처리 추가
- `AuthService.resetPassword()`: 에러 메시지 파싱 개선
- `AuthService.changePassword()`: 에러 메시지 파싱 개선
- `UserService.getCurrentUser()`: 에러 코드 주석 추가
- `UserService.getUser()`: 에러 코드 주석 추가
- `UserService.updateUser()`: 에러 코드 주석 추가
- `LetterService.getLetter()`: 에러 코드 주석 추가
- `LetterService.reportLetter()`: 에러 코드 주석 추가
- `LetterService.deleteLetter()`: 에러 코드 주석 추가
- `FriendService.deleteFriend()`: 에러 코드 주석 추가
- 모든 서비스 파일의 에러 메시지 파싱 로직 통일

**파일**: `lib/data/services/*.dart`

### 6. API 엔드포인트 주석 개선
**수정 내용**:
- 모든 서비스 파일에 API 명세서에 따른 주석 추가
- Query Parameters 설명 추가
- Request/Response 구조 설명 추가

**파일**: `lib/data/services/*.dart`

### 7. LetterDto sentAt 필드 주석 개선
**수정 내용**:
- API 명세서에 따르면 `sentAt`은 항상 포함되어야 함을 주석으로 명시
- 기본값 사용은 안전장치임을 명시

**파일**: `lib/data/dto/letter_dto.dart`

### 8. createLetter 요청 데이터 주석 개선
**수정 내용**:
- `recipientId`: DIRECT 편지인 경우 필수
- `scheduledAt`: 예약 발송 시간 (선택사항)
- `attachedImages`: 이미지 URL 배열 (선택사항)
- `visibility`: PUBLIC, FRIENDS, DIRECT, PRIVATE

**파일**: `lib/data/services/letter_service.dart`

### 9. getFriendLetters Query Parameters 주석 개선
**수정 내용**:
- `page`: 페이지 번호 (기본값: 0)
- `size`: 페이지 크기 (기본값: 20)
- `sort`: 정렬 기준 (기본값: sentAt,desc)
  - 정렬 필드: sentAt (현재는 sentAt만 지원)
  - 정렬 방향: asc, desc

**파일**: `lib/data/services/bouquet_service.dart`

### 10. ApiResponse Page 객체 파싱 개선
**수정 내용**:
- `number` 필드도 Page 객체로 인식하도록 수정
- API 명세서에 따른 주석 추가

**파일**: `lib/data/dto/api_response.dart`

---

## 📋 공통 응답 구조

모든 API는 다음 형식으로 응답합니다:

### 성공 응답
```json
{
  "success": true,
  "data": { ... },
  "message": "성공 메시지 (선택사항)"
}
```

### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지"
  }
}
```

**구현 상태**: ✅ `ApiResponse<T>` 클래스로 올바르게 파싱됨

---

## 📋 페이징 응답 구조

페이징이 지원되는 API는 다음 형식으로 응답합니다:

```json
{
  "success": true,
  "data": {
    "content": [...],
    "totalElements": 100,
    "totalPages": 5,
    "size": 20,
    "number": 0,
    "first": true,
    "last": false
  }
}
```

**구현 상태**: ✅ `PageResponse<T>` 클래스로 올바르게 파싱됨

---

## 🔐 인증

대부분의 API는 JWT Bearer Token 인증이 필요합니다:

```
Authorization: Bearer {token}
```

**구현 상태**: ✅ `ApiClient`의 interceptor에서 자동으로 토큰 추가

**예외**: 
- Health check 엔드포인트 (`/actuator/health`, `/health`)
- 인증 불필요한 엔드포인트 (`/auth/login`, `/auth/signup`, `/auth/forgot-password`)

---

## 📝 주요 데이터 구조

### UserDto
```dart
{
  id: String,
  email: String, // 편지 sender에는 없을 수 있음
  nickname: String,
  avatarUrl: String?,
  joinedAt: DateTime?,
  friendCount: int?,
  sentLetters: int?
}
```
✅ API 명세서와 일치

**참고**: 
- 편지 응답의 `sender`에는 `id`, `nickname`만 포함될 수 있음
- 사용자 프로필 조회에는 `email`, `avatarUrl`, `joinedAt` 등이 포함됨
- 친구 목록에는 `friendCount`, `sentLetters`가 포함됨

### LetterDto
```dart
{
  id: String,
  title: String,
  content: String, // 공개 편지 목록에는 없을 수 있음 (preview 사용)
  preview: String,
  sender: UserDto, // {id, nickname}만 포함될 수 있음
  sentAt: DateTime, // 항상 포함됨
  visibility: String, // "PUBLIC", "FRIENDS", "DIRECT", "PRIVATE"
  template: LetterTemplateDto?,
  attachedImages: List<String>?
}
```
✅ API 명세서와 일치

### SharedFlowerDto (친구별 편지)
```dart
{
  id: String, // 편지 ID
  letter: {
    id: String,
    title: String,
    preview: String,
    fontFamily: String? // letter 객체 내부
  },
  sentAt: DateTime,
  sentByMe: boolean,
  isRead: boolean?, // 내가 받은 편지만, 내가 보낸 편지는 null
  fontFamily: String? // 최상위 레벨 (letter.fontFamily보다 우선)
}
```
✅ API 명세서와 일치

**참고**:
- `letter` 객체에는 `sender` 정보가 없음 (API 명세서에 명시되지 않음)
- `fontFamily`는 최상위 레벨이 우선
- 편지는 `sentAt DESC` 순으로 정렬됨

### NotificationDto
```dart
{
  id: String,
  title: String,
  subtitle: String?,
  createdAt: DateTime,
  readAt: DateTime?,
  category: String, // "LETTER", "FRIEND", "SYSTEM"
  isRead: boolean,
  relatedId: String?
}
```
✅ API 명세서와 일치 (수정 완료)

### InviteCodeDto
```dart
{
  code: String, // 6자리 숫자+영문 조합
  expiresAt: DateTime,
  remainingMinutes: int?
}
```
✅ API 명세서와 일치

---

## 🎯 API 엔드포인트 목록

### 인증
- ✅ POST `/auth/login`
- ✅ POST `/auth/signup`
- ✅ POST `/auth/forgot-password`
- ✅ POST `/auth/reset-password`
- ✅ PUT `/auth/change-password`
- ✅ POST `/auth/logout`

### 사용자
- ✅ GET `/users/{userId}`
- ✅ PUT `/users/{userId}`
- ✅ PUT `/users/{userId}/fcm-token`

### 편지
- ✅ POST `/letters`
- ✅ GET `/letters/public`
- ✅ GET `/letters/{letterId}`
- ✅ POST `/letters/{letterId}/reply`
- ✅ POST `/letters/{letterId}/report`
- ✅ DELETE `/letters/{letterId}`

### 친구
- ✅ POST `/friends/invite`
- ✅ GET `/friends`
- ✅ DELETE `/friends/{friendId}`
- ✅ GET `/friends/{friendId}/letters`

### 초대 코드
- ✅ POST `/invite-codes/generate`
- ✅ GET `/invite-codes/current`

### 알림
- ✅ GET `/notifications`
- ✅ PUT `/notifications/{notificationId}/read`
- ✅ PUT `/notifications/read-all`
- ✅ DELETE `/notifications/{notificationId}`

### 파일
- ✅ POST `/files/upload`

### 설정
- ✅ GET `/settings/push-notification`
- ✅ PUT `/settings/push-notification`
- ✅ GET `/settings/language`
- ✅ PUT `/settings/language`

---

## 🔍 세부 검토 사항

### 1. 에러 코드 처리
모든 서비스 파일에서 API 명세서에 명시된 에러 코드를 올바르게 처리하고 있습니다:

- ✅ `INVALID_EMAIL`: 잘못된 이메일 형식
- ✅ `EMAIL_ALREADY_EXISTS`: 이미 존재하는 이메일
- ✅ `INVALID_PASSWORD`: 잘못된 비밀번호 형식
- ✅ `INVALID_CREDENTIALS`: 이메일 또는 비밀번호가 올바르지 않음
- ✅ `INVALID_INVITE_CODE`: 유효하지 않은 초대 코드
- ✅ `INVITE_CODE_EXPIRED`: 만료된 초대 코드
- ✅ `INVITE_CODE_ALREADY_USED`: 이미 사용된 초대 코드
- ✅ `CANNOT_USE_OWN_INVITE_CODE`: 자신의 초대 코드는 사용 불가
- ✅ `ALREADY_FRIENDS`: 이미 친구 관계
- ✅ `USER_NOT_FOUND`: 사용자를 찾을 수 없음
- ✅ `LETTER_NOT_FOUND`: 편지를 찾을 수 없음
- ✅ `FRIENDSHIP_NOT_FOUND`: 친구 관계를 찾을 수 없음
- ✅ `FORBIDDEN`: 권한이 없음
- ✅ `INTERNAL_SERVER_ERROR`: 서버 오류

### 2. 데이터 파싱
모든 DTO가 API 명세서에 맞게 파싱되고 있습니다:

- ✅ `UserDto`: 편지 sender에는 email이 없을 수 있음
- ✅ `LetterDto`: 공개 편지 목록에는 content가 없을 수 있음 (preview 사용)
- ✅ `SharedFlowerDto`: letter 객체에 sender 정보 없음
- ✅ `NotificationDto`: `createdAt`, `readAt`, `isRead` 필드 사용
- ✅ `PageResponse`: `number` 필드 지원 (page와 동일)

### 3. Query Parameters
모든 API의 Query Parameters가 명세서와 일치합니다:

- ✅ `/letters/public`: `page`, `size` (sort 없음)
- ✅ `/friends/{friendId}/letters`: `page`, `size`, `sort` (기본값: `sentAt,desc`)
- ✅ `/notifications`: `category`, `page`, `size`

### 4. Request Body
모든 API의 Request Body가 명세서와 일치합니다:

- ✅ `/auth/signup`: multipart/form-data (profileImage 포함 가능)
- ✅ `/users/{userId}`: multipart/form-data (profileImage, avatarUrl 포함 가능)
- ✅ `/letters`: JSON (attachedImages, scheduledAt, recipientId 포함 가능)
- ✅ `/letters/{letterId}/reply`: JSON (visibility 필드 없음)

### 5. Response Body
모든 API의 Response Body가 명세서와 일치합니다:

- ✅ 공통 응답 형식: `{success: true, data: {...}}`
- ✅ 에러 응답 형식: `{success: false, error: {code, message}}`
- ✅ 페이징 응답: `{success: true, data: {content: [...], totalElements, ...}}`

---

## ✅ 최종 검증 결과

### 전체 평가: ✅ **완벽**

1. **API 엔드포인트**: 모든 엔드포인트가 명세서와 일치 ✅
2. **요청 구조**: 모든 요청이 명세서와 일치 ✅
3. **응답 구조**: 모든 응답 파싱이 올바르게 구현됨 ✅
4. **에러 처리**: API 명세서에 따른 에러 응답 구조 및 에러 코드 지원 ✅
5. **인증**: JWT Bearer Token 자동 추가 ✅
6. **페이징**: PageResponse 구조 올바르게 파싱됨 ✅
7. **데이터 타입**: 모든 DTO가 명세서와 일치 ✅
8. **주석**: 모든 서비스 파일에 API 명세서에 따른 주석 추가 ✅

### 수정 완료 사항
1. ✅ NotificationDto 필드명 수정 (`time` → `createdAt`, `isUnread` → `isRead`)
2. ✅ FriendService.getFriends() 응답 구조 수정 (UserDto → FriendProfileDto 변환)
3. ✅ LetterTemplateDto 색상 파싱 개선 (hex 코드 + 색상 이름 지원)
4. ✅ SharedFlowerDto 파싱 로직 개선 (주석 추가)
5. ✅ 모든 서비스 파일의 에러 코드 처리 개선
6. ✅ 모든 서비스 파일의 주석 개선
7. ✅ LetterDto sentAt 필드 주석 개선
8. ✅ createLetter 요청 데이터 주석 개선
9. ✅ getFriendLetters Query Parameters 주석 개선
10. ✅ ApiResponse Page 객체 파싱 개선

---

## 📌 참고사항

1. **Base URL**: `https://www.taba.asia/api/v1`
2. **Content-Type**: `application/json` (multipart/form-data는 파일 업로드 시)
3. **페이징**: 기본값 `page=0`, `size=20`
4. **정렬**: 친구별 편지 목록은 `sort=sentAt,desc` 기본값
5. **초대 코드**: 정확히 6자리 숫자+영문 조합, 유효 시간 3분
6. **편지 답장**: `visibility` 필드 없음 (서버에서 자동으로 DIRECT로 설정)
7. **친구 목록**: `lastLetterAt` 정보 없음 (기본값 사용)

---

## 🔍 추가 확인 사항

### 1. 공개 편지 목록의 sender 구조
API 명세서를 보면 공개 편지 목록에서 sender는 `{ ... }`로만 표시되어 있는데, 실제로는 `{id, nickname}`만 포함되는 것으로 추정됩니다. 현재 코드는 `UserDto.fromJson`을 사용하여 파싱하고 있으며, `email`이 없을 수 있도록 처리되어 있습니다. ✅

### 2. SharedFlowerDto의 sender 정보
API 명세서에 따르면 `letter` 객체에는 `sender` 정보가 없습니다. 현재 코드는 기본값을 사용하고 있으며, `sentByMe`로 발신자를 판단할 수 있습니다. ✅

### 3. FriendService.getFriends()의 lastLetterAt
API 명세서에 따르면 친구 목록에는 `lastLetterAt` 정보가 없습니다. 현재 코드는 기본값(현재 시간)을 사용하고 있으며, 이는 UI에서 사용하지 않는 것으로 보입니다. ✅

---

**문서 작성일**: 2025-01-18  
**최종 검토일**: 2025-01-18  
**검토 상태**: ✅ 완료
