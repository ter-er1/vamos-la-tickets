# 🚀 GUIA PRÁTICO: Como Rodar o Servidor e Instalar o App

**Leia este arquivo para entender EXATAMENTE como fazer tudo!**

---

## 📍 PARTE 1: RODAR O SERVIDOR LOCAL (PC)

### ⚠️ IMPORTANTE: Você precisa de Node.js instalado!

#### ✅ Verificar se Node.js está instalado:

**Windows:**
```bash
node --version
npm --version
```

**Linux:**
```bash
node --version
npm --version
```

Se aparecer versões (ex: `v16.0.0`), está pronto! ✅  
Se der erro, instale em: https://nodejs.org (escolher LTS)

---

## 🎬 PASSO A PASSO: RODAR SERVIDOR

### Passo 1: Abrir Terminal/PowerShell

**Windows:**
1. Pressionar `Windows + R`
2. Digitar `powershell`
3. Pressionar Enter

**Linux:**
1. Pressionar `Ctrl + Alt + T`

### Passo 2: Ir para a pasta do servidor

```bash
cd "validaçao tickets/local_server"
```

**Ou caminho completo:**

**Windows:**
```bash
cd "C:\Users\SeuUsuário\validaçao tickets\local_server"
```

**Linux:**
```bash
cd ~/validaçao\ tickets/local_server
```

### Passo 3: Instalar dependências (primeira vez só)

```bash
npm install
```

Esperar terminar (~2 minutos)

### Passo 4: Iniciar o servidor

```bash
npm start
```

### ✅ Você verá algo assim:

```
╔════════════════════════════════════════════╗
║   🎫 VAMOS LÁ TICKETS - SERVIDOR LOCAL    ║
╚════════════════════════════════════════════╝

📡 API rodando em:     http://0.0.0.0:8000
🗄️  Banco de dados:    /path/to/tickets.db
🔑 SECRET_KEY:         vamos-la-tickets...

✅ Pronto para receber validações!
```

✅ **SERVIDOR RODANDO COM SUCESSO!**

Deixe este terminal aberto enquanto usar o sistema!

---

## 🧪 TESTAR SERVIDOR (Terminal NOVO)

Abra um **NOVO terminal** (não feche o outro):

```bash
cd "validaçao tickets/local_server"
node test-api.js
```

Você verá testes sendo executados:
```
✅ Evento criado
✅ Tickets sincronizados
✅ Validação 1: VÁLIDA
✅ Validação 2: JÁ USADA
✅ Estatísticas obtidas

✅ TESTES CONCLUÍDOS COM SUCESSO!
```

Se tudo passou ✅, o servidor está funcionando 100%!

---

## 📱 PARTE 2: APP ANDROID (Instalar nos Telefones)

### ❌ O app NÃO está compilado ainda

O app está como **código-fonte** (Flutter). Você precisa **compilar para APK** primeiro!

---

## 🔨 COMPILAR O APP (Gerar APK)

### ⚠️ Você precisa de Flutter instalado!

#### ✅ Verificar se Flutter está instalado:

```bash
flutter --version
```

Se aparecer versão, está pronto! ✅  
Se der erro, instale em: https://flutter.dev/docs/get-started/install

---

### 📋 PRÉ-REQUISITOS

1. ✅ Flutter 3.0+ instalado
2. ✅ Android SDK instalado (vem com Flutter)
3. ✅ Emulador Android OU dispositivo físico

### 🎬 PASSO A PASSO: COMPILAR APK

#### Passo 1: Abrir Terminal (novo)

**Windows:** `Windows + R` → `powershell`  
**Linux:** `Ctrl + Alt + T`

#### Passo 2: Ir para pasta do app

```bash
cd "validaçao tickets/mobile_app"
```

#### Passo 3: Atualizar dependências Flutter

```bash
flutter pub get
```

Esperar terminar (~1 minuto)

#### Passo 4: Compilar APK para RELEASE (produção)

```bash
flutter build apk --release
```

Esperar ~5-10 minutos...

### ✅ Quando terminar:

```
✓ Built build/app/outputs/flutter-app-release.apk (X.XMB).
```

---

## 📍 ONDE ESTÁ O APK PRONTO PARA INSTALAR?

```
/validaçao tickets/mobile_app/build/app/outputs/flutter-app-release.apk
```

**Ou caminho visual:**
```
validaçao tickets
└─ mobile_app
   └─ build
      └─ app
         └─ outputs
            └─ flutter-app-release.apk ⭐ ESTE ARQUIVO!
```

---

## 📱 INSTALAR APK NOS TELEFONES

### Opção 1: Conectar via USB (Mais fácil)

**Passo 1:** Conectar telefone ao PC com cabo USB

**Passo 2:** Ativar "Depuração USB" no telefone:
- Ir a Configurações
- Sobre o telefone
- Tocar 7x em "Número da compilação"
- Voltar e entrar em "Opções do desenvolvedor"
- Ativar "Depuração USB"

