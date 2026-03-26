# 🗺️ MAPA MENTAL: ENTENDER SEU SISTEMA

Use este arquivo para visualizar como tudo funciona junto!

---

## 📍 ONDE ESTÁ CADA COISA?

```
Seu Computador
├─ SERVIDOR
│  ├─ local_server/
│  │  ├─ server.js (código principal)
│  │  ├─ package.json (dependências)
│  │  └─ test-api.js (testes)
│  │
│  ├─ DATABASE
│  │  └─ database/tickets.db (SQLite)
│  │
│  └─ RODANDO COM: npm start (Porta 8000)
│
├─ APP (código fonte)
│  ├─ mobile_app/
│  │  ├─ lib/ (código do app)
│  │  ├─ pubspec.yaml (dependências flutter)
│  │  └─ build/ (resultado final)
│  │     └─ flutter-app-release.apk (INSTALAR NOS TELEFONES)
│  │
│  └─ COMPILADO COM: flutter build apk --release
│
├─ QR CODES
│  ├─ generate_qr_codes.py (gerar)
│  └─ qr_codes/ (armazenar)
│
└─ DOCUMENTAÇÃO
   ├─ LEIA_PRIMEIRO.txt (comece aqui)
   ├─ COMECE_AQUI.md
   ├─ QUICK_START.md
   ├─ RODAR_SERVIDOR_E_APP.md
   ├─ CHECKLIST_COMPLETO.md
   ├─ API_EXAMPLES.md
   └─ etc...
```

---

## 🔄 FLUXO DE DADOS

```
┌────────────────────────────────────────────────────────────────┐
│                    SEU COMPUTADOR (PC)                         │
│                                                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │          NODE.JS SERVER (Porta 8000)                    │  │
│  │                                                         │  │
│  │  Endpoints:                                             │  │
│  │  ├─ POST /events (criar evento)                         │  │
│  │  ├─ POST /sync-tickets (carregar ingressos)             │  │
│  │  ├─ POST /validate-ticket (VALIDAR INGRESSO)            │  │
│  │  ├─ GET /stats (estatísticas)                           │  │
│  │  ├─ GET /logs (histórico)                               │  │
│  │  └─ GET /health (está online?)                          │  │
│  │                                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│         ▲                     │                                │
│         │ Lê                  │ Escreve                        │
│         │                     ▼                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │          SQLITE DATABASE (tickets.db)                   │  │
│  │                                                         │  │
│  │  Tabelas:                                               │  │
│  │  ├─ events (eventos)                                    │  │
│  │  ├─ tickets (ingressos com status: valid/used)          │  │
│  │  └─ validation_logs (todas validações)                  │  │
│  │                                                         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
                           ▲  ▼
                    WiFi / HTTP
                    (mesma rede LAN)
                    (JSON)
         ┌──────────┴──────────┐
         │                     │
    ┌─────────────────┐   ┌─────────────────┐
    │    TELEFONE 1   │   │    TELEFONE 2   │
    │   (Flutter)     │   │   (Flutter)     │
    │                 │   │                 │
    │ Scanner 1       │   │ Scanner 2       │
    │ Login + QR      │   │ Login + QR      │
    │ Cache local     │   │ Cache local     │
    │                 │   │                 │
    │ Resultado:      │   │ Resultado:      │
    │ 🟢 Verde OK     │   │ 🟡 Amarelo Dup. │
    │ 🔔 Som beep     │   │ 🔔 Som beep     │
    └─────────────────┘   └─────────────────┘
```

---

## 🔐 COMO A VALIDAÇÃO FUNCIONA

