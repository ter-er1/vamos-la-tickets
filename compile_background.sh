#!/bin/bash
# Compilação em background - NÃO será interrompida

LOG_FILE="/tmp/flutter_build.log"

{
    cd ~/validaçao\ tickets/mobile_app
    
    echo "[$(date)] Iniciando compilação..." >> $LOG_FILE
    
    # Mata tudo
    pkill -9 java 2>/dev/null || true
    sleep 2
    
    # Limpa
    rm -rf build android/.gradle android/build .dart_tool 2>/dev/null || true
    
    # Restaura deps
    flutter pub get >> $LOG_FILE 2>&1
    
    sleep 5
    
    # Compila - com timeout de 2 horas
    timeout 7200 flutter build apk --release --target-platform android-arm64 >> $LOG_FILE 2>&1
    
    BUILD_STATUS=$?
    
    if [ $BUILD_STATUS -eq 0 ]; then
        echo "[$(date)] ✅ SUCESSO!" >> $LOG_FILE
        ls -lh build/app/outputs/flutter-apk/ >> $LOG_FILE
    else
        echo "[$(date)] ❌ FALHOU com código $BUILD_STATUS" >> $LOG_FILE
    fi
    
    # Salva resultado em arquivo para você verificar depois
    cp $LOG_FILE ~/compilacao_resultado.log
    
} &

# Mostra PID
echo "🚀 Compilação iniciada em background!"
echo "   PID: $!"
echo "   Log: $LOG_FILE"
echo ""
echo "Para acompanhar:"
echo "  tail -f $LOG_FILE"
echo ""
echo "Para verificar resultado depois:"
echo "  cat ~/compilacao_resultado.log"
