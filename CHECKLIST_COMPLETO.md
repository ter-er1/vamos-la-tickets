# ✅ CHECKLIST: Operações Passo a Passo

Use este arquivo como guia enquanto executa todas as operações!

---

## 📋 CHECKLIST 1: VERIFICAR PRÉ-REQUISITOS

Antes de tudo, verifique se seu PC tem os programas necessários:

### Node.js + npm (para o servidor)

**Windows/Linux:**
```bash
node --version
npm --version
```

Se ver versões (ex: `v16.0.0`), marque ✅

- [ ] Node.js instalado (versão 14+)
- [ ] npm instalado

**Se não tem, instale em:** https://nodejs.org (escolher LTS - versão em azul)

---

### Flutter (para compilar o app)

```bash
flutter --version
```

Se ver versão, marque ✅

- [ ] Flutter instalado (versão 3.0+)

**Se não tem, instale em:** https://flutter.dev/docs/get-started/install

---

### Android SDK (necessário para Flutter)

```bash
flutter doctor
```

Procure por ✅ em "Android toolchain"

- [ ] Android SDK configurado

---

## 📋 CHECKLIST 2: RODAR O SERVIDOR

### Passo 1: Abrir Terminal

**Windows:**
- Pressionar `Windows + R`
- Digitar `powershell`
- Clicar OK

**Linux:**
- Pressionar `Ctrl + Alt + T`

- [ ] Terminal aberto

---

### Passo 2: Navegar até pasta do servidor

```bash
cd "validaçao tickets/local_server"
```

Ou o caminho completo do seu PC.

- [ ] Dentro da pasta `local_server`

Verificar com: `pwd` (Linux) ou `cd` (Windows)

---

### Passo 3: Instalar dependências (primeira vez só!)

```bash
npm install
```

Esperar terminar (~2-3 minutos)

- [ ] Comando `npm install` executado
- [ ] Pasta `node_modules` criada

---

### Passo 4: Rodar o servidor

```bash
npm start
```

Deve ver algo assim:

```
📡 API rodando em:     http://0.0.0.0:8000
🗄️  Banco de dados:    ../database/tickets.db
✅ Pronto para receber validações!
```

- [ ] Servidor rodando
- [ ] Mensagem "Pronto para receber validações" aparecendo

**DEIXE ESTE TERMINAL ABERTO!** ⚠️

---

## 📋 CHECKLIST 3: TESTAR O SERVIDOR

### Passo 1: Abrir NOVO terminal (não feche o anterior!)

- [ ] Novo terminal aberto

---

### Passo 2: Navegar até pasta do servidor

```bash
cd "validaçao tickets/local_server"
```

- [ ] Dentro da pasta `local_server`

---

### Passo 3: Rodar testes

```bash
node test-api.js
```

Você verá:

```
✅ Evento criado
✅ Tickets sincronizados
✅ Validação 1: VÁLIDA
✅ Validação 2: JÁ USADA (duplicação bloqueada)
✅ Estatísticas obtidas

✅ TESTES CONCLUÍDOS COM SUCESSO!
```

- [ ] Todos os testes passando ✅
- [ ] Nenhum ❌ aparecendo

**Se tudo passou:** Servidor 100% funcional! 🎉

---

## 📋 CHECKLIST 4: COMPILAR O APP (Gerar APK)

### Passo 1: Abrir NOVO terminal

- [ ] Novo terminal aberto (total de 3 agora: servidor + teste + este)

---

### Passo 2: Navegar até pasta do app

```bash
cd "validaçao tickets/mobile_app"
```

- [ ] Dentro da pasta `mobile_app`

---

### Passo 3: ⚠️ IMPORTANTE - Atualizar IP do Servidor

O app precisa saber qual é o IP do seu PC servidor!

**Descobrir seu IP:**

**Windows - Command Prompt:**
```bash
ipconfig
```

Procurar por: `IPv4 Address: 192.168.X.X`

**Linux - Terminal:**
```bash
ifconfig
```

Procurar por: `inet 192.168.X.X`

- [ ] IP do servidor descoberto: `192.168.___.___.___.___.___`

**Editar arquivo:**
```
mobile_app/lib/main.dart
```

Procurar por (linha ~16):
```dart
const String SERVER_URL = 'http://192.168.1.100:8000';
```

Trocar o IP para o SEU IP!

**Exemplo:** Se seu IP é `192.168.1.50`:
```dart
const String SERVER_URL = 'http://192.168.1.50:8000';
```

- [ ] IP atualizado em `main.dart`

---

### Passo 4: Atualizar dependências Flutter

```bash
flutter pub get
```

Esperar terminar (~1 minuto)

- [ ] Comando `flutter pub get` executado
- [ ] Sem erros

---

### Passo 5: Compilar APK

```bash
flutter build apk --release
```

Esperar **5-10 minutos**... (é normal ser lento)

Você verá:
```
✓ Built build/app/outputs/flutter-app-release.apk
```

- [ ] APK compilado com sucesso
- [ ] Mensagem `Built build/app/outputs/flutter-app-release.apk` aparecendo

---

### Passo 6: Verificar se APK foi criado

```bash
ls -lh build/app/outputs/flutter-app-release.apk
```

Deve mostrar um arquivo ~40MB

- [ ] APK encontrado em `build/app/outputs/flutter-app-release.apk`
- [ ] Tamanho é maior que 30MB

---

## 📋 CHECKLIST 5: INSTALAR APK NOS TELEFONES

### Método A: Conectar via USB (Recomendado)

#### Passo 1: Preparar telefone

- [ ] Telefone conectado ao PC com cabo USB
- [ ] Autorizar conexão no telefone (toque em "Permitir")

#### Passo 2: Ativar Depuração USB

