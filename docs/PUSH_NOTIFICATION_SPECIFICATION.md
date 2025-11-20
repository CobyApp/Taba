# 푸시 알림 명세서

## 📋 목차
1. [개요](#개요)
2. [FCM 토큰 관리](#fcm-토큰-관리)
3. [푸시 알림 시나리오](#푸시-알림-시나리오)
4. [푸시 메시지 구조](#푸시-메시지-구조)
5. [딥링크 처리](#딥링크-처리)
6. [서버 구현 가이드](#서버-구현-가이드)
7. [클라이언트 구현](#클라이언트-구현)

---

## 1. 개요

Taba 앱은 Firebase Cloud Messaging (FCM)을 사용하여 푸시 알림을 전송합니다. 
서버에서 푸시 알림을 보낼 때는 **딥링크 정보를 포함**하여 사용자가 알림을 탭했을 때 해당 화면으로 바로 이동할 수 있도록 합니다.

### 주요 특징
- ✅ FCM 토큰 자동 등록 및 갱신
- ✅ 포그라운드/백그라운드/앱 종료 상태 모두 지원
- ✅ 딥링크를 통한 화면 자동 이동
- ✅ 사용자별 푸시 알림 설정 (ON/OFF)

---

## 2. FCM 토큰 관리

### 2.1 토큰 등록

**시점**: 사용자 로그인 또는 회원가입 성공 시

**API**: `PUT /users/{userId}/fcm-token`

**Request Body**:
```json
{
  "fcmToken": "string"
}
```

**Response**:
```json
{
  "success": true,
  "data": null
}
```

### 2.2 토큰 갱신

클라이언트에서 FCM 토큰이 갱신되면 자동으로 서버에 업데이트 요청을 보냅니다.

**API**: `PUT /users/{userId}/fcm-token`

### 2.3 토큰 삭제

**시점**: 사용자 로그아웃 시

**API**: `DELETE /users/{userId}/fcm-token` (선택사항)

또는 클라이언트에서 `FirebaseMessaging.deleteToken()` 호출

---

## 3. 푸시 알림 시나리오

### 3.1 새 편지 수신 (DIRECT)

**발생 시점**: 친구가 나에게 직접 편지를 보냈을 때

**조건**:
- 수신자의 푸시 알림 설정이 ON인 경우
- 편지의 `visibility`가 `DIRECT`인 경우

**알림 내용**:
- 제목: `"{친구닉네임}님이 편지를 보냈어요"`
- 본문: `"{편지제목}"` 또는 `"{편지미리보기}"`

**딥링크**: 편지 상세 화면으로 이동

### 3.2 공개 편지에 반응 받음

**발생 시점**: 내가 작성한 공개 편지에 다른 사용자가 반응을 남겼을 때

**조건**:
- 수신자의 푸시 알림 설정이 ON인 경우
- 반응을 남긴 사용자가 나와 친구가 아닌 경우 (선택사항)

**알림 내용**:
- 제목: `"누군가 당신의 편지에 반응했어요"`
- 본문: `"{편지제목}"`

**딥링크**: 편지 상세 화면으로 이동

### 3.3 친구 요청 수락

**발생 시점**: 내가 보낸 친구 요청이 수락되었을 때

**조건**:
- 수신자의 푸시 알림 설정이 ON인 경우

**알림 내용**:
- 제목: `"{친구닉네임}님이 친구 요청을 수락했어요"`
- 본문: `"이제 서로 편지를 주고받을 수 있어요"`

**딥링크**: 꽃다발 화면으로 이동

### 3.4 친구 추가됨 (초대 코드 사용)

**발생 시점**: 내 초대 코드로 다른 사용자가 친구 추가를 했을 때

**조건**:
- 수신자의 푸시 알림 설정이 ON인 경우

**알림 내용**:
- 제목: `"{친구닉네임}님이 친구로 추가되었어요"`
- 본문: `"이제 서로 편지를 주고받을 수 있어요"`

**딥링크**: 꽃다발 화면으로 이동

### 3.5 시스템 알림

**발생 시점**: 서버에서 중요한 공지사항이나 업데이트 알림을 보낼 때

**조건**:
- 수신자의 푸시 알림 설정이 ON인 경우

**알림 내용**:
- 제목: 서버에서 정의
- 본문: 서버에서 정의

**딥링크**: 알림 센터 또는 메인 화면

---

## 4. 푸시 메시지 구조

### 4.1 FCM 메시지 형식

서버에서 FCM으로 푸시 알림을 보낼 때는 다음 구조를 따라야 합니다:

```json
{
  "notification": {
    "title": "알림 제목",
    "body": "알림 본문"
  },
  "data": {
    "category": "LETTER|REACTION|FRIEND|SYSTEM",
    "relatedId": "string (optional)",
    "deepLink": "string (optional)",
    "notificationId": "string (optional)"
  },
  "token": "fcm_token"
}
```

### 4.2 데이터 필드 설명

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `category` | string | ✅ | 알림 카테고리 (`LETTER`, `REACTION`, `FRIEND`, `SYSTEM`) |
| `relatedId` | string | ❌ | 관련 리소스 ID (편지 ID, 알림 ID 등) |
| `deepLink` | string | ❌ | 딥링크 경로 (선택사항, 없으면 category 기반으로 처리) |
| `notificationId` | string | ❌ | 알림 ID (알림 읽음 처리용) |

### 4.3 Category별 데이터 예시

#### LETTER (새 편지)
```json
{
  "category": "LETTER",
  "relatedId": "letter_123",
  "deepLink": "/letter/letter_123"
}
```

#### REACTION (반응)
```json
{
  "category": "REACTION",
  "relatedId": "letter_456",
  "deepLink": "/letter/letter_456"
}
```

#### FRIEND (친구 관련)
```json
{
  "category": "FRIEND",
  "relatedId": "friend_789",
  "deepLink": "/bouquet"
}
```

#### SYSTEM (시스템 알림)
```json
{
  "category": "SYSTEM",
  "notificationId": "notification_001",
  "deepLink": "/notifications"
}
```

---

## 5. 딥링크 처리

### 5.1 딥링크 형식

딥링크는 다음과 같은 형식을 따릅니다:

```
taba://{path}?{query}
```

또는

```
/{path}?{query}
```

### 5.2 지원하는 딥링크 경로

| 경로 | 설명 | 예시 |
|------|------|------|
| `/letter/{letterId}` | 편지 상세 화면 | `/letter/letter_123` |
| `/bouquet` | 꽃다발 화면 | `/bouquet` |
| `/bouquet/{friendId}` | 특정 친구의 꽃다발 | `/bouquet/friend_456` |
| `/notifications` | 알림 센터 | `/notifications` |
| `/write` | 편지 작성 화면 | `/write` |
| `/write?replyTo={letterId}` | 답장 작성 화면 | `/write?replyTo=letter_123` |
| `/settings` | 설정 화면 | `/settings` |

### 5.3 딥링크 처리 우선순위

1. **`deepLink` 필드가 있는 경우**: `deepLink` 값을 우선 사용
2. **`deepLink` 필드가 없는 경우**: `category`와 `relatedId`를 기반으로 자동 생성

### 5.4 딥링크 자동 생성 규칙

| Category | relatedId | 생성된 딥링크 |
|----------|-----------|---------------|
| `LETTER` | `letter_123` | `/letter/letter_123` |
| `REACTION` | `letter_456` | `/letter/letter_456` |
| `FRIEND` | `friend_789` | `/bouquet/friend_789` |
| `FRIEND` | 없음 | `/bouquet` |
| `SYSTEM` | 없음 | `/notifications` |

---

## 6. 서버 구현 가이드

### 6.1 푸시 알림 전송 전 확인사항

1. ✅ 수신자의 FCM 토큰이 등록되어 있는지 확인
2. ✅ 수신자의 푸시 알림 설정이 ON인지 확인 (`GET /settings/push-notification`)
3. ✅ FCM 토큰이 유효한지 확인 (만료된 토큰은 제외)

### 6.2 푸시 알림 전송 예시

#### Node.js (Firebase Admin SDK)

```javascript
const admin = require('firebase-admin');

async function sendPushNotification(userId, category, relatedId, title, body) {
  // 1. 사용자 정보 조회
  const user = await getUserById(userId);
  if (!user.fcmToken) {
    console.log('FCM 토큰이 없습니다.');
    return;
  }

  // 2. 푸시 알림 설정 확인
  const pushEnabled = await getPushNotificationSetting(userId);
  if (!pushEnabled) {
    console.log('푸시 알림이 비활성화되어 있습니다.');
    return;
  }

  // 3. 딥링크 생성
  const deepLink = generateDeepLink(category, relatedId);

  // 4. FCM 메시지 구성
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      category: category,
      relatedId: relatedId || '',
      deepLink: deepLink,
    },
    token: user.fcmToken,
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        channelId: 'taba_notifications',
      },
    },
  };

  // 5. 푸시 알림 전송
  try {
    const response = await admin.messaging().send(message);
    console.log('푸시 알림 전송 성공:', response);
    
    // 6. 알림 기록 생성 (선택사항)
    await createNotification({
      userId: userId,
      category: category,
      relatedId: relatedId,
      title: title,
      body: body,
    });
  } catch (error) {
    console.error('푸시 알림 전송 실패:', error);
    
    // FCM 토큰이 만료된 경우 삭제
    if (error.code === 'messaging/registration-token-not-registered') {
      await deleteFcmToken(userId);
    }
  }
}

function generateDeepLink(category, relatedId) {
  switch (category) {
    case 'LETTER':
    case 'REACTION':
      return `/letter/${relatedId}`;
    case 'FRIEND':
      return relatedId ? `/bouquet/${relatedId}` : '/bouquet';
    case 'SYSTEM':
      return '/notifications';
    default:
      return '/';
  }
}
```

#### 편지 수신 시 푸시 알림 전송

```javascript
// 편지 생성 후
async function onLetterCreated(letter) {
  if (letter.visibility === 'DIRECT' && letter.recipientId) {
    const recipient = await getUserById(letter.recipientId);
    
    await sendPushNotification(
      letter.recipientId,
      'LETTER',
      letter.id,
      `${letter.sender.nickname}님이 편지를 보냈어요`,
      letter.title || letter.preview || '새 편지가 도착했어요'
    );
  }
}
```

#### 반응 받을 시 푸시 알림 전송

```javascript
// 반응 생성 후
async function onReactionCreated(reaction) {
  const letter = await getLetterById(reaction.letterId);
  
  // 편지 작성자에게 알림
  if (letter.senderId !== reaction.userId) {
    await sendPushNotification(
      letter.senderId,
      'REACTION',
      letter.id,
      '누군가 당신의 편지에 반응했어요',
      letter.title || '새 반응이 도착했어요'
    );
  }
}
```

#### 친구 추가 시 푸시 알림 전송

```javascript
// 친구 추가 후
async function onFriendAdded(friendRequest) {
  // 요청을 보낸 사용자에게 알림
  await sendPushNotification(
    friendRequest.requesterId,
    'FRIEND',
    friendRequest.friendId,
    `${friendRequest.friend.nickname}님이 친구로 추가되었어요`,
    '이제 서로 편지를 주고받을 수 있어요'
  );
  
  // 요청을 받은 사용자에게도 알림 (선택사항)
  await sendPushNotification(
    friendRequest.friendId,
    'FRIEND',
    friendRequest.requesterId,
    `${friendRequest.requester.nickname}님이 친구로 추가되었어요`,
    '이제 서로 편지를 주고받을 수 있어요'
  );
}
```

### 6.3 배치 푸시 알림 전송

여러 사용자에게 동일한 알림을 보낼 때:

```javascript
async function sendBatchPushNotifications(userIds, category, title, body) {
  const messages = [];
  
  for (const userId of userIds) {
    const user = await getUserById(userId);
    if (!user.fcmToken) continue;
    
    const pushEnabled = await getPushNotificationSetting(userId);
    if (!pushEnabled) continue;
    
    messages.push({
      notification: {
        title: title,
        body: body,
      },
      data: {
        category: category,
        deepLink: '/notifications',
      },
      token: user.fcmToken,
    });
  }
  
  if (messages.length > 0) {
    try {
      const response = await admin.messaging().sendAll(messages);
      console.log(`성공: ${response.successCount}, 실패: ${response.failureCount}`);
    } catch (error) {
      console.error('배치 푸시 알림 전송 실패:', error);
    }
  }
}
```

---

## 7. 클라이언트 구현

### 7.1 푸시 알림 수신 처리

클라이언트는 다음과 같이 푸시 알림을 처리합니다:

1. **포그라운드**: 스낵바로 알림 표시 + 데이터 새로고침
2. **백그라운드**: 시스템 알림 표시, 탭 시 딥링크 처리
3. **앱 종료 상태**: 시스템 알림 표시, 탭 시 앱 실행 후 딥링크 처리

### 7.2 딥링크 처리 로직

```dart
Future<void> _handlePushNotificationTap(RemoteMessage message) async {
  final data = message.data;
  final deepLink = data['deepLink'] as String?;
  final category = data['category'] as String?;
  final relatedId = data['relatedId'] as String?;
  
  // 1. deepLink가 있으면 우선 사용
  if (deepLink != null && deepLink.isNotEmpty) {
    _navigateToDeepLink(deepLink);
    return;
  }
  
  // 2. category와 relatedId로 자동 생성
  if (category != null) {
    switch (category.toUpperCase()) {
      case 'LETTER':
      case 'REACTION':
        if (relatedId != null) {
          _navigateToLetter(relatedId);
        }
        break;
      case 'FRIEND':
        if (relatedId != null) {
          _navigateToBouquet(relatedId);
        } else {
          _navigateToBouquet();
        }
        break;
      case 'SYSTEM':
        _navigateToNotifications();
        break;
    }
  }
}
```

### 7.3 딥링크 파싱 및 네비게이션

```dart
void _navigateToDeepLink(String deepLink) {
  // taba:// 제거
  String path = deepLink.replaceFirst(RegExp(r'^taba://'), '');
  path = path.replaceFirst(RegExp(r'^/'), '');
  
  final uri = Uri.parse('/$path');
  final segments = uri.pathSegments;
  
  if (segments.isEmpty) return;
  
  switch (segments[0]) {
    case 'letter':
      if (segments.length > 1) {
        _navigateToLetter(segments[1]);
      }
      break;
    case 'bouquet':
      if (segments.length > 1) {
        _navigateToBouquet(segments[1]);
      } else {
        _navigateToBouquet();
      }
      break;
    case 'notifications':
      _navigateToNotifications();
      break;
    case 'write':
      final replyTo = uri.queryParameters['replyTo'];
      _navigateToWrite(replyTo: replyTo);
      break;
    case 'settings':
      _navigateToSettings();
      break;
  }
}
```

---

## 8. 테스트 가이드

### 8.1 테스트 시나리오

1. **새 편지 수신**
   - 친구가 직접 편지 보내기
   - 푸시 알림 수신 확인
   - 알림 탭 시 편지 상세 화면 이동 확인

2. **반응 받기**
   - 공개 편지에 반응 남기기
   - 편지 작성자에게 푸시 알림 전송 확인
   - 알림 탭 시 편지 상세 화면 이동 확인

3. **친구 추가**
   - 초대 코드로 친구 추가
   - 양쪽 사용자에게 푸시 알림 전송 확인
   - 알림 탭 시 꽃다발 화면 이동 확인

4. **푸시 알림 설정 OFF**
   - 설정에서 푸시 알림 OFF
   - 편지 수신 시 푸시 알림 미전송 확인

### 8.2 디버깅

클라이언트 로그에서 다음 메시지를 확인할 수 있습니다:

- `📱 FCM Token: {token}` - FCM 토큰 등록 성공
- `📬 포그라운드 메시지 수신` - 포그라운드에서 메시지 수신
- `📬 백그라운드에서 알림 탭` - 백그라운드에서 알림 탭
- `📬 앱 종료 상태에서 알림 탭` - 앱 종료 상태에서 알림 탭

---

## 9. 주의사항

1. **FCM 토큰 만료**: FCM 토큰은 만료될 수 있으므로, 전송 실패 시 토큰을 삭제해야 합니다.

2. **푸시 알림 설정**: 사용자가 푸시 알림을 OFF한 경우 알림을 보내지 않아야 합니다.

3. **중복 알림 방지**: 같은 이벤트에 대해 여러 번 알림을 보내지 않도록 주의해야 합니다.

4. **딥링크 유효성**: 딥링크의 리소스가 삭제되었을 수 있으므로, 클라이언트에서 에러 처리를 해야 합니다.

5. **iOS APNs**: iOS에서는 APNs 인증 키가 Firebase Console에 등록되어 있어야 합니다.

---

## 10. 참고 자료

- [Firebase Cloud Messaging 문서](https://firebase.google.com/docs/cloud-messaging)
- [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
- [Flutter Firebase Messaging 패키지](https://pub.dev/packages/firebase_messaging)

