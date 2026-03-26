# 🚀 Quick Start - GitHub Actions Build

## Em 5 Minutos:

### 1️⃣ **Criar Repositório GitHub**
Vá para: https://github.com/new
- Nome: `vamos-la-tickets`
- Deixe vazio (não inicialize)
- Clique "Create repository"

---

### 2️⃣ **Conectar seu código ao GitHub**

```bash
cd ~/validaçao\ tickets

# Copiar o URL do repositório criado (github.com/SEU_USUARIO/vamos-la-tickets.git)
# Colar aqui:
git remote add origin https://github.com/SEU_USUARIO/vamos-la-tickets.git

# Fazer push inicial
git add -A
git commit -m "Vamos Lá Tickets - v1.0"
git branch -M main
git push -u origin main
```

---

### 3️⃣ **Acompanhar Build**

Vá para: https://github.com/SEU_USUARIO/vamos-la-tickets
- Clique em "**Actions**"
- Veja o status (🟡 Running → ✅ Success)

---

### 4️⃣ **Baixar APK** (quando terminar ~20min)

#### **Opção A - Artifacts (Mais rápido):**
1. Clique no workflow (ex: "Build Flutter APK")
2. Scroll para baixo → "Artifacts"
3. Clique `flutter-app-apk` → download

#### **Opção B - Releases (Melhor):**
1. Lado direito → "Releases"
2. Clique na release → `app-release.apk` → download

---

## ✨ Pronto!

**APK pronto para instalar!** 🎉

```bash
# Instalar via ADB (Android Debug Bridge)
adb install -r ~/Downloads/app-release.apk

# Ou copie manualmente para o telefone via USB
```

---

## 🔄 Recompilar Mudanças

Sempre que fizer mudanças no código:

```bash
cd ~/validaçao\ tickets
git add -A
git commit -m "Descrição da mudança"
git push origin main
```

GitHub Actions recompila **automaticamente** 🤖

---

## 📞 Problemas?

| Problema | Solução |
|----------|---------|
| Workflow falha | Clique no workflow → veja erro em vermelho |
| Não vê Artifacts | Espere 20 minutos, workflow ainda rodando |
| APK não instala | Telefone precisa de Android 5.0+ |
| Git não funciona | `git init` na pasta antes de fazer push |

---

## 🎯 Próximo Passo:

→ **Instalar APK no telefone**
