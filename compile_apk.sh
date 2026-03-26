#!/bin/bash

# 🔧 Script otimizado para compilar APK com poucos recursos
# Compilado para ARM64 apenas (compatível com 90%+ dos telefones)

set -e

echo "🔍 Limpando processos..."
pkill -9 -f gradle || true
pkill -9 -f java || true
sleep 2

cd ~/validaçao\ tickets/mobile_app

echo "🧹 Limpando cache..."
rm -rf build .dart_tool android/.gradle android/build

echo "📦 Restaurando dependências..."
flutter pub get

echo "⏳ Esperando memória se estabilizar..."
sleep 5

echo "🚀 Compilando APK (ARM64 apenas)..."
echo "   Isso pode levar 15-30 minutos..."

# Compilar com --no-split (um único APK) e --target-platform arm64
flutter build apk \
  --release \
  --target-platform android-arm64 \
  --no-split \
  --dart-define-from-file=dart-defines.json 2>&1 | tee build.log

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ APK COMPILADO COM SUCESSO!"
  ls -lh build/app/outputs/flutter-apk/app-release.apk
else
  echo "❌ Compilação falhou. Verifique build.log"
  exit 1
fi