No telefone:
- Ir a **Configurações**
- Procurar **"Sobre o telefone"**
- Tocar 7x em **"Número da compilação"**
- Voltar para Configurações
- Entrar em **"Opções do desenvolvedor"** (apareceu novo)
- Ativar **"Depuração USB"**

- [ ] Depuração USB ativada
- [ ] Telefone conectado e autorizado

#### Passo 3: Instalar via Flutter

No terminal (pasta mobile_app):

```bash
flutter install
```

Esperar instalar (~30 segundos)

- [ ] App instalado no telefone
- [ ] Nenhum erro de conexão

---

### Método B: Copiar APK Manualmente

Se não quer usar USB:

#### Passo 1: Copiar arquivo

```
mobile_app/build/app/outputs/flutter-app-release.apk
```

Copiar para:
- Nuvem (Google Drive, OneDrive)
- Pendrive
- Email

- [ ] APK copiado

---

#### Passo 2: No telefone

- [ ] Abrir gerenciador de arquivos
- [ ] Navegar até o APK
- [ ] Clicar para instalar
- [ ] Autorizar instalação

---

### Método C: Via Email/WhatsApp

- [ ] Enviar `flutter-app-release.apk` por email
- [ ] No telefone, baixar arquivo
- [ ] Clicar para instalar
- [ ] Autorizar

---

## 📋 CHECKLIST 6: TESTAR O APP

### Passo 1: Abrir app no telefone

- [ ] App aparece na tela inicial (ícone de ticket)
- [ ] App abre sem erros

---

### Passo 2: Login

Preencher:
- **Nome:** João Silva (exemplo)
- **Email:** joao@evento.com

- [ ] Dados preenchidos
- [ ] Botão "ENTRAR" clicável
- [ ] Login bem-sucedido (conectou ao servidor)

---

### Passo 3: Scanner ativo

Depois do login:

- [ ] Câmera está ligada
- [ ] Tela fica preta (aguardando QR)
- [ ] Botão "Conectar" mostra servidor conectado

---

### Passo 4: Testar com QR Code

Gerar QR Code de teste:

**Terminal (raiz do projeto):**
```bash
python3 generate_qr_codes.py
```

Criar evento e gerar QR codes

- [ ] QR codes gerados em `qr_codes/` pasta

Escanear no app:
- [ ] Apontar câmera para QR code
- [ ] Resultado aparece (verde/vermelho/amarelo)
- [ ] Som beep toca

---

## 📋 CHECKLIST 7: PRODUÇÃO - MÚLTIPLOS TELEFONES

Se tudo funcionou, agora instalar em todos os telefones:

### Passo 1: Copiar APK para todos os telefones

APK está em:
```
mobile_app/build/app/outputs/flutter-app-release.apk
```

Métodos:
- [ ] Copiar via USB para cada telefone
- [ ] Ou enviar por email/nuvem

**Sugestão:** Pegar 1 pendrive, copiar APK, levar para cada telefone

---

### Passo 2: Instalar em cada telefone

Para cada telefone:
- [ ] Conectar/receber APK
- [ ] Abrir arquivo
- [ ] Instalar
- [ ] Pronto!

---

### Passo 3: Configurar cada telefone

Para cada telefone:
- [ ] Abrir app
- [ ] Fazer login (nome + email)
- [ ] Testar com 1 QR code
- [ ] Confirmar que conecta ao servidor

---

## 🎯 RESUMO: Como usar no dia do evento

### Antes do evento:

- [ ] Servidor rodando no PC (npm start)
- [ ] Todos os telefones com app instalado
- [ ] Todos logados no app
- [ ] Testar com alguns QR codes

### Durante o evento:

- [ ] Manter servidor rodando o tempo todo
- [ ] Scanners apontando para QR codes
- [ ] Resultados aparecendo (verde = OK)
- [ ] Duplicação automaticamente bloqueada

### Depois:

- [ ] Estatísticas em: `GET /stats`
- [ ] Logs em: `GET /logs`
- [ ] Database salvo em: `/database/tickets.db`

---

## 🚨 SE ALGO DER ERRADO

### Servidor não começa (porta 8000 em uso)

**Windows:**
```bash
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

**Linux:**
```bash
lsof -i :8000
kill -9 <PID>
```

- [ ] Porta liberada

---

### App não conecta ao servidor

**Verificar:**
- [ ] IP em `main.dart` está correto?
- [ ] Servidor está rodando?
- [ ] Telefone e PC na mesma rede WiFi?
- [ ] Firewall permite porta 8000?

**Testar conexão:**
```bash
ping 192.168.1.100
```

(substituir IP)

---

### APK não instala

- [ ] Android versão 5.0+?
- [ ] Espaço livre no telefone?
- [ ] Origem "Desconhecida" ativada em Configurações?

---

### Testes não passam

- [ ] Servidor está rodando?
- [ ] Não há erros em outro terminal?
- [ ] Database não corrompido?

Reconstruir database:
```bash
rm database/tickets.db
npm start
```

---

## ✨ PRONTO! 🎉

Se todos os checkboxes estão ✅:

1. ✅ Pré-requisitos instalados
2. ✅ Servidor rodando
3. ✅ Testes passando
4. ✅ APK compilado
5. ✅ App instalado em telefones
6. ✅ Login funcionando
7. ✅ Escanear QR codes funcionando

**Seu sistema está 100% pronto para usar!**

---

## 📞 PRÓXIMOS PASSOS

1. Criar evento para o seu evento
2. Exportar lista de ingressos (tickets)
3. Gerar QR codes
4. Instalar app em 6 telefones (ou quantos tiver)
5. Começar a validar no dia do evento!

**Ver:** `API_EXAMPLES.md` para exemplos de API

---

**Boa sorte! 🚀**
