#!/bin/bash
# Keystore 생성 스크립트
# 사용법: ./create_keystore.sh

echo "Keystore를 생성합니다..."
echo "비밀번호를 입력하세요 (keystore와 key 모두 같은 비밀번호 사용):"
read -s PASSWORD

keytool -genkey -v -keystore android/app/keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias taba-key \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" \
  -dname "CN=Taba, OU=Development, O=Taba, L=Seoul, ST=Seoul, C=KR"

echo ""
echo "✅ Keystore가 생성되었습니다: android/app/keystore.jks"
echo "⚠️  비밀번호를 안전하게 보관하세요: $PASSWORD"
echo ""
echo "다음 명령어로 base64 인코딩하세요:"
echo "base64 -i android/app/keystore.jks | pbcopy"
