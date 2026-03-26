# ⚡ QUICK START - Comece AGORA em 10 minutos!

Se você quer começar rapidão, leia só isto! ⚡

---

## 🎯 RESUMÃO (TL;DR)

```
1. cd validaçao\ tickets/local_server
2. npm install
3. npm start         ← DEIXE RODANDO

4. (novo terminal)
5. cd validaçao\ tickets/mobile_app
6. flutter pub get
7. flutter build apk --release

8. Instalar APK nos telefones
9. Abrir app → fazer login → escanear QR = ✅
```

---

## 🚀 PASSO 1: RODAR SERVIDOR (2 minutos)

### Terminal 1:

```bash
cd "validaçao tickets/local_server"
npm install
npm start
```

Você verá:
```
📡 API rodando em:     http://0.0.0.0:8000
✅ Pronto para receber validações!
```

✅ **Deixe ABERTO**

---

## 🧪 PASSO 2: TESTAR SERVIDOR (1 minuto)

### Terminal 2 (novo):

```bash
cd "validaçao tickets/local_server"
node test-api.js
```

Você verá:
```
✅ Evento criado
✅ Tickets sincronizados
✅ Validação: VÁLIDA
✅ Duplicação: BLOQUEADA
✅ TESTES CONCLUÍDOS!
```

✅ **Servidor 100% OK**

---

## 🔨 PASSO 3: COMPILAR APP (5-10 minutos)

### Terminal 3 (novo):

**IMPORTANTE:** Primeiro, atualizar IP em `mobile_app/lib/main.dart`

Procure por (linha ~16):
```dart
const String SERVER_URL = 'http://192.168.1.100:8000';
```

Trocar para seu IP real (ex: `192.168.1.50`):
```dart
const String SERVER_URL = 'http://192.168.1.50:8000';
```

Depois:

```bash
cd "validaçao tickets/mobile_app"
flutter pub get
flutter build apk --release
```

Esperar 5-10 minutos...

Resultado:
```
✓ Built build/app/outputs/flutter-app-release.apk
```

✅ **APK pronto**

---

## 📱 PASSO 4: INSTALAR NOS TELEFONES (5 minutos)

Arquivo está em:
```
mobile_app/build/app/outputs/flutter-app-release.apk
```

### Conectar via USB:

```bash
flutter install
```

### Ou copiar APK:

1. Copiar `flutter-app-release.apk`
2. Colocar no pendrive/cloud
3. No telefone, abrir e instalar

✅ **App instalado**

---

## 🎯 PASSO 5: USAR (1 minuto)

1. Abrir app no telefone
2. Login: `Nome` + `Email`
3. Câmera abre
4. Escanear QR code
5. Ver resultado (verde/vermelho)

✅ **FUNCIONANDO!**

---

## 🗺️ ONDE ESTÁ TUDO?

```
validaçao tickets/
├─ local_server/          ← SERVIDOR (npm start aqui)
├─ mobile_app/            ← APP (flutter build aqui)
├─ database/              ← DATABASE (criado automaticamente)
├─ qr_codes/              ← QR CODES (gerar com script)
└─ RODAR_SERVIDOR_E_APP.md ← GUIA COMPLETO
```

---

## ⚠️ IMPORTANTE

✅ **Servidor rodando:** `npm start` no Terminal 1  
✅ **IP correto:** Atualizar em `main.dart` antes de compilar  
✅ **Mesma rede:** Servidor e telefones na mesma WiFi  
✅ **Deixe aberto:** Não fechar terminal do servidor!

---

## 🆘 ERROS COMUNS

| Erro | Solução |
|------|---------|
| "npm: command not found" | Instalar Node.js: https://nodejs.org |
| "flutter: command not found" | Instalar Flutter: https://flutter.dev |
| "Porta 8000 em uso" | `lsof -i :8000 && kill -9 PID` |
| "App não conecta" | Verificar IP em main.dart |
| "Testes falhando" | Servidor não está rodando |

---

## 📞 PRÓXIMOS PASSOS

**Ver arquivos completos:**
- `RODAR_SERVIDOR_E_APP.md` - Guia visual completo
- `CHECKLIST_COMPLETO.md` - Passo a passo com verificações
- `README.md` - Visão geral do projeto
- `API_EXAMPLES.md` - Como usar a API

---

## 🎉 PRONTO!

Seu sistema está funcionando! Agora:

1. Criar evento
2. Gerar QR codes
3. Validar ingressos
4. Pronto! 🚀

**Qualquer dúvida, volte aqui ou leia o guia completo!**
