# 템플릿 및 폰트 목록

## 📄 템플릿 목록 (20개)

편지 작성 시 사용할 수 있는 템플릿 목록입니다. 모든 템플릿은 흰색 텍스트가 잘 보이도록 어두운 배경색을 사용합니다.

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
| `ocean_deep` | 오션 딥 | `#001A2E` | `#FFFFFF` (white) |
| `lavender_night` | 라벤더 나이트 | `#1A0F2E` | `#FFFFFF` (white) |
| `cherry_blossom` | 벚꽃 | `#2D0F1A` | `#FFFFFF` (white) |
| `midnight_forest` | 미드나잇 포레스트 | `#0A1A0F` | `#FFFFFF` (white) |
| `royal_purple` | 로얄 퍼플 | `#1A0A2E` | `#FFFFFF` (white) |
| `deep_rose` | 딥 로즈 | `#2E0A14` | `#FFFFFF` (white) |
| `starry_night` | 별이 빛나는 밤 | `#0A0A1A` | `#FFFFFF` (white) |
| `emerald_dark` | 에메랄드 다크 | `#0A1A0A` | `#FFFFFF` (white) |
| `sapphire_blue` | 사파이어 블루 | `#0A0F2E` | `#FFFFFF` (white) |
| `crimson_night` | 크림슨 나이트 | `#1A0A0A` | `#FFFFFF` (white) |

---

## 🔤 폰트 목록

### 영어 폰트 (20개)
- **Indie Flower** (기본 display 폰트)
- **Kalam** (기본 body 폰트)
- Patrick Hand
- Comic Neue
- Permanent Marker
- Pacifico
- Lobster
- Chewy
- Fredoka One
- Baloo 2
- Bangers
- Bubblegum Sans
- Cookie
- Nunito
- Quicksand
- Comfortaa
- Poppins
- Raleway
- Open Sans
- Roboto

### 한국어 폰트 (20개)
- **Jua** (기본 display 폰트)
- **Sunflower** (기본 body 폰트)
- Yeon Sung
- Poor Story
- Dongle
- Gamja Flower
- Hi Melody
- Nanum Gothic
- Nanum Myeongjo
- Noto Sans KR
- Noto Serif KR
- Gowun Batang
- Gowun Dodum
- Do Hyeon
- Black Han Sans
- Song Myung
- Stylish
- Single Day
- Gowun Batang
- Noto Sans KR

### 일본어 폰트 (20개)
- **Yomogi** (기본 display 폰트)
- **Kosugi Maru** (기본 body 폰트)
- M PLUS Rounded 1c
- Shippori Mincho
- Noto Sans JP
- Noto Serif JP
- M PLUS 1p
- Sawarabi Mincho
- Sawarabi Gothic
- Zen Kurenaido
- Zen Maru Gothic
- Kiwi Maru
- Mochiy Pop One
- Mochiy Pop P One
- Hachi Maru Pop
- Yusei Magic
- Zen Antique
- Zen Antique Soft
- Zen Kaku Gothic New
- Zen Old Mincho

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