```
PASSO 1: GERAR QR CODE
┌──────────────────────────────────────────┐
│ ticket_id = ABC123                       │
│ SECRET_KEY = meu-segredo-super-secreto   │
│                                          │
│ HMAC = SHA256(ABC123 + segredo)          │
│ HMAC = a7f3c9d8e1b5f2g4h6i8j0k2         │
│                                          │
│ QR = "ABC123:a7f3c9d8e1b5f2g4h6i8j0k2" │
│                                          │
│ (HMAC é único e impossível falsificar)  │
└──────────────────────────────────────────┘

PASSO 2: ESCANEAR
┌──────────────────────────────────────────┐
│ App lê QR code                           │
│ Extrai: ticket_id = ABC123              │
│ Extrai: HMAC = a7f3c9d8e1b5f2g4h6i8j0k2 │
│ Envia ao servidor                       │
└──────────────────────────────────────────┘

PASSO 3: SERVIDOR VALIDA
┌──────────────────────────────────────────┐
│ 1. Recebe ABC123 + HMAC                 │
│ 2. Recalcula: SHA256(ABC123 + segredo)  │
│ 3. Compara HMACs                        │
│    ✅ Iguais? = QR válido, não falsificado
│    ❌ Diferentes? = QR FALSIFICADO! Rejeitar
│                                          │
│ 4. Se válido, busca no banco             │
│    ✅ Encontrado?                        │
│    ❌ Não encontrado? = Ingresso inválido
│                                          │
│ 5. Verifica status                      │
│    ✅ Status='valid'? = Primeiro uso OK  │
│    ❌ Status='used'? = JÁ FOI USADO!     │
│                                          │
│ 6. UPDATE ATÔMICO                       │
│    UPDATE tickets SET status='used'     │
│    WHERE id='ABC123' AND status='valid' │
│    (tudo ou nada - zero chance de dup.) │
│                                          │
│ 7. Retorna resultado ao app             │
└──────────────────────────────────────────┘

PASSO 4: APP MOSTRA RESULTADO
┌──────────────────────────────────────────┐
│ 🟢 VERDE = Validado com sucesso          │
│ 🟡 AMARELO = Já foi validado antes      │
│ 🔴 VERMELHO = Ingressso inválido/falsif. │
│                                          │
│ 🔊 BEEP! = Som de confirmação           │
│                                          │
│ ✅ Histórico salvo no servidor           │
└──────────────────────────────────────────┘
```

---

## 📊 ARQUITETURA EM CAMADAS

```
┌─────────────────────────────────────┐
│  CAMADA 1: INTERFACE (User)         │
│  ├─ Tela de login                   │
│  ├─ Câmera QR                       │
│  └─ Resultado (verde/amarelo/vermel)│
└──────────┬──────────────────────────┘
           │ Flutter
┌──────────▼──────────────────────────┐
│  CAMADA 2: APLICAÇÃO (Mobile App)   │
│  ├─ Scanner: mobile_scanner         │
│  ├─ HTTP: requisições ao servidor   │
│  ├─ Criptografia: HMAC-SHA256       │
│  ├─ Storage local: SQLite           │
│  ├─ Cache: dados offline            │
│  └─ State: Provider pattern         │
└──────────┬──────────────────────────┘
           │ HTTP/WiFi LAN
┌──────────▼──────────────────────────┐
│  CAMADA 3: API (Servidor)           │
│  ├─ Express.js                      │
│  ├─ 7 endpoints REST                │
│  ├─ HMAC validation                 │
│  ├─ Business logic                  │
│  ├─ Atomic updates                  │
│  └─ Logging                         │
└──────────┬──────────────────────────┘
           │ SQL
┌──────────▼──────────────────────────┐
│  CAMADA 4: DATABASE (SQLite)        │
│  ├─ Tabela: events                  │
│  ├─ Tabela: tickets                 │
│  ├─ Tabela: validation_logs         │
│  ├─ Índices                         │
│  └─ Transações ACID                 │
└─────────────────────────────────────┘
```

---

## 🎯 QUEM FAZ O QUÊ?