**Passo 3:** Terminal (na pasta mobile_app):

```bash
flutter install
```

Esperar instalar (~30 segundos)

### ✅ App instalado! 🎉

---

### Opção 2: Cópia manual do APK

**Passo 1:** Copiar arquivo `flutter-app-release.apk`

**Passo 2:** Copiar para pendrive ou nuvem (Google Drive, etc)

**Passo 3:** No telefone:
- Abrir gerenciador de arquivos
- Navegar até o APK
- Clicar e instalar

---

### Opção 3: Email/WhatsApp

**Passo 1:** Copiar APK para pasta visível

**Passo 2:** Enviar por email/WhatsApp

**Passo 3:** No telefone, baixar e instalar

---

## ⚠️ IMPORTANTE: CONFIGURAR IP DO SERVIDOR NO APP

Antes de usar o app, você precisa dizer ao app **qual é o IP do servidor**!

### Passo 1: Descobrir IP do Servidor

**Windows (cmd):**
```bash
ipconfig
```

Procurar por "IPv4 Address" (ex: `192.168.1.100`)

**Linux:**
```bash
ifconfig
```

Procurar por "inet addr" ou "inet" (ex: `192.168.1.100`)

### Passo 2: Atualizar IP no Código

Abrir arquivo:
```
mobile_app/lib/main.dart
```

Procurar por esta linha (~linha 16):
```dart
const String SERVER_URL = 'http://192.168.1.100:8000';
```

Trocar `192.168.1.100` pelo seu IP!

**Exemplo:** Se seu IP é `192.168.1.50`:
```dart
const String SERVER_URL = 'http://192.168.1.50:8000';
```

### Passo 3: Compilar novamente

```bash
flutter build apk --release
```

Agora gerar novo APK com IP correto!

---

## 🎯 RESUMO COMPLETO

```
1️⃣  SERVIDOR (PC)
    ├─ Abrir Terminal
    ├─ cd validaçao\ tickets/local_server
    ├─ npm install (primeira vez)
    ├─ npm start
    └─ ✅ Servidor rodando em http://192.168.1.100:8000

2️⃣  TESTAR SERVIDOR
    ├─ Terminal novo
    ├─ cd validaçao\ tickets/local_server
    ├─ node test-api.js
    └─ ✅ Testes passando

3️⃣  COMPILAR APP
    ├─ Terminal novo
    ├─ cd validaçao\ tickets/mobile_app
    ├─ flutter pub get
    ├─ flutter build apk --release
    └─ ✅ APK em: build/app/outputs/flutter-app-release.apk

4️⃣  INSTALAR NOS TELEFONES
    ├─ Copiar APK
    ├─ Conectar via USB ou enviar arquivo
    ├─ Instalar
    └─ ✅ App pronto nos telefones

5️⃣  USAR!
    ├─ Abrir app
    ├─ Login (nome + email)
    ├─ Escanear QR Code
    └─ ✅ Ver resultado (verde/vermelho/amarelo)
```

---

## 🚨 PROBLEMAS COMUNS

### Problema: "npm: comando não encontrado"
**Solução:** Node.js não está instalado. Instale em https://nodejs.org

### Problema: "flutter: comando não encontido"
**Solução:** Flutter não está instalado. Instale em https://flutter.dev

### Problema: "Porta 8000 já está em uso"
**Solução:**
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux
lsof -i :8000
kill -9 <PID>
```

### Problema: "App não conecta ao servidor"
**Solução:** 
1. Verificar IP em `main.dart`
2. Verificar se servidor está rodando
3. Verificar firewall (porta 8000)
4. Ping: `ping 192.168.1.100`

### Problema: "Múltiplos APKs em build/app/outputs/"
**Solução:** Use `flutter-app-release.apk` (o maior)

---

## 📞 PRÓXIMOS PASSOS

✅ Servidor rodando  
✅ App compilado  
✅ Instalado nos telefones  

Agora:

1. Criar evento: `POST /events`
2. Sincronizar tickets: `POST /sync-tickets`
3. Começar a validar!

**Ver exemplos em:** `API_EXAMPLES.md`

---

## 💡 DICAS IMPORTANTES

**Porta 8000:**
- Todos scanners devem acessar `http://SEU_IP:8000`
- IP deve ser FIXO no router
- Não feche o terminal do servidor!

**APK:**
- Tamanho: ~40MB
- Versão: Release (otimizada)
- Android 5.0+ necessário

**Configuração:**
- IP do servidor em `main.dart`
- SECRET_KEY em `local_server/.env`
- Database criado automaticamente

---

**Qualquer dúvida, consulte:**
- `README.md` - Visão geral
- `INSTALLATION.md` - Passo a passo completo
- `API_EXAMPLES.md` - Exemplos de uso

✨ **Pronto para começar?** 🚀
