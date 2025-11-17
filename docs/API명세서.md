# Taba API 명세서

## 기본 정보

- **Base URL**: `https://api.taba.app`
- **API Version**: `v1`
- **인증 방식**: JWT Bearer Token
- **Content-Type**: `application/json`
- **Charset**: `UTF-8`

## 공통 응답 형식

### 성공 응답
```json
{
  "success": true,
  "data": { ... },
  "message": "성공 메시지"
}
```

### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": { ... }
  }
}
```

## 인증

### JWT 토큰
- **헤더**: `Authorization: Bearer {token}`
- **만료 시간**: 7일
- **리프레시 토큰**: 별도 지원 (선택사항)

## API 엔드포인트

### 1. 인증 (Authentication)

#### 1.1 회원가입
```
POST /api/v1/auth/signup
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "nickname": "사용자닉네임",
  "agreeTerms": true,
  "agreePrivacy": true
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "userId": "uuid",
    "token": "jwt_token",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "user123",
      "nickname": "사용자닉네임",
      "avatarUrl": null,
      "statusMessage": "",
      "joinedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

#### 1.2 로그인
```
POST /api/v1/auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "user123",
      "nickname": "사용자닉네임",
      "avatarUrl": "https://...",
      "statusMessage": "상태 메시지",
      "joinedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

#### 1.3 비밀번호 찾기
```
POST /api/v1/auth/forgot-password
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "비밀번호 재설정 링크가 이메일로 전송되었습니다."
}
```

#### 1.4 비밀번호 재설정
```
POST /api/v1/auth/reset-password
```

**Request Body:**
```json
{
  "token": "reset_token",
  "newPassword": "newpassword123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "비밀번호가 재설정되었습니다."
}
```

#### 1.5 비밀번호 변경
```
PUT /api/v1/auth/change-password
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "currentPassword": "oldpassword",
  "newPassword": "newpassword123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "비밀번호가 변경되었습니다."
}
```

#### 1.6 로그아웃
```
POST /api/v1/auth/logout
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "로그아웃되었습니다."
}
```

### 2. 사용자 (User)

#### 2.1 프로필 조회
```
GET /api/v1/users/{userId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "user123",
    "nickname": "사용자닉네임",
    "avatarUrl": "https://...",
    "statusMessage": "상태 메시지",
    "joinedAt": "2024-01-01T00:00:00Z",
    "friendCount": 10,
    "sentLetters": 25
  }
}
```

#### 2.2 프로필 수정
```
PUT /api/v1/users/{userId}
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "nickname": "새닉네임",
  "statusMessage": "새 상태 메시지",
  "avatarUrl": "https://..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "nickname": "새닉네임",
    "statusMessage": "새 상태 메시지",
    "avatarUrl": "https://...",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

### 3. 편지 (Letter)

#### 3.1 편지 작성
```
POST /api/v1/letters
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "편지 제목",
  "content": "편지 내용",
  "preview": "미리보기 텍스트",
  "flowerType": "ROSE",
  "visibility": "PUBLIC",
  "isAnonymous": false,
  "template": {
    "background": "#000000",
    "textColor": "#FFFFFF",
    "fontFamily": "Jua",
    "fontSize": 16.0
  },
  "attachedImages": [
    "https://...",
    "https://..."
  ],
  "scheduledAt": "2024-01-01T12:00:00Z",
  "recipientId": "uuid"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "편지 제목",
    "content": "편지 내용",
    "preview": "미리보기 텍스트",
    "sender": {
      "id": "uuid",
      "nickname": "사용자닉네임",
      "avatarUrl": "https://..."
    },
    "flowerType": "ROSE",
    "sentAt": "2024-01-01T00:00:00Z",
    "likes": 0,
    "views": 0,
    "savedCount": 0,
    "attachedImages": ["https://..."],
    "template": { ... }
  }
}
```

#### 3.2 공개 편지 목록 조회 (하늘)
```
GET /api/v1/letters/public
Authorization: Bearer {token}
```

