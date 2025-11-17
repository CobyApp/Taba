# Taba ERD (Entity Relationship Diagram)

## 엔티티 목록

### 1. users (사용자)
```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- BCrypt 해시
    username VARCHAR(50) UNIQUE NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    avatar_url VARCHAR(500),
    status_message VARCHAR(200),
    language VARCHAR(10) DEFAULT 'ko', -- ko, en, ja
    push_notification_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_username (username)
);
```

### 2. letters (편지)
```sql
CREATE TABLE letters (
    id VARCHAR(36) PRIMARY KEY,
    sender_id VARCHAR(36) NOT NULL,
    recipient_id VARCHAR(36) NULL, -- DIRECT인 경우만
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    preview VARCHAR(500) NOT NULL,
    flower_type VARCHAR(20) NOT NULL, -- ROSE, TULIP, SAKURA, SUNFLOWER, DAISY, LAVENDER
    visibility VARCHAR(20) NOT NULL, -- PUBLIC, FRIENDS, DIRECT, PRIVATE
    is_anonymous BOOLEAN DEFAULT false,
    template_background VARCHAR(50) NULL,
    template_text_color VARCHAR(50) NULL,
    template_font_family VARCHAR(100) NULL,
    template_font_size DECIMAL(5,2) NULL,
    scheduled_at TIMESTAMP NULL, -- 예약 발송 시간
    sent_at TIMESTAMP NULL, -- 실제 발송 시간
    likes INT DEFAULT 0,
    views INT DEFAULT 0,
    saved_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_sender (sender_id),
    INDEX idx_recipient (recipient_id),
    INDEX idx_visibility (visibility),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_sent_at (sent_at),
    INDEX idx_created_at (created_at)
);
```

### 3. letter_images (편지 첨부 이미지)
```sql
CREATE TABLE letter_images (
    id VARCHAR(36) PRIMARY KEY,
    letter_id VARCHAR(36) NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    image_order INT NOT NULL, -- 이미지 순서
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (letter_id) REFERENCES letters(id) ON DELETE CASCADE,
    INDEX idx_letter (letter_id)
);
```

### 4. letter_tags (편지 태그)
```sql
CREATE TABLE letter_tags (
    id VARCHAR(36) PRIMARY KEY,
    letter_id VARCHAR(36) NOT NULL,
    tag VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (letter_id) REFERENCES letters(id) ON DELETE CASCADE,
    UNIQUE KEY uk_letter_tag (letter_id, tag),
    INDEX idx_tag (tag)
);
```

### 5. letter_likes (편지 좋아요)
```sql
CREATE TABLE letter_likes (
    id VARCHAR(36) PRIMARY KEY,
    letter_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (letter_id) REFERENCES letters(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_letter_user (letter_id, user_id),
    INDEX idx_user (user_id)
);
```

### 6. letter_saves (편지 저장)
```sql
CREATE TABLE letter_saves (
    id VARCHAR(36) PRIMARY KEY,
    letter_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (letter_id) REFERENCES letters(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_letter_user (letter_id, user_id),
    INDEX idx_user (user_id)
);
```

### 7. friendships (친구 관계)
```sql
CREATE TABLE friendships (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    friend_id VARCHAR(36) NOT NULL,
    bouquet_name VARCHAR(100) NULL, -- 사용자 지정 꽃다발 이름
    bloom_level DECIMAL(3,2) DEFAULT 0.0, -- 0.0 ~ 1.0
    trust_score INT DEFAULT 0, -- 0 ~ 100
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_friend (user_id, friend_id),
    INDEX idx_user (user_id),
    INDEX idx_friend (friend_id)
);
```

### 8. shared_flowers (공유된 편지 - 꽃다발)
```sql
CREATE TABLE shared_flowers (
    id VARCHAR(36) PRIMARY KEY,
    letter_id VARCHAR(36) NOT NULL,
    friendship_id VARCHAR(36) NOT NULL,
    sent_by_user_id VARCHAR(36) NOT NULL, -- 편지를 보낸 사용자 ID
    seed_id VARCHAR(50) NOT NULL, -- 씨앗 ID
    energy DECIMAL(3,2) DEFAULT 0.5, -- 에너지 레벨
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMP NOT NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (letter_id) REFERENCES letters(id) ON DELETE CASCADE,
    FOREIGN KEY (friendship_id) REFERENCES friendships(id) ON DELETE CASCADE,
    FOREIGN KEY (sent_by_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_friendship (friendship_id),
    INDEX idx_sent_by (sent_by_user_id),
    INDEX idx_sent_at (sent_at),
    INDEX idx_is_read (is_read)
);
```

