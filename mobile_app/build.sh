#!/bin/bash

echo "🔧 COMPILANDO APP VAMOS LÁ TICKETS - VERSÃO OTIMIZADA"
echo "=================================================="
echo ""

# 1. Limpar TUDO
echo "📦 Limpando cache..."
rm -rf build
rm -rf .dart_tool
rm -rf android/.gradle
rm -rf ~/.gradle

# 2. Restaurar dependências
echo "📥 Restaurando dependências..."
flutter pub get

# 3. Compilar - VERSÃO OTIMIZADA PARA MEMÓRIA BAIXA
echo "⚙️  Compilando APK (apenas ARM64)..."
export GRADLE_OPTS="-Xmx1g"
flutter build apk --release --target-platform android-arm64

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCESSO! APK COMPILADO!"
    echo ""
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "📱 Seu APK está pronto em:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ ERRO NA COMPILAÇÃO"
    exit 1
fi
