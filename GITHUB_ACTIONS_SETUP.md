# 🚀 GitHub Actions - Build APK Automaticamente

## ✨ O que é?

Workflow que compila o APK automaticamente na nuvem (servidor GitHub) sempre que você fazer **push** no repositório.

**Vantagens:**
- ✅ Não precisa de internet estável localmente
- ✅ Não precisa de RAM insuficiente (GitHub fornece máquinas potentes)
- ✅ Compila em paralelo com seu desenvolvimento
- ✅ APK pronto para download em ~15-20 minutos

---

## 📋 Como Usar:

### **Passo 1: Criar Repositório GitHub**

Se não tiver repositório Git ainda:

```bash
cd ~/validaçao\ tickets
git init
git config user.email "seu-email@gmail.com"
git config user.name "Seu Nome"
```

Se já tiver repositório, apenas prossiga.

---

### **Passo 2: Adicionar Repositório Remoto (GitHub)**

1. Vá para: https://github.com/new
2. Crie um repositório chamado `vamos-la-tickets`
3. NÃO inicialize com README (deixe vazio)
4. Clique em "Create repository"

Copie o URL do repositório (ex: `https://github.com/SEU_USUARIO/vamos-la-tickets.git`)

No terminal:
```bash
cd ~/validaçao\ tickets

# Adicionar repositório remoto
git remote add origin https://github.com/SEU_USUARIO/vamos-la-tickets.git

# Verificar que foi adicionado corretamente
git remote -v
```

---

### **Passo 3: Fazer Push do Código**

```bash
cd ~/validaçao\ tickets

# Adicionar todos os arquivos
git add -A

# Commit
git commit -m "Vamos Lá Tickets - Release 1.0.0"

# Push para main branch
git branch -M main
git push -u origin main
```

---

### **Passo 4: Acompanhar a Compilação**

1. Vá para: `https://github.com/SEU_USUARIO/vamos-la-tickets`
2. Clique em "**Actions**" (abas no topo)
3. Veja o workflow em execução (status: 🟡 In Progress)

Tempo esperado: **15-20 minutos**

---

### **Passo 5: Baixar o APK Compilado**

Quando o workflow terminar:

**Opção A - Via Artifacts (Recomendado):**
1. Clique no workflow executado (ex: "Build Flutter APK")
2. Scroll até o final → "Artifacts"
3. Clique em `flutter-app-apk` → downloads automaticamente

**Opção B - Via Release (Melhor):**
1. Vá para "Releases" → lado direito do repo
2. Clique na release mais recente (ex: "apk-123456")
3. Clique em `app-release.apk` para download

---

### **Passo 6: Verificar o APK**

```bash
# Listar arquivo
ls -lh app-release.apk

# Verificar tipo de arquivo
file app-release.apk

# Deve mostrar: "Zip archive data, at least v2.0 to extract"
```

**Tamanho esperado:** 15-20 MB (ARM64 Release)

---

## ⚙️ Troubleshooting:

### ❌ Workflow falhou?

1. Clique no workflow na aba "Actions"
2. Procure por **❌ Build Failed** ou erro em vermelho
3. Veja o log completo na seção "Build APK"
4. Erros comuns:
   - **Erro de dependência**: Pode ser que uma dependência não funcione no Ubuntu. Solução: Adicione `--no-sound` ao comando flutter.
   - **Erro de timeout**: GitHub tem limite de ~1 hora. Se ultrapassar, tente novamente (raro).

### 🔄 Recompilar?

Se precisar recompilar (sem fazer commit novo):

1. Vá para "Actions" → "Build Flutter APK"
2. Clique em "Run workflow" (botão azul no canto direito)
3. Selecione a branch `main`
4. Clique "Run workflow"

A compilação começará novamente.

---

## 📊 Monitoramento:

Para acompanhar sem abrir GitHub:

```bash
# Verificar status do repositório
cd ~/validaçao\ tickets
git status

# Ver commits recentes
git log --oneline -5

# Puxar mudanças (se compilar em outro PC)
git pull origin main
```

---

## 💾 Salvando Mudanças Futuras:

Toda vez que fizer mudanças no código:

```bash
cd ~/validaçao\ tickets

# Ver o que mudou
git status

# Adicionar tudo
git add -A

# Commit com mensagem descritiva
git commit -m "Descrição do que mudou"

# Push para GitHub (workflow inicia automaticamente)
git push origin main
```

---

## 🎯 Próximos Passos:

1. **Compilação concluída** → Download APK ✅
2. **Instalar em Android** → `adb install app-release.apk`
3. **Testar no telefone** → Abrir app → Settings → configurar IP do servidor local
4. **Validar QR codes** → Scanner → testa com código de teste

---

## 📞 Dúvidas?

- **Workflow não dispara?** → Verifique se fez push na branch `main`
- **Não vê Artifacts?** → Workflow está ainda executando ou falhou
- **APK não instala?** → Pode ser incompatibilidade. Verifique Android version mínima
