# 🔧 GitHub Actions - Troubleshooting Avançado

## Status do Workflow

### ✅ Success (Verde)
- APK compilado com sucesso
- Disponível em Artifacts/Releases
- Pronto para instalar

### 🟡 In Progress (Amarelo)
- Ainda compilando
- Tempo normal: 15-20 minutos
- **NÃO cancele**, deixe terminar

### ❌ Failure (Vermelho)
- Compilação falhou
- Ver seção abaixo

---

## ❌ Erros Comuns

### 1. `Error: Flutter version not found`
**Causa:** Flutter 3.32.2 não está disponível no Ubuntu

**Solução:**
No workflow (`.github/workflows/build-apk.yml`), mude:
```yaml
flutter-version: '3.24.0'  # Versão mais estável
channel: 'stable'
```

### 2. `Gradle build failed: Out of memory`
**Causa:** JVM roeu memória (raro no GitHub)

**Solução:** Adicione ao workflow:
```yaml
- name: Build APK
  env:
    JAVA_TOOL_OPTIONS: -Xmx2g
  run: |
    cd mobile_app
    flutter build apk --release --target-platform android-arm64
```

### 3. `Error: Plugin not found`
**Causa:** Dependência Dart não resolve

**Solução:** No workflow, antes de build:
```yaml
- name: Fix dependencies
  run: |
    cd mobile_app
    flutter pub get
    flutter pub upgrade
```

### 4. `UnknownHostException: services.gradle.org`
**Causa:** Mesmo erro local, mas GitHub tem melhor internet

**Solução (improvável no GitHub, mas se acontecer):**
Adicione mirror Maven ao workflow:
```yaml
- name: Setup Gradle
  run: |
    mkdir -p ~/.gradle
    cat > ~/.gradle/gradle.properties << EOF
    org.gradle.jvmargs=-Xmx1024m
    maven.repo.local=.m2
    EOF
```

---

## 🔍 Debugging

### Ver logs detalhados:
1. Vá para: https://github.com/SEU_USUARIO/vamos-la-tickets/actions
2. Clique no workflow com erro
3. Clique em "Build APK"
4. Procure por **❌** em vermelho
5. Clique em "Step" para expandir detalhes

### Exemplo de log com erro:
```
❌ Flutter build apk failed
FAILURE: Build failed with an exception.
...
java.net.UnknownHostException: download.gradle.org
...
```

---

## 🆘 Erros Específicos

### `java.lang.UnsatisfiedLinkError`
Falta de dependência nativa Android.
**Solução:** Atualize NDK no `build.gradle.kts`:
```kotlin
ndkVersion = "27.0.12077973"
```

### `Plugin 'kotlin-android' not found`
Falta de plugin Kotlin.
**Solução:** No `build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    kotlin("android")
}
```

### `Error: App bundle not found`
Arquivo APK não foi gerado.
**Causa:** Flutter não encontrou o App para compilar

**Solução:**
```yaml
- name: Debug structure
  run: |
    cd mobile_app
    ls -la
    ls -la lib/
    flutter analyze  # Verifica erros Dart
```

---

## 🔄 Reexecutar Workflow

### Opção 1: Push novo código
```bash
cd ~/validaçao\ tickets
git add -A
git commit -m "Fix: descrição"
git push origin main
```
Workflow inicia automaticamente.

### Opção 2: Trigger manual (sem código novo)
1. GitHub → Actions
2. "Build Flutter APK"
3. "Run workflow" (botão azul)
4. Selecione `main`
5. "Run workflow"

### Opção 3: Forçar rebuild (avançado)
```bash
cd ~/validaçao\ tickets
git commit --allow-empty -m "Rebuild APK"
git push origin main
```

---

## 📊 Monitorar em Tempo Real

```bash
# Verificar último commit
cd ~/validaçao\ tickets
git log --oneline -1

# Clonar repositório para verificar (em outro PC)
git clone https://github.com/SEU_USUARIO/vamos-la-tickets.git
cd vamos-la-tickets
git log --oneline -5
```

---

## 🛠️ Customizações Úteis

### Aumentar retenção de artefatos
No workflow, mude:
```yaml
retention-days: 30  # Padrão
retention-days: 90  # Mais tempo
```

### Build com múltiplas arquiteturas
```yaml
strategy:
  matrix:
    arch: [android-arm, android-arm64, android-x86, android-x86_64]

- name: Build APK
  run: flutter build apk --target-platform ${{ matrix.arch }} --release
```

### Notificação por email
Adicione step no workflow:
```yaml
- name: Send Email Notification
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: seu-email@gmail.com
    password: sua-senha-app
    subject: ❌ APK Build Failed
    body: Veja: https://github.com/SEU_USUARIO/vamos-la-tickets/actions
```

### Slack notification
```yaml
- name: Notify Slack
  if: success()
  uses: slackapi/slack-github-action@v1.24.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "✅ APK compilado com sucesso!",
        "attachments": [{
          "title": "Download",
          "text": "Artifacts: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
        }]
      }
```

---

## 💾 Backup de APK

GitHub guarda artefatos por 30 dias (padrão).

**Backup seguro:**
```bash
# Criar pasta de backup
mkdir -p ~/backup-apk

# Descarregar APK e guardar
# (Faça manualmente via GitHub UI)

# Ou sincronize com drive/cloud
# Exemplo com rsync:
rsync -av ~/Downloads/app-release.apk ~/backup-apk/
```

---

## 📞 Quando Abrir Issue no GitHub

Se o problema persistir, abra Issue no repositório GitHub:
1. GitHub → Issues → New Issue
2. Título: "[BUG] Workflow Build falha"
3. Descrever:
   - O que você tentou
   - Erro exato (copiar logs)
   - Steps para reproduzir

---

## ⚡ Performance

Tempos típicos de build:
- **Gradle setup**: 2-3 min
- **Flutter build**: 10-12 min
- **Artifact upload**: 1-2 min
- **Total**: 15-20 min

Se exceder 30min:
- Cancele o workflow
- Verifique erros
- Tente novamente
