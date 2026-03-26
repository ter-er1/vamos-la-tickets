# 📱 Instalar APK no Android

## ✨ Preparação do Telefone

### 1. Ativar Modo Desenvolvedor

**Android 10+:**
1. Settings → About phone
2. Procure "Build number" (versão do Android)
3. Toque 7 vezes no "Build number"
4. Volte → Advanced → Developer options
5. Ative "USB Debugging"

**Android 9 ou anterior:**
1. Settings → About phone
2. Toque 7 vezes em "Build number"
3. Back → Development options
4. Ative "USB Debugging"

---

## 📥 Opção 1: Via ADB (Android Debug Bridge)

### Passo 1: Instalar ADB no Linux
```bash
sudo apt-get update
sudo apt-get install -y adb
```

### Passo 2: Conectar via USB
1. Conecte telefone ao PC via USB
2. No telefone, clique "Allow" na popup "Allow USB Debugging?"
3. No PC, verifique:
```bash
adb devices
# Deve mostrar seu telefone:
# List of attached devices
# R38M70XXXXX  device
```

### Passo 3: Instalar APK
```bash
# Navegar para pasta do APK
cd ~/Downloads

# Instalar
adb install -r app-release.apk

# Output esperado:
# Success
```

**Pronto!** App aparecerá na home do telefone 🎉

---

## 📲 Opção 2: Via Arquivos (Sem ADB)

### Passo 1: Copiar para Telefone
1. Conecte telefone via USB
2. Abra o gerenciador de arquivos do PC
3. Vá para pasta do telefone (ex: Internal Storage)
4. Copie `app-release.apk` para pasta visível (ex: Downloads)

### Passo 2: Instalar no Telefone
1. No telefone, abra **Gerenciador de Arquivos**
2. Vá para **Downloads**
3. Procure **app-release.apk**
4. Toque para instalar
5. Clique "Install" (se pedir permissão de fontes desconhecidas, ative)

**Pronto!** 🎉

---

## ☁️ Opção 3: Via Nuvem (Google Drive)

### Passo 1: Upload para Drive
```bash
# Manual via Google Drive web:
# 1. Vá para drive.google.com
# 2. Clique "New" → "File upload"
# 3. Selecione app-release.apk
# 4. Espere upload terminar
```

### Passo 2: Baixar no Telefone
1. No telefone, abra **Google Drive app**
2. Procure **app-release.apk**
3. Toque → **Download**
4. Toque no arquivo baixado
5. Clique **Install**

**Pronto!** 🎉

---

## ⚙️ Desinstalar APK Anterior

Se já tem uma versão antiga instalada:

### Via ADB:
```bash
# Listar pacotes instalados
adb shell pm list packages | grep vamos

# Desinstalar (copie o nome exato)
adb uninstall com.example.vamos_la_tickets
```

### Manualmente no Telefone:
1. Settings → Apps
2. Procure "Vamos Lá Tickets"
3. Toque → "Uninstall"
4. Confirme

---

## ✅ Verificar Instalação

### Via ADB:
```bash
# Ver se está instalado
adb shell pm list packages | grep vamos

# Deve mostrar algo como:
# package:com.example.vamos_la_tickets
```

### Manualmente:
1. Na home do telefone, procure o ícone "Vamos Lá Tickets"
2. Se aparecer, foi instalado com sucesso ✅

---

## 🚀 Primeira Execução

### Tela de Splash
Ao abrir o app pela primeira vez:
1. Tela com logo (splash screen) aparece
2. Redirecionado para Settings

### Configurar Servidor
1. Abra **Settings**
2. Clique em **"Add Server"** ou **"Server Configuration"**
3. Digite IP do servidor local:
   - Exemplo: `192.168.1.100`
   - Ou: `10.0.0.50`
4. Clique **"Test Connection"**
5. Se tudo OK, clique **"Save"**

### Fazer Login
1. Volte para tela anterior
2. Digite credenciais (usuário/senha)
3. Clique **"Login"**

### Abrir Scanner
1. Clique em **"Scanner"** ou ícone de câmera
2. Aponte para QR code
3. Se válido: ✅ som e mensagem de sucesso
4. Se inválido: ❌ som de erro e mensagem

---

## 🐛 Troubleshooting

### ❌ "Aplication not installed"
**Causa:** Incompatibilidade Android ou arquivo corrompido

**Solução:**
1. Verifique Android version (precisa 5.0+)
2. Tente desinstalar versão anterior
3. Redownload do APK do GitHub

### ❌ "Could not verify integrity"
**Causa:** APK corrompido durante download

**Solução:**
```bash
# Verificar integridade
file app-release.apk

# Deve mostrar:
# app-release.apk: Zip archive data...

# Se não for Zip, redownload
```

### ❌ App não abre / Tela branca
**Causa:** Erro no código ou falta de permissão

**Solução:**
1. Ative permissões:
   - Settings → Apps → Vamos Lá Tickets
   - Permissions → Camera (enable)
   - Permissions → Storage (enable)
2. Reabra o app

### ❌ "Permission Denied"
**Causa:** Falta permissão de câmera ou armazenamento

**Solução:**
```bash
# Resetar permissões
adb shell pm clear --cache-only com.example.vamos_la_tickets

# Ou manualmente no Settings → Apps → Permissions
```

### ⚠️ App slow/lag
**Causa:** Telefone com RAM baixa ou CPU lento

**Solução:**
1. Feche outros apps
2. Limpe cache: Settings → Apps → Vamos Lá Tickets → Storage → Clear Cache
3. Reinicie telefone

---

## 📊 Info do APK

Para verificar detalhes do APK instalado:

```bash
# Info do pacote
adb shell dumpsys package com.example.vamos_la_tickets | grep -E "versionCode|versionName"

# Deve mostrar algo como:
# versionCode=1 targetSdk=34
# versionName=1.0.0
```

---

## 🎯 Próximos Passos

1. ✅ APK instalado
2. → Configurar servidor (Settings)
3. → Fazer login
4. → Abrir scanner
5. → Testar com QR code

**Dúvida?** Ver guia principal: `README.md`
