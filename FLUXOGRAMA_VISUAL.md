# 🎨 Fluxograma Visual - GitHub Actions APK Build

## Fluxo Completo (De ponta a ponta)

```
┌─────────────────────────────────────────────────────────────────┐
│                    SEU COMPUTADOR                               │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 1. SETUP GIT LOCAL (1 min)                              │  │
│  │                                                          │  │
│  │  $ git init                                             │  │
│  │  $ git remote add origin [GitHub-URL]                  │  │
│  │  $ git add -A                                           │  │
│  │  $ git commit -m "v1.0"                                 │  │
│  │  $ git push -u origin main                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                     │
│           ▼                                                     │
└─────────────────────────────────────────────────────────────────┘
            │
            │ 📤 PUSH
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB.COM                                   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 2. WEBHOOK DETECTA PUSH (automático)                    │  │
│  │                                                          │  │
│  │  ✅ Novo commit detectado                               │  │
│  │  ✅ Branch = main                                       │  │
│  │  ✅ Workflow .github/workflows/build-apk.yml DISPARA    │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 3. GITHUB ACTIONS RUNNER (20 min)                       │  │
│  │                                                          │  │
│  │  🟡 Status: IN PROGRESS                                 │  │
│  │                                                          │  │
│  │  ├─ ✅ Checkout code (1 min)                            │  │
│  │  ├─ ✅ Setup Java 17 (1 min)                            │  │
│  │  ├─ ✅ Setup Flutter 3.32.2 (2 min)                    │  │
│  │  ├─ ✅ flutter pub get (2 min)                          │  │
│  │  ├─ ⏳ Build APK (10-12 min)  ← ETAPA LONGA            │  │
│  │  │  ├─ Gradle compile                                  │  │
│  │  │  ├─ Flutter build                                   │  │
│  │  │  ├─ DEX merge                                       │  │
│  │  │  └─ Package APK                                     │  │
│  │  ├─ ✅ Upload Artifact (1 min)                         │  │
│  │  └─ ✅ Create Release (1 min)                          │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 4. BUILD CONCLUÍDO ✅                                   │  │
│  │                                                          │  │
│  │  APK Pronto: app-release.apk (17 MB)                    │  │
│  │  Disponível em:                                         │  │
│  │   - Artifacts                                           │  │
│  │   - Releases → Downloads                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                     │
└─────────────────────────────────────────────────────────────────┘
            │
            │ 📥 DOWNLOAD APK
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SEU COMPUTADOR                               │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 5. INSTALAR NO TELEFONE (2 min)                        │  │
│  │                                                          │  │
│  │  $ adb install -r ~/Downloads/app-release.apk           │  │
│  │                                                          │  │
│  │  ✅ Installation successful!                            │  │
│  │                                                          │  │
│  │  Ícone aparece na home do telefone                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ 6. CONFIGURAR & USAR APP (5 min)                        │  │
│  │                                                          │  │
│  │  ✅ Abrir app                                           │  │
│  │  ✅ Settings → Adicionar servidor IP                   │  │
│  │  ✅ Login com credenciais                              │  │
│  │  ✅ Abrir Scanner                                       │  │
│  │  ✅ Apontar para QR code                                │  │
│  │  ✅ ✔️ Validação concluída!                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ ✅ SUCESSO! APP FUNCIONANDO! 🎉                         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Timeline Estimado

```
┌──────┬──────────────┬──────────────────────────────────────────┐
│ Fase │    Tempo     │ O que Acontece                           │
├──────┼──────────────┼──────────────────────────────────────────┤
│  1   │   ~1 min     │ Git setup + push                         │
├──────┼──────────────┼──────────────────────────────────────────┤
│  2   │   ~1 min     │ GitHub detecta mudança                   │
├──────┼──────────────┼──────────────────────────────────────────┤
│  3   │  ~20 min     │ GitHub Actions compila                   │
│      │ (⏳ ESPERE)  │  • Java setup: 2 min                     │
│      │              │  • Flutter setup: 2 min                  │
│      │              │  • Dependencies: 2 min                   │
│      │              │  • Build APK: 12 min (longo!)            │
│      │              │  • Upload: 2 min                         │
├──────┼──────────────┼──────────────────────────────────────────┤
│  4   │   ~1 min     │ Download APK                             │
├──────┼──────────────┼──────────────────────────────────────────┤
│  5   │   ~2 min     │ adb install                              │
├──────┼──────────────┼──────────────────────────────────────────┤
│  6   │   ~5 min     │ Configurar e testar app                  │
├──────┼──────────────┼──────────────────────────────────────────┤
│TOTAL │   ~30 min    │ DO INÍCIO AO APP FUNCIONANDO 🎉          │
└──────┴──────────────┴──────────────────────────────────────────┘
```

---

## O Que Você Faz vs O Que GitHub Faz

```
┌─────────────────────────────────────────┐
│         VOCÊ (seu computador)           │
│                                         │
│  ✓ git init                             │
│  ✓ git remote add origin [URL]          │
│  ✓ git add -A                           │
│  ✓ git commit -m "..."                  │
│  ✓ git push ← ISTO!                     │
│                                         │
│  ... ESPERA 20 MINUTOS ...              │
│                                         │
│  ✓ Download APK                         │
│  ✓ adb install                          │
│  ✓ Testar app                           │
└─────────────────────────────────────────┘
       ↓ (automático)
