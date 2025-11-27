#!/bin/bash

# 개발 빌드 스크립트 (개발 서버 사용)
# 사용법: ./scripts/build_dev.sh [android|ios|both]

set -e

PLATFORM=${1:-both}

echo "🔧 개발 빌드 시작 (개발 서버: https://dev.taba.asia)"
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
    echo "🤖 Android 개발 빌드 중..."
    echo "   서버: https://dev.taba.asia/api/v1"
    flutter build apk --release \
        --dart-define=API_ENV=dev
    
    echo "✅ Android APK 빌드 완료: build/app/outputs/flutter-apk/app-release.apk"
fi

# iOS 빌드
if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
    echo ""
    echo "🍎 iOS 개발 빌드 중..."
    echo "   서버: https://dev.taba.asia/api/v1"
    
    # CocoaPods 의존성 설치
    cd ios
    pod install
    cd ..
    
    flutter build ipa --release \
        --dart-define=API_ENV=dev \
        --export-options-plist=ios/ExportOptions-dev.plist
    
    echo "✅ iOS IPA 빌드 완료: build/ios/ipa/"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 개발 빌드 완료!"
echo "   📱 서버: https://dev.taba.asia/api/v1 (개발)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