**Query Parameters:**
- `page`: Integer (기본값: 0)
- `size`: Integer (기본값: 20)
- `sort`: String (기본값: "sentAt,desc")

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "uuid",
        "title": "편지 제목",
        "preview": "미리보기",
        "sender": {
          "id": "uuid",
          "nickname": "사용자닉네임",
          "avatarUrl": "https://..."
        },
        "flowerType": "ROSE",
        "sentAt": "2024-01-01T00:00:00Z",
        "likes": 10,
        "views": 50,
        "position": {
          "x": 0.3,
          "y": 0.5
        }
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 100,
    "totalPages": 5
  }
}
```

#### 3.3 편지 상세 조회
```
GET /api/v1/letters/{letterId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "편지 제목",
    "content": "편지 내용",
    "sender": {
      "id": "uuid",
      "nickname": "사용자닉네임",
      "avatarUrl": "https://..."
    },
    "flowerType": "ROSE",
    "sentAt": "2024-01-01T00:00:00Z",
    "likes": 10,
    "views": 51,
    "savedCount": 5,
    "isLiked": false,
    "isSaved": false,
    "attachedImages": ["https://..."],
    "template": { ... }
  }
}
```

#### 3.4 편지 좋아요
```
POST /api/v1/letters/{letterId}/like
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "likes": 11,
    "isLiked": true
  }
}
```

#### 3.5 편지 저장
```
POST /api/v1/letters/{letterId}/save
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "savedCount": 6,
    "isSaved": true
  }
}
```

#### 3.6 편지 신고
```
POST /api/v1/letters/{letterId}/report
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "reason": "신고 사유"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "신고가 접수되었습니다."
}
```

#### 3.7 편지 삭제
```
DELETE /api/v1/letters/{letterId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "편지가 삭제되었습니다."
}
```

### 4. 꽃다발 (Bouquet)

#### 4.1 친구 목록 조회 (꽃다발)
```
GET /api/v1/bouquets
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "friend": {
        "id": "uuid",
        "nickname": "친구닉네임",
        "avatarUrl": "https://...",
        "lastLetterAt": "2024-01-01T00:00:00Z",
        "friendCount": 5,
        "sentLetters": 10
      },
      "sharedFlowers": [
        {
          "id": "uuid",
          "letter": {
            "id": "uuid",
            "title": "편지 제목",
            "preview": "미리보기"
          },
          "flowerType": "ROSE",
          "sentAt": "2024-01-01T00:00:00Z",
          "sentByMe": true,
          "isRead": true
        }
      ],
      "bloomLevel": 0.75,
      "trustScore": 80,
      "bouquetName": "우리 꽃다발",
      "unreadCount": 2
    }
  ]
}
```

#### 4.2 친구별 편지 목록 조회
```
GET /api/v1/bouquets/{friendId}/letters
Authorization: Bearer {token}
```

**Query Parameters:**
- `page`: Integer
- `size`: Integer

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [ ... ],
    "page": 0,
    "size": 20,
    "totalElements": 50,
    "totalPages": 3
  }
}
```

#### 4.3 꽃다발 이름 변경
```
PUT /api/v1/bouquets/{friendId}/name
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "bouquetName": "새 꽃다발 이름"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "bouquetName": "새 꽃다발 이름"
  }
}
```

### 5. 친구 (Friend)

#### 5.1 친구 추가 (초대 코드)
```
POST /api/v1/friends/invite
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "inviteCode": "USER-123456"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "user": {
      "id": "uuid",
      "nickname": "친구닉네임",
      "avatarUrl": "https://..."
    },
    "lastLetterAt": "2024-01-01T00:00:00Z",
    "friendCount": 5,
    "sentLetters": 10
  }
}
```

#### 5.2 친구 목록 조회
```
GET /api/v1/friends
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "user": {
        "id": "uuid",
        "nickname": "친구닉네임",
        "avatarUrl": "https://..."
      },
      "lastLetterAt": "2024-01-01T00:00:00Z",
      "friendCount": 5,
      "sentLetters": 10
    }
  ]
}
```

#### 5.3 친구 삭제
```
DELETE /api/v1/friends/{friendId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "친구 관계가 삭제되었습니다."
}
```

### 6. 초대 코드 (Invite Code)

#### 6.1 초대 코드 생성
```
POST /api/v1/invite-codes/generate
Authorization: Bearer {token}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "code": "USER-123456",
    "expiresAt": "2024-01-01T00:03:00Z",
    "remainingMinutes": 3
  }
}
```