┌─────────────────────────────────────────┐
│      GITHUB ACTIONS (nuvem)             │
│    (você NÃO FIZER NADA AQUI!)          │
│                                         │
│  • Checkout seu código                  │
│  • Setup Java + Flutter                 │
│  • Instala dependências                 │
│  • Compila APK                          │
│  • Uploads artefatos                    │
│  • Cria Release                         │
│                                         │
│  ✅ PRONTO! → volta para você           │
└─────────────────────────────────────────┘
```

---

## Onde Encontrar Cada Coisa

```
GitHub → Seu Repositório
│
├─ 📁 Code (aba)
│  └─ Seus arquivos aparecem aqui
│
├─ 🤖 Actions (aba)
│  └─ "Build Flutter APK" workflow
│     ├─ 🟡 In Progress (executando)
│     └─ ✅ Success (pronto!)
│
├─ 📦 Artifacts (dentro do workflow)
│  └─ flutter-app-apk → DOWNLOAD APK
│
└─ 📤 Releases (aba)
   └─ apk-123456
      └─ app-release.apk → DOWNLOAD APK
```

---

## Sinais de Progresso

```
🟡 YELLOW = Compilando (ESPERE!)
   ↓
✅ GREEN = Pronto! (DOWNLOAD!)
   ↓
❌ RED = Erro (veja TROUBLESHOOTING.md)
```

---

## Checklist Visual

```
ANTES:
  ☐ Repositório GitHub criado
  ☐ URL copiada
  ☐ Código local pronto

DURANTE PUSH:
  ☐ git add -A
  ☐ git commit
  ☐ git push

NA NUVEM:
  ☐ Workflow iniciou (🟡)
  ☐ Esperou 20 minutos
  ☐ Workflow completou (✅)

DOWNLOAD:
  ☐ APK (~17 MB) baixado
  ☐ Arquivo verificado

INSTALAR:
  ☐ Telefone via USB conectado
  ☐ adb install executado
  ☐ App instalado (ícone visible)

USAR:
  ☐ App abre (splash screen)
  ☐ Configurar IP do servidor
  ☐ Login com credenciais
  ☐ Scanner funciona
  ☐ QR code valida com sucesso ✅
```

---

## Alternativas de Download

```
OPÇÃO 1 - ARTIFACTS (mais rápido):
  GitHub → Actions → Build Flutter APK → Artifacts → flutter-app-apk

OPÇÃO 2 - RELEASES (mais seguro):
  GitHub → Releases → apk-[numero] → app-release.apk

OPÇÃO 3 - DIRETO DO PC:
  Não precisa GitHub web, direct download link nos logs
```

---

## Suporte Rápido

```
❓ "Workflow não iniciou?"
   → Confirme push foi enviado: git push -u origin main

❓ "Workflow falhou?"
   → Veja logs: Actions → Build Flutter APK → erro em vermelho

❓ "APK não aparece?"
   → Workflow ainda executando (espere 20 min)

❓ "APK não instala?"
   → Verifique Android version (5.0+) ou reinstale

❓ "App não abre?"
   → Permissões de câmera desativadas
```

---

## 🚀 Próximo Passo

**Copie os comandos de `COMANDOS_PRONTOS.md` e execute!**

→ https://github.com/SEU_USUARIO/vamos-la-tickets (após fazer push)
