# ✓ Checklist Pre-Launch - GitHub Actions

## 🔍 Verificações Finais

### **Verificar Arquivos Criados**

```bash
cd ~/validaçao\ tickets

# Verificar que workflow existe
ls -la .github/workflows/build-apk.yml

# Deve mostrar:
# -rw-r--r-- ... .github/workflows/build-apk.yml
```

✅ Se arquivo existe → OK!
❌ Se não existir → ERRO (será informado)

---

### **Verificar Git Configurado**

```bash
# Ver status
git status

# Deve mostrar: "On branch main" (ou master)
# Se não tem branch, criar:
git branch -M main
```

✅ Se viu "On branch main" → OK!
❌ Se erro → Executar acima

---

### **Verificar Documentação**

```bash
cd ~/validaçao\ tickets

# Listar documentação criada
ls -la *.md | head -20

# Deve ter:
# - COMECE_AGORA.md
# - COMANDOS_PRONTOS.md
# - FLUXOGRAMA_VISUAL.md
# - Outros...
```

✅ Se todos arquivos estão → OK!
❌ Se alguns faltam → Avise

---

## 🔐 Verificar Código

### **Flutter Project Exists**

```bash
# Verificar Flutter project
ls -la mobile_app/pubspec.yaml
ls -la mobile_app/lib/main.dart

# Ambos devem existir
```

✅ Se existem → OK!
❌ Se faltam → ERRO crítico

---

### **Server Project Exists**

```bash
# Verificar server
ls -la local_server/server.js
ls -la local_server/package.json

# Ambos devem existir
```

✅ Se existem → OK!
❌ Se faltam → ERRO crítico

---

## 🧪 Teste Rápido: Pode Fazer Push?

```bash
cd ~/validaçao\ tickets

# Ver status
git status

# Deve mostrar:
# On branch main
# nothing to commit, working tree clean

# OU (se houver mudanças):
# On branch main
# Changes not staged for commit:
#   modified: arquivo.txt
```

✅ Se mostrou isso → OK, pode fazer push!
❌ Se erro de git → Avise

---

## 📋 Checklist Final

```
Preparação:
  ☑ Workflow .github/workflows/build-apk.yml existe
  ☑ Documentação criada
  ☑ Git funcionando (git status OK)
  ☑ Flutter project em mobile_app/
  ☑ Server project em local_server/

Pronto para GitHub:
  ☑ Tem conta GitHub
  ☑ Terminal aberto em ~/validaçao tickets
  ☑ SSH key ou token GitHub configurado (opcional, pode usar HTTPS)

Próximo:
  ☑ Criar repositório em https://github.com/new
  ☑ Copiar URL
  ☑ git remote add origin [URL]
  ☑ git push -u origin main
```

---

## 🚦 Verde para Começar?

Se TODAS as verificações passaram ✅:

**PARABÉNS! Você está 100% pronto para começar!**

1. Abra: `COMECE_AGORA.md`
2. Siga as instruções
3. Aguarde APK 🎉

---

## 🆘 Algo Deu Errado?

### **"Workflow não existe"**
```bash
# Criar pasta
mkdir -p ~/.github/workflows

# Arquivo será recriado automaticamente
```

### **"Git diz erro"**
```bash
cd ~/validaçao\ tickets
git init
git config user.name "Seu Nome"
git config user.email "email@gmail.com"
```

### **"Flutter project não existe"**
❌ ERRO CRÍTICO - Avise ao assistente

### **"Documentação não encontrada"**
Já foi criada. Se não vê, execute:
```bash
ls -la ~/validaçao\ tickets/*.md
```

---

## ✅ Status Verde?

Todos os ✅ aparecem acima?

**SIM → Vá para `COMECE_AGORA.md`** 🚀

**NÃO → Avise qual falhou acima** 🆘