```
PC (Servidor)                Telefone (App)
──────────────────          ──────────────
│                           │
│ npm start                 │ flutter build apk
│ ├─ Inicia API             │ ├─ Compila código
│ │  (ouve porta 8000)      │ │
│ ├─ Abre database          │ └─ Gera APK
│ │  (SQLite)               │    (instalável)
│ └─ Pronto para            │
│    requisições            │ flutter install
│                           │ ├─ Copia APK
│ Quando app envia:         │ ├─ Instala
│ ├─ Valida HMAC            │ └─ Pronto!
│ ├─ Busca no banco         │
│ ├─ Verifica status        │ Ao usar:
│ ├─ UPDATE atômico         │ ├─ Faz login
│ ├─ Registra log           │ ├─ Liga câmera
│ ├─ Retorna resultado      │ ├─ Escaneia QR
│ └─ E3.js fica escutando   │ ├─ Envia ao servidor
│                           │ ├─ Recebe resultado
│                           │ ├─ Mostra na tela
│                           │ └─ Faz beep
```

---

## 📈 FLUXO TEMPORAL

```
TIMELINE DE OPERAÇÃO:

T=0       Usuário inicia sistema
          ├─ npm start (servidor)
          └─ APK já instalado nos telefones

T=+1min   Servidor pronto
          └─ Aguardando conexões

T=+X      Staff abre app no telefone
          ├─ Faz login
          ├─ App conecta ao servidor
          └─ Câmera ativa

T=+Y      Escaneia QR code
          ├─ App lê código
          ├─ Envia ao servidor
          ├─ Servidor processa
          ├─ Retorna resultado
          ├─ App mostra (0.2s)
          └─ Beep! 🔊

T=+Y+1s   Próximo ingresso
          └─ Repeat...

MÚLTIPLOS TELEFONES:
T=+Y      Telefone 1: escaneia
T=+Y+20ms Telefone 2: escaneia (simultâneo!)
T=+Y+40ms Telefone 3: escaneia (simultâneo!)
          Servidor processa todos atomicamente
          (até 6 simultâneos sem problema)
```

---

## 🔍 MAPA DE DOCUMENTAÇÃO

```
PRECISO DE:                           LEIA:
─────────────────────────────────────────────────────
Como começar rápido?                LEIA_PRIMEIRO.txt
Respostas às 2 perguntas?            COMECE_AQUI.md
Guia visual com figuras?             RODAR_SERVIDOR_E_APP.md
Passo a passo verificado?            CHECKLIST_COMPLETO.md
Exemplos de código?                  API_EXAMPLES.md
Toda informação técnica?             README_COMPLETO.md
Navegação por tópico?                ÍNDICE.md
Resumo super rápido?                 QUICK_START.md
Resposta direta?                     RESPOSTA_DIRETA.md
Diagrama ASCII?                      GUIA_RÁPIDO.txt
Entender a arquitetura?              Este arquivo (MAPA_MENTAL.md)
```

---

## ✨ RESUMO EM UMA IMAGEM

```
                    ┌─────────────┐
                    │   Usuário   │
                    └──────┬──────┘
                           │
                ┌──────────┴──────────┐
                │                     │
          ┌─────▼─────┐         ┌─────▼─────┐
          │ Telefone  │         │ Telefone  │
          │  Android  │         │  Android  │
          │  (app)    │         │  (app)    │
          └─────┬─────┘         └─────┬─────┘
                │                     │
                └──────────┬──────────┘
                           │
                        WiFi/LAN
                           │
                ┌──────────▼──────────┐
                │    Servidor PC      │
                │  (Node.js Express)  │
                │    Porta 8000       │
                └──────────┬──────────┘
                           │
                        SQL │
                           │
                ┌──────────▼──────────┐
                │   SQLite Database   │
                │   (tickets.db)      │
                └─────────────────────┘
                
 ✅ Tudo conectado via HTTP/JSON
 ✅ Criptografia HMAC-SHA256
 ✅ Bloqueio de duplicatas
 ✅ Cache offline funcional
 ✅ Performance <500ms
```

---

## 🚀 PRÓXIMA AÇÃO

Agora que você entende a arquitetura, escolha:

1. **Começar agora** → `COMECE_AQUI.md`
2. **Ver guia visual** → `RODAR_SERVIDOR_E_APP.md`
3. **Passo a passo** → `CHECKLIST_COMPLETO.md`
4. **Mais detalhes** → `README_COMPLETO.md`

---

**Entendeu o fluxo? Agora comece a usar! 🚀**
