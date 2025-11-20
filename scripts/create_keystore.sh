#!/bin/bash
# Keystore 생성 스크립트
# 사용법: ./scripts/create_keystore.sh

echo "🔐 Keystore 생성 스크립트"
echo ""
echo "Keystore 비밀번호를 입력하세요 (keystore와 key 모두 같은 비밀번호 사용):"
read -s KEYSTORE_PASSWORD

echo ""
echo "비밀번호 확인:"
read -s KEYSTORE_PASSWORD_CONFIRM

if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
    echo "❌ 비밀번호가 일치하지 않습니다."
    exit 1
fi

echo ""
echo "Keystore를 생성하는 중..."

keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias taba-key \
  -storepass "$KEYSTORE_PASSWORD" \
  -keypass "$KEYSTORE_PASSWORD" \
  -dname "CN=Taba, OU=Development, O=Taba, L=Seoul, ST=Seoul, C=KR"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore가 생성되었습니다: android/app/keystore.jks"
    echo ""
    echo "📋 다음 단계:"
    echo "1. Keystore를 base64로 인코딩:"
    echo "   base64 -i android/app/keystore.jks | pbcopy"
    echo ""
    echo "2. GitHub Secrets에 추가:"
    echo "   - ANDROID_KEYSTORE_BASE64: (위에서 복사한 값)"
    echo "   - ANDROID_KEYSTORE_PASSWORD: $KEYSTORE_PASSWORD"
    echo "   - ANDROID_KEY_ALIAS: taba-key"
    echo "   - ANDROID_KEY_PASSWORD: $KEYSTORE_PASSWORD"
    echo ""
    echo "⚠️  비밀번호를 안전하게 보관하세요!"
else
    echo "❌ Keystore 생성에 실패했습니다."
    exit 1
fi

