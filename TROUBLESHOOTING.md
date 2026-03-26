# 🔧 GUIA DE TROUBLESHOOTING - Compilação do APK

## ⚠️ Problemas Comuns & Soluções

### 1. **"Timeout waiting to lock build logic queue"**
**Causa:** Gradle daemon travado, múltiplas instâncias rodando
**Solução:**
```bash
pkill -9 java
rm -rf android/.gradle ~/.gradle
# Compile novamente
```

### 2. **"Could not connect to Kotlin compile daemon"**
**Causa:** Memória RAM insuficiente, Kotlin daemon travado
**Solução:**
```bash
# Desativar daemon (mais lento mas mais estável)
gradle.properties: org.gradle.daemon=false
```

### 3. **"Falha na resolução de nome (storage.googleapis.com)"**
**Causa:** Problema de internet/DNS
**Solução:**
```bash
# Aguarde alguns minutos ou tente com VPN
# Ou mude DNS para 8.8.8.8
```

### 4. **APP abre, fica branco e fecha**
**Causa:** Erro na inicialização (permissões, conexão, código)
**Solução:**
- Verificar logcat: `adb logcat | grep -i error`
- App agora tem tela de CONFIGURAÇÃO para digitar IP do servidor
- Verifique IP na tela de configurações

### 5. **APK muito grande (>50MB)**
**Causa:** Minificação desativada (modo debug)
**Solução:**
```bash
flutter build apk --release  # Ativa minificação
```

---

## 📊 Especificações de Compilação

### Seu Sistema
- **RAM:** 3.7 GB
- **Swap:** 7.7 GB
- **Java:** OpenJDK 17 ✅
- **Flutter:** 3.32.2 ✅

### Configuração Otimizada
- **JVM Heap:** 1GB (máx, não 8GB!)
- **Workers:** 1 (serial, não paralelo)
- **Daemon:** Desativado (mais estável)
- **Plataforma:** ARM64 apenas (90%+ telefones)

### Arquiteturas Suportadas
- ✅ **ARM64 (arm64-v8a)** - Compilado (97% dos telefones modernos)
- ⚠️ ARM32 (armeabi-v7a) - Não compilado (requer 2x RAM)
- ⚠️ x86/x86_64 - Não compilados (raros em telefones)

---

## 🚀 Comando de Compilação Recomendado

Para sua máquina com 3.7GB RAM:

```bash
cd ~/validaçao\ tickets/mobile_app
flutter clean
flutter pub get
flutter build apk --release --target-platform android-arm64 --no-split
```

**Tempo esperado:** 20-30 minutos
**Tamanho APK:** 15-20 MB
**Compatibilidade:** 97% dos telefones Android modernos

---

## 🔍 Como Debugar se Falhar Novamente

1. **Verifique memória:**
   ```bash
   free -h
   ```
   Precisa de pelo menos 700MB livres

2. **Mate processos Java:**
   ```bash
   pkill -9 java
   ```

3. **Limpe cache:**
   ```bash
   rm -rf android/.gradle ~/.gradle
   ```

4. **Compile novamente:**
   ```bash
   flutter build apk --release --target-platform android-arm64
   ```

5. **Se ainda falhar, verifique logs:**
   ```bash
   flutter build apk --release --verbose 2>&1 | tee build.log
   cat build.log | grep -i error
   ```

---

## ✅ Como Saber que Funcionou

Depois de compilar com sucesso, você terá:

```bash
✓ Build app/outputs/flutter-apk/app-release.apk (XX MB)
```

Arquivo estará em:
```
~/validaçao tickets/mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Instalando no Telefone

### Opção 1: Via ADB (USB)
```bash
adb install ~/validaçao\ tickets/mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

### Opção 2: Transferência manual
1. Copie o APK via USB
2. Abra em "Gerenciador de Arquivos"
3. Toque para instalar

### Opção 3: Via compartilhamento
```bash
cp ~/validaçao\ tickets/mobile_app/build/app/outputs/flutter-apk/app-release.apk ~/app-vamos-la-tickets.apk
# Compartilhe por WhatsApp, Email, etc
```

---

## 🔗 Configurar Servidor

Na tela de CONFIGURAÇÕES do app:
1. Digite o IP do seu PC: `hostname -I`
2. Digite a porta: `8000`
3. Clique em "Testar Conexão"
4. Se OK, volta para LOGIN

**Servidor precisa estar rodando:**
```bash
cd ~/validaçao\ tickets/local_server
npm start
```

---

## 📝 Próximos Passos

1. ✅ Compilar APK (em progresso...)
2. ⏳ Instalar no telefone
3. ⏳ Digitar IP do servidor
4. ⏳ Testar escanear QR code
5. ⏳ Integrar com cloud backend (Fase 2)
