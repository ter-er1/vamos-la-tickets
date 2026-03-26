# 📋 Copiar & Colar - Comandos Prontos

## 1️⃣ Setup Local Git

Copie exatamente ISSO e execute no terminal:

```bash
cd ~/validaçao\ tickets
git init
git config user.email "seu-email@gmail.com"
git config user.name "Seu Nome"
```

---

## 2️⃣ Conectar ao GitHub

**ANTES:** Vá para https://github.com/new e crie repositório `vamos-la-tickets`

**DEPOIS:** Copie e execute:

```bash
cd ~/validaçao\ tickets
git remote add origin https://github.com/SEU_USUARIO/vamos-la-tickets.git
git remote -v
```

**Substitua `SEU_USUARIO` pelo seu username do GitHub!**

---

## 3️⃣ Fazer Push (DISPARA BUILD!)

Copie e execute:

```bash
cd ~/validaçao\ tickets
git add -A
git commit -m "Vamos Lá Tickets - Release v1.0"
git branch -M main
git push -u origin main
```

**✅ PRONTO! Build iniciou automaticamente no GitHub!**

---

## 4️⃣ Verificar Status (abra no navegador)

Copie e abra no navegador:

```
https://github.com/SEU_USUARIO/vamos-la-tickets/actions
```

Você verá:
- 🟡 **Yellow** = Em execução (15-20 min)
- ✅ **Green** = Sucesso!

---

## 5️⃣ Quando Terminar: Instalar APK

Conecte telefone via USB e execute:

```bash
adb install -r ~/Downloads/app-release.apk
```

---

## 🔄 Fazer Mudanças Depois

Sempre que mudar código:

```bash
cd ~/validaçao\ tickets
git add -A
git commit -m "Descrição da mudança"
git push origin main
```

**Workflow dispara automaticamente!** 🤖

---

## 🆘 Problemas?

### Git não funciona?
```bash
# Inicializar novo repo
cd ~/validaçao\ tickets
rm -rf .git
git init
git config user.email "seu-email@gmail.com"
git config user.name "Seu Nome"
```

### Remote já existe?
```bash
# Remover
git remote remove origin

# Adicionar novo
git remote add origin https://github.com/SEU_USUARIO/vamos-la-tickets.git
```

### Quer forçar rebuild (sem mudanças)?
```bash
cd ~/validaçao\ tickets
git commit --allow-empty -m "Rebuild APK"
git push origin main
```

---

## 💾 Resumo Rápido

| Ação | Comando |
|------|---------|
| **Setup Git** | `git init` |
| **Conectar GitHub** | `git remote add origin [URL]` |
| **Commit** | `git add -A && git commit -m "msg"` |
| **Push (build)** | `git push origin main` |
| **Ver status** | `git remote -v` |
| **Instalar APK** | `adb install -r app-release.apk` |

---

## 📞 URLs Importantes

- **GitHub Repo:** https://github.com/SEU_USUARIO/vamos-la-tickets
- **Actions Status:** https://github.com/SEU_USUARIO/vamos-la-tickets/actions
- **Releases:** https://github.com/SEU_USUARIO/vamos-la-tickets/releases

---

## ⏱️ Cronograma

| Etapa | Tempo |
|-------|-------|
| Setup Git | 1 min |
| Push para GitHub | 1 min |
| Build no GitHub | 15-20 min |
| Download APK | 1 min |
| Instalar no telefone | 2 min |
| **TOTAL** | **~25 min** |

---

**Você está pronto! Comece pelo STEP 1! 🚀**
