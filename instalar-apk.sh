#!/bin/bash

# Script para instalar o APK no telefone

echo "🚀 Instalando Vamos Lá Tickets..."
echo ""
echo "⚠️ Certifique-se de:"
echo "1. Telefone conectado via USB"
echo "2. USB Debugging ativado"
echo "3. ADB instalado"
echo ""

# Verificar se adb existe
if ! command -v adb &> /dev/null; then
    echo "❌ ADB não encontrado!"
    echo "Instale Android SDK Platform Tools"
    exit 1
fi

# Instalar APK
APK_PATH="$(dirname "$0")/app-debug-arm64.apk"

if [ ! -f "$APK_PATH" ]; then
    echo "❌ APK não encontrado em: $APK_PATH"
    exit 1
fi

echo "📱 Instalando APK..."
adb install -r "$APK_PATH"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK INSTALADO COM SUCESSO!"
    echo ""
    echo "🎫 Para usar:"
    echo "1. Abra o app 'Vamos Lá Tickets'"
    echo "2. Vá para ⚙️ Configurações"
    echo "3. Digite o IP do seu servidor local (ex: 192.168.1.100)"
    echo "4. Clique 'Testar Conexão'"
    echo "5. Faça login"
    echo "6. Use o scanner de QR codes"
else
    echo "❌ Erro ao instalar APK"
    exit 1
fi
