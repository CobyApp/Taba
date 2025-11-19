# 템플릿 및 폰트 목록

## 📄 템플릿 목록 (10개)

편지 작성 시 사용할 수 있는 템플릿 목록입니다.

| ID | 이름 | 배경색 | 텍스트 색상 |
|---|---|---|---|
| `neon_grid` | 네온 그리드 | `#0A0024` (deep midnight) | `#FFFFFF` (white) |
| `retro_paper` | 레트로 페이퍼 | `#1E1A14` (dark warm paper) | `#FFFFFF` (white) |
| `mint_terminal` | 민트 터미널 | `#061A17` | `#FFFFFF` (white) |
| `holo_purple` | 홀로 퍼플 | `#1D1433` | `#FFFFFF` (white) |
| `pixel_blue` | 픽셀 블루 | `#001133` | `#FFFFFF` (white) |
| `sunset_grid` | 선셋 그리드 | `#210014` | `#FFFFFF` (white) |
| `cyber_green` | 사이버 그린 | `#001100` | `#00FF00` (green) |
| `matrix_dark` | 매트릭스 다크 | `#000000` (black) | `#00CC00` (green) |
| `neon_pink` | 네온 핑크 | `#1A0016` | `#FF00FF` (magenta) |
| `retro_yellow` | 레트로 옐로우 | `#2A1F00` | `#FFFF00` (yellow) |

> **참고**: 시즌/프리미엄 템플릿은 곧 추가될 예정입니다.

---

## 🔤 폰트 목록

### 영어 폰트 (8개)
- **Indie Flower** (기본 display 폰트)
- **Kalam** (기본 body 폰트)
- Patrick Hand
- Shadows Into Light
- Comic Neue
- Caveat
- Dancing Script
- Permanent Marker

### 한국어 폰트 (8개)
- **Jua** (기본 display 폰트)
- **Sunflower** (기본 body 폰트)
- Yeon Sung
- Poor Story
- Dongle
- Gamja Flower
- Hi Melody
- Nanum Pen Script

### 일본어 폰트 (6개)
- **Yomogi** (기본 display 폰트)
- **Kosugi Maru** (기본 body 폰트)
- M PLUS Rounded 1c
- Comic Neue
- Shippori Mincho
- Noto Sans JP

---

## 🎨 앱 테마 폰트

앱 전체에서 사용되는 테마 폰트입니다.

### 한국어 (ko)
- **Display 폰트**: Jua
- **Body 폰트**: Sunflower

### 일본어 (ja)
- **Display 폰트**: Yomogi (FontWeight.w600)
- **Body 폰트**: Kosugi Maru

### 영어 (en)
- **Display 폰트**: Indie Flower (FontWeight.w600)
- **Body 폰트**: Kalam

---

## 📝 텍스트 스타일

### Display 스타일
- `displayLarge`: fontSize 40, letterSpacing 2, fontWeight w600
- `displayMedium`: fontWeight w600
- `headlineMedium`: fontSize 32
- `headlineSmall`: fontSize 26

### Body 스타일
- `titleLarge`: fontWeight w600, letterSpacing 0.5
- `titleMedium`: fontWeight w600
- `titleSmall`: fontWeight w500
- `bodyLarge`: fontSize 16
- `bodyMedium`: alpha 0.82
- `bodySmall`: fontSize 12

### Label 스타일
- `labelLarge`: fontWeight w700, letterSpacing 0.6
- `labelMedium`: letterSpacing 0.8

---

## 🔍 특수 폰트 사용처

### Press Start 2P
- 메인 화면 앱 이름 (`sky_screen.dart`)
  - fontSize: 20
  - letterSpacing: 2
  - color: white

---

## 📦 폰트 패키지

모든 폰트는 `google_fonts` 패키지를 통해 제공됩니다.

```yaml
dependencies:
  google_fonts: ^6.1.0
```

