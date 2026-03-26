#!/bin/bash

echo "🎯 PLANO B - COMPILAÇÃO SUPER OTIMIZADA"
echo "========================================"
echo ""

# Limpar extremamente
rm -rf build
rm -rf .dart_tool  
rm -rf android/.gradle
rm -rf ~/.gradle/daemon
rm -rf ~/.gradle/*.lock

flutter pub get

# Compilar com MÁXIMA COMPRESSÃO
flutter build apk \
    --release \
    --target-platform android-arm64 \
    --split-per-abi \
    --tree-shake-icons

echo "✅ Compilação completa!"
ls -lh build/app/outputs/flutter-apk/
