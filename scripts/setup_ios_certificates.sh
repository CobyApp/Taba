#!/bin/bash

# iOS 인증서 및 프로비저닝 프로파일 설정 스크립트
# 이 스크립트는 인증서와 프로파일을 확인하고 base64로 인코딩합니다.

set -e

echo "🔐 iOS 인증서 및 프로비저닝 프로파일 설정 도구"
echo "================================================"
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 성공 메시지
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 경고 메시지
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 함수: 오류 메시지
error() {
    echo -e "${RED}❌ $1${NC}"
}

# 함수: 정보 메시지
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 1. Keychain에서 Distribution 인증서 확인
echo "1️⃣  Keychain에서 Distribution 인증서 확인 중..."
echo ""

CERTIFICATES=$(security find-identity -v -p codesigning | grep "Distribution" || echo "")

if [ -z "$CERTIFICATES" ]; then
    error "Distribution 인증서를 찾을 수 없습니다."
    echo ""
    info "인증서를 생성하려면:"
    echo "   1. Xcode → Settings → Accounts → Manage Certificates"
    echo "   2. 또는 Keychain Access → 인증서 지원 → 인증 기관에 인증서 요청"
    echo ""
    exit 1
else
    success "Distribution 인증서를 찾았습니다:"
    echo "$CERTIFICATES"
    echo ""
fi

# 2. 인증서를 .p12로 내보내기
echo "2️⃣  인증서를 .p12 파일로 내보내기"
echo ""
info "Keychain Access에서 수동으로 내보내야 합니다:"
echo "   1. Keychain Access 앱 열기"
echo "   2. 왼쪽 사이드바: 로그인 → 인증서"
echo "   3. 'Apple Distribution: [이름]' 인증서 찾기"
echo "   4. 우클릭 → '내보내기...' 선택"
echo "   5. 파일 형식: Personal Information Exchange (.p12)"
echo "   6. 비밀번호 설정 (기억하세요! GitHub Secret에 사용합니다)"
echo ""

read -p "이미 .p12 파일이 있나요? (y/n): " has_p12

if [ "$has_p12" = "y" ] || [ "$has_p12" = "Y" ]; then
    read -p ".p12 파일 경로를 입력하세요 (예: ~/Desktop/distribution.p12): " p12_path
    p12_path="${p12_path/#\~/$HOME}"
    
    if [ ! -f "$p12_path" ]; then
        error "파일을 찾을 수 없습니다: $p12_path"
        exit 1
    fi
    
    success "파일을 찾았습니다: $p12_path"
    
    # 비밀번호 확인
    read -sp "인증서 비밀번호를 입력하세요: " cert_password
    echo ""
    
    # 비밀번호 검증
    if ! security import "$p12_path" -k ~/Library/Keychains/login.keychain-db -P "$cert_password" -T /usr/bin/codesign 2>/dev/null; then
        error "비밀번호가 올바르지 않습니다."
        exit 1
    fi
    
    success "비밀번호 확인 완료"
    
    # Base64 인코딩
    echo ""
    echo "3️⃣  Base64 인코딩 중..."
    base64_output=$(base64 -i "$p12_path")
    
    echo ""
    success "Base64 인코딩 완료!"
    echo ""
    info "다음 값을 GitHub Secret 'APPLE_CERTIFICATE_BASE64'에 복사하세요:"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$base64_output"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 클립보드에 복사 (macOS)
    if command -v pbcopy &> /dev/null; then
        echo "$base64_output" | pbcopy
        success "클립보드에 복사되었습니다!"
    fi
    
    # 비밀번호 저장
    echo ""
    info "다음 값을 GitHub Secret 'APPLE_CERTIFICATE_PASSWORD'에 입력하세요:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$cert_password"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
else
    warning ".p12 파일을 먼저 생성하세요."
    exit 1
fi

# 4. Provisioning Profile 확인
echo ""
echo "4️⃣  Provisioning Profile 확인"
echo ""
read -p "Provisioning Profile 파일이 있나요? (y/n): " has_profile

if [ "$has_profile" = "y" ] || [ "$has_profile" = "Y" ]; then
    read -p "Profile 파일 경로를 입력하세요 (예: ~/Desktop/profile.mobileprovision): " profile_path
    profile_path="${profile_path/#\~/$HOME}"
    
    if [ ! -f "$profile_path" ]; then
        error "파일을 찾을 수 없습니다: $profile_path"
        exit 1
    fi
    
    success "파일을 찾았습니다: $profile_path"
    
    # Profile 정보 추출
    echo ""
    info "Provisioning Profile 정보:"
    TEMP_PLIST=$(mktemp)
    security cms -D -i "$profile_path" > "$TEMP_PLIST" 2>/dev/null
    
    if [ -f "$TEMP_PLIST" ]; then
        PROFILE_NAME=$(/usr/libexec/PlistBuddy -c "Print Name" "$TEMP_PLIST" 2>/dev/null || echo "Unknown")
        PROFILE_UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" "$TEMP_PLIST" 2>/dev/null || echo "Unknown")
        PROFILE_TEAM_ID=$(/usr/libexec/PlistBuddy -c "Print TeamIdentifier:0" "$TEMP_PLIST" 2>/dev/null || echo "Unknown")
        BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print Entitlements:application-identifier" "$TEMP_PLIST" 2>/dev/null | cut -d. -f2- || echo "Unknown")
        
        echo "   이름: $PROFILE_NAME"
        echo "   UUID: $PROFILE_UUID"
        echo "   Team ID: $PROFILE_TEAM_ID"
        echo "   Bundle ID: $BUNDLE_ID"
        echo ""
        
        rm -f "$TEMP_PLIST"
    fi
    
    # Base64 인코딩
    echo "5️⃣  Base64 인코딩 중..."
    profile_base64=$(base64 -i "$profile_path")
    
    echo ""
    success "Base64 인코딩 완료!"
    echo ""
    info "다음 값을 GitHub Secret 'APPLE_PROVISIONING_PROFILE_BASE64'에 복사하세요:"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$profile_base64"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 클립보드에 복사 (macOS)
    if command -v pbcopy &> /dev/null; then
        echo "$profile_base64" | pbcopy
        success "클립보드에 복사되었습니다!"
    fi
    
else
    warning "Provisioning Profile을 먼저 다운로드하세요."
    info "다운로드 위치: Apple Developer Portal → Profiles → 다운로드"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "설정 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
info "다음 단계:"
echo "   1. GitHub 저장소 → Settings → Secrets and variables → Actions"
echo "   2. 위에서 생성한 값들을 각 Secret에 추가"
echo "   3. App Store Connect API Key도 설정해야 합니다"
echo ""

