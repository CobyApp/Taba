#!/bin/bash

# GitHub Secrets 설정 가이드 및 검증 스크립트

set -e

echo "🔑 GitHub Secrets 설정 가이드"
echo "=============================="
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo "필요한 GitHub Secrets 목록:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Android Secrets (5개)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. ANDROID_KEYSTORE_BASE64"
echo "   설명: Keystore 파일을 base64로 인코딩한 값"
echo "   생성: base64 -i android/app/keystore.jks | pbcopy"
echo ""
echo "2. ANDROID_KEYSTORE_PASSWORD"
echo "   설명: Keystore 비밀번호"
echo "   예시: your-keystore-password"
echo ""
echo "3. ANDROID_KEY_ALIAS"
echo "   설명: 키 별칭"
echo "   예시: taba-key"
echo ""
echo "4. ANDROID_KEY_PASSWORD"
echo "   설명: 키 비밀번호"
echo "   예시: your-key-password"
echo ""
echo "5. GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"
echo "   설명: Google Play 서비스 계정 JSON (전체 내용)"
echo "   생성: Google Play Console → API 액세스 → 서비스 계정 생성"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🍎 iOS Secrets (6개)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. APP_STORE_CONNECT_API_KEY_ID"
echo "   설명: App Store Connect API Key ID (10자리)"
echo "   생성: App Store Connect → 사용자 및 액세스 → 키"
echo "   예시: ABC123DEF4"
echo ""
echo "2. APP_STORE_CONNECT_ISSUER_ID"
echo "   설명: App Store Connect Issuer ID (UUID)"
echo "   생성: App Store Connect → 사용자 및 액세스 → 키 (페이지 상단)"
echo "   예시: 12345678-1234-1234-1234-123456789012"
echo ""
echo "3. APP_STORE_CONNECT_API_KEY"
echo "   설명: App Store Connect API Key (.p8 파일 내용)"
echo "   생성: App Store Connect에서 .p8 파일 다운로드 후 내용 복사"
echo "   형식: -----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----"
echo ""
echo "4. APPLE_CERTIFICATE_BASE64"
echo "   설명: Distribution Certificate (.p12)를 base64로 인코딩"
echo "   생성: ./scripts/setup_ios_certificates.sh 실행"
echo ""
echo "5. APPLE_CERTIFICATE_PASSWORD"
echo "   설명: Certificate 비밀번호 (.p12 내보낼 때 설정한 비밀번호)"
echo "   예시: your-certificate-password"
echo ""
echo "6. APPLE_PROVISIONING_PROFILE_BASE64"
echo "   설명: Provisioning Profile을 base64로 인코딩"
echo "   생성: ./scripts/setup_ios_certificates.sh 실행"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# GitHub CLI 확인
if command -v gh &> /dev/null; then
    info "GitHub CLI가 설치되어 있습니다."
    echo ""
    read -p "GitHub CLI로 Secrets를 설정하시겠습니까? (y/n): " use_gh
    
    if [ "$use_gh" = "y" ] || [ "$use_gh" = "Y" ]; then
        echo ""
        info "GitHub CLI로 Secrets 설정"
        echo ""
        
        # Android Secrets
        echo "📱 Android Secrets 설정"
        read -p "ANDROID_KEYSTORE_BASE64 설정? (y/n): " set_keystore
        if [ "$set_keystore" = "y" ] || [ "$set_keystore" = "Y" ]; then
            if [ -f "android/app/keystore.jks" ]; then
                keystore_base64=$(base64 -i android/app/keystore.jks)
                gh secret set ANDROID_KEYSTORE_BASE64 --body "$keystore_base64"
                success "ANDROID_KEYSTORE_BASE64 설정 완료"
            else
                warning "android/app/keystore.jks 파일을 찾을 수 없습니다."
            fi
        fi
        
        read -p "ANDROID_KEYSTORE_PASSWORD 설정? (y/n): " set_keystore_pass
        if [ "$set_keystore_pass" = "y" ] || [ "$set_keystore_pass" = "Y" ]; then
            read -sp "비밀번호 입력: " keystore_password
            echo ""
            gh secret set ANDROID_KEYSTORE_PASSWORD --body "$keystore_password"
            success "ANDROID_KEYSTORE_PASSWORD 설정 완료"
        fi
        
        read -p "ANDROID_KEY_ALIAS 설정? (y/n): " set_alias
        if [ "$set_alias" = "y" ] || [ "$set_alias" = "Y" ]; then
            read -p "별칭 입력 (기본값: taba-key): " key_alias
            key_alias=${key_alias:-taba-key}
            gh secret set ANDROID_KEY_ALIAS --body "$key_alias"
            success "ANDROID_KEY_ALIAS 설정 완료: $key_alias"
        fi
        
        read -p "ANDROID_KEY_PASSWORD 설정? (y/n): " set_key_pass
        if [ "$set_key_pass" = "y" ] || [ "$set_key_pass" = "Y" ]; then
            read -sp "키 비밀번호 입력: " key_password
            echo ""
            gh secret set ANDROID_KEY_PASSWORD --body "$key_password"
            success "ANDROID_KEY_PASSWORD 설정 완료"
        fi
        
        # iOS Secrets
        echo ""
        echo "🍎 iOS Secrets 설정"
        read -p "APP_STORE_CONNECT_API_KEY_ID 설정? (y/n): " set_key_id
        if [ "$set_key_id" = "y" ] || [ "$set_key_id" = "Y" ]; then
            read -p "API Key ID 입력: " api_key_id
            gh secret set APP_STORE_CONNECT_API_KEY_ID --body "$api_key_id"
            success "APP_STORE_CONNECT_API_KEY_ID 설정 완료"
        fi
        
        read -p "APP_STORE_CONNECT_ISSUER_ID 설정? (y/n): " set_issuer_id
        if [ "$set_issuer_id" = "y" ] || [ "$set_issuer_id" = "Y" ]; then
            read -p "Issuer ID 입력: " issuer_id
            gh secret set APP_STORE_CONNECT_ISSUER_ID --body "$issuer_id"
            success "APP_STORE_CONNECT_ISSUER_ID 설정 완료"
        fi
        
        read -p "APP_STORE_CONNECT_API_KEY 설정? (y/n): " set_api_key
        if [ "$set_api_key" = "y" ] || [ "$set_api_key" = "Y" ]; then
            read -p ".p8 파일 경로 입력: " p8_path
            if [ -f "$p8_path" ]; then
                api_key=$(cat "$p8_path")
                gh secret set APP_STORE_CONNECT_API_KEY --body "$api_key"
                success "APP_STORE_CONNECT_API_KEY 설정 완료"
            else
                error "파일을 찾을 수 없습니다: $p8_path"
            fi
        fi
        
        success "GitHub Secrets 설정 완료!"
        echo ""
        info "나머지 Secrets는 수동으로 설정하세요:"
        echo "   - APPLE_CERTIFICATE_BASE64 (./scripts/setup_ios_certificates.sh 실행)"
        echo "   - APPLE_CERTIFICATE_PASSWORD"
        echo "   - APPLE_PROVISIONING_PROFILE_BASE64 (./scripts/setup_ios_certificates.sh 실행)"
        echo "   - GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"
        
    else
        info "수동 설정 방법:"
        echo "   1. GitHub 저장소 → Settings → Secrets and variables → Actions"
        echo "   2. 'New repository secret' 클릭"
        echo "   3. 위의 목록에 따라 각 Secret 추가"
    fi
else
    warning "GitHub CLI가 설치되어 있지 않습니다."
    echo ""
    info "설치 방법:"
    echo "   brew install gh"
    echo ""
    info "또는 수동으로 설정:"
    echo "   1. GitHub 저장소 → Settings → Secrets and variables → Actions"
    echo "   2. 'New repository secret' 클릭"
    echo "   3. 위의 목록에 따라 각 Secret 추가"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "가이드 완료!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