#### 6.2 초대 코드 조회
```
GET /api/v1/invite-codes/current
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "code": "USER-123456",
    "expiresAt": "2024-01-01T00:03:00Z",
    "remainingMinutes": 2
  }
}
```

### 7. 알림 (Notification)

#### 7.1 알림 목록 조회
```
GET /api/v1/notifications
Authorization: Bearer {token}
```

**Query Parameters:**
- `page`: Integer
- `size`: Integer
- `category`: String (LETTER, REACTION, FRIEND, SYSTEM)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "uuid",
        "title": "알림 제목",
        "subtitle": "알림 내용",
        "time": "2024-01-01T00:00:00Z",
        "category": "LETTER",
        "isUnread": true,
        "relatedId": "uuid"
      }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 10,
    "totalPages": 1
  }
}
```

#### 7.2 알림 읽음 처리
```
PUT /api/v1/notifications/{notificationId}/read
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "isUnread": false,
    "readAt": "2024-01-01T00:00:00Z"
  }
}
```

#### 7.3 알림 전체 읽음 처리
```
PUT /api/v1/notifications/read-all
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "readCount": 10,
    "message": "모든 알림이 읽음 처리되었습니다."
  }
}
```

### 8. 설정 (Settings)

#### 8.1 푸시 알림 설정 조회
```
GET /api/v1/settings/push-notification
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "enabled": true
  }
}
```

#### 8.2 푸시 알림 설정 변경
```
PUT /api/v1/settings/push-notification
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "enabled": false
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "enabled": false
  }
}
```

#### 8.3 언어 설정 조회
```
GET /api/v1/settings/language
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "language": "ko"
  }
}
```

#### 8.4 언어 설정 변경
```
PUT /api/v1/settings/language
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "language": "en"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "language": "en"
  }
}
```

### 9. 파일 업로드

#### 9.1 이미지 업로드
```
POST /api/v1/files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request:**
- `file`: File (이미지 파일)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.taba.app/images/uuid.jpg",
    "fileName": "image.jpg"
  }
}
```

## 에러 코드

| 코드 | HTTP 상태 | 설명 |
|------|-----------|------|
| `INVALID_EMAIL` | 400 | 잘못된 이메일 형식 |
| `EMAIL_ALREADY_EXISTS` | 400 | 이미 존재하는 이메일 |
| `INVALID_PASSWORD` | 400 | 잘못된 비밀번호 형식 |
| `UNAUTHORIZED` | 401 | 인증 실패 |
| `TOKEN_EXPIRED` | 401 | 토큰 만료 |
| `FORBIDDEN` | 403 | 권한 없음 |
| `LETTER_NOT_FOUND` | 404 | 편지를 찾을 수 없음 |
| `USER_NOT_FOUND` | 404 | 사용자를 찾을 수 없음 |
| `INVALID_INVITE_CODE` | 400 | 유효하지 않은 초대 코드 |
| `INVITE_CODE_EXPIRED` | 400 | 만료된 초대 코드 |
| `FRIEND_ALREADY_EXISTS` | 400 | 이미 친구 관계가 존재함 |
| `INTERNAL_SERVER_ERROR` | 500 | 서버 오류 |

## 페이징

모든 목록 조회 API는 페이징을 지원합니다.

**Query Parameters:**
- `page`: 페이지 번호 (0부터 시작, 기본값: 0)
- `size`: 페이지 크기 (기본값: 20, 최대: 100)
- `sort`: 정렬 기준 (예: "sentAt,desc")

**Response Format:**
```json
{
  "content": [ ... ],
  "page": 0,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5,
  "first": true,
  "last": false
}
```

## 날짜/시간 형식

- **ISO 8601 형식**: `2024-01-01T00:00:00Z`
- **타임존**: UTC
- 클라이언트에서 로컬 타임존으로 변환

## Rate Limiting

- **일반 API**: 100 requests/minute
- **인증 API**: 10 requests/minute
- **파일 업로드**: 20 requests/minute

## 버전 관리

API 버전은 URL 경로에 포함됩니다:
- `v1`: 현재 버전
- 향후 `v2` 등으로 확장 가능