### 9. invite_codes (초대 코드)
```sql
CREATE TABLE invite_codes (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    code VARCHAR(20) NOT NULL, -- 형식: {USERNAME}-{6자리숫자}
    expires_at TIMESTAMP NOT NULL,
    used_by_user_id VARCHAR(36) NULL, -- 사용한 사용자 ID
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (used_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uk_code (code),
    INDEX idx_user (user_id),
    INDEX idx_expires_at (expires_at),
    INDEX idx_used_by (used_by_user_id)
);
```

### 10. notifications (알림)
```sql
CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    title VARCHAR(200) NOT NULL,
    subtitle VARCHAR(500),
    category VARCHAR(20) NOT NULL, -- LETTER, REACTION, FRIEND, SYSTEM
    related_id VARCHAR(36) NULL, -- 관련 엔티티 ID (letter_id, friendship_id 등)
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_category (category),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
);
```

### 11. password_reset_tokens (비밀번호 재설정 토큰)
```sql
CREATE TABLE password_reset_tokens (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_token (token),
    INDEX idx_user (user_id),
    INDEX idx_expires_at (expires_at)
);
```

### 12. letter_reports (편지 신고)
```sql
CREATE TABLE letter_reports (
    id VARCHAR(36) PRIMARY KEY,
    letter_id VARCHAR(36) NOT NULL,
    reporter_id VARCHAR(36) NOT NULL,
    reason VARCHAR(500),
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, REVIEWED, RESOLVED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    FOREIGN KEY (letter_id) REFERENCES letters(id) ON DELETE CASCADE,
    FOREIGN KEY (reporter_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_letter (letter_id),
    INDEX idx_reporter (reporter_id),
    INDEX idx_status (status)
);
```

## 관계도 (Relationships)

```
users (1) ────< (N) letters
                ├─ sender_id
                └─ recipient_id (nullable, DIRECT인 경우)

letters (1) ────< (N) letter_images
letters (1) ────< (N) letter_tags
letters (1) ────< (N) letter_likes
letters (1) ────< (N) letter_saves
letters (1) ────< (N) letter_reports

users (1) ────< (N) friendships (user_id)
users (1) ────< (N) friendships (friend_id)

friendships (1) ────< (N) shared_flowers

users (1) ────< (N) invite_codes (user_id)
users (1) ────< (N) invite_codes (used_by_user_id)

users (1) ────< (N) notifications

users (1) ────< (N) password_reset_tokens
```

## 주요 인덱스 전략

1. **users**
   - `email`: 로그인 시 빠른 조회
   - `username`: 초대 코드 생성 시 조회

2. **letters**
   - `sender_id`: 사용자별 편지 조회
   - `visibility`, `sent_at`: 공개 편지 목록 조회
   - `scheduled_at`: 예약 발송 스케줄러 조회

3. **shared_flowers**
   - `friendship_id`, `sent_at`: 꽃다발 편지 목록 조회
   - `is_read`: 읽지 않은 편지 조회

4. **notifications**
   - `user_id`, `is_read`, `created_at`: 알림 목록 조회

5. **invite_codes**
   - `code`: 초대 코드 검증
   - `expires_at`: 만료된 코드 정리

## 데이터 타입 및 제약사항

### Enum 타입
- `flower_type`: ROSE, TULIP, SAKURA, SUNFLOWER, DAISY, LAVENDER
- `visibility`: PUBLIC, FRIENDS, DIRECT, PRIVATE
- `notification_category`: LETTER, REACTION, FRIEND, SYSTEM
- `language`: ko, en, ja

### 제약사항
- 친구 관계는 양방향으로 저장 (user_id, friend_id)
- 편지 좋아요/저장은 중복 방지 (UNIQUE 제약)
- 초대 코드는 유효기간 내에만 사용 가능
- 소프트 삭제 지원 (deleted_at 컬럼)

## 성능 최적화

1. **읽기 최적화**
   - 자주 조회되는 컬럼에 인덱스 생성
   - 페이징 처리로 대량 데이터 조회 방지

2. **쓰기 최적화**
   - 배치 삽입 사용 (편지 이미지 등)
   - 비동기 처리 (알림 발송 등)

3. **캐싱 전략**
   - 사용자 프로필 정보 (Redis)
   - 공개 편지 목록 (Redis)
   - 친구 목록 (Redis)

## 마이그레이션 전략

1. 초기 스키마 생성
2. 인덱스 추가 (성능 최적화)
3. 외래 키 제약 추가 (데이터 무결성)
4. 소프트 삭제 지원 추가

