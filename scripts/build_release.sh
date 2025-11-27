#!/bin/bash

# Release 빌드 스크립트 (프로덕션 서버 사용)
# 사용법: ./scripts/build_release.sh [android|ios|both]

set -e

PLATFORM=${1:-both}

echo "🚀 Release 빌드 시작 (프로덕션 서버: https://www.taba.asia)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Flutter 의존성 확인
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되어 있지 않습니다."
    exit 1
fi

# 의존성 설치
echo "📦 의존성 설치 중..."
flutter pub get

# Android 빌드
if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
    echo ""
    echo "🤖 Android Release 빌드 중..."
    echo "   서버: https://www.taba.asia/api/v1"
    flutter build appbundle --release \
        --dart-define=API_ENV=prod
    
    echo "✅ Android AAB 빌드 완료: build/app/outputs/bundle/release/app-release.aab"
fi

# iOS 빌드
if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
    echo ""
    echo "🍎 iOS Release 빌드 중..."
    echo "   서버: https://www.taba.asia/api/v1"
    
    # CocoaPods 의존성 설치
    cd ios
    pod install
    cd ..
    
    flutter build ipa --release \
        --dart-define=API_ENV=prod \
        --export-options-plist=ios/ExportOptions-prod.plist
    
    echo "✅ iOS IPA 빌드 완료: build/ios/ipa/"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Release 빌드 완료!"
echo "   📱 서버: https://www.taba.asia/api/v1 (프로덕션)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

