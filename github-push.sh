#!/bin/bash

# Script para facilitar push para GitHub e acompanhar build do GitHub Actions
# Uso: ./github-push.sh "mensagem do commit"

set -e

REPO_URL="https://github.com/SEU_USUARIO/vamos-la-tickets.git"
BRANCH="main"
WORKSPACE_DIR="$HOME/validaçao tickets"

echo "📦 GitHub Push Script - Vamos Lá Tickets"
echo "========================================"

# Verificar se está em um repositório Git
cd "$WORKSPACE_DIR"

if [ ! -d .git ]; then
    echo "❌ Não é um repositório Git!"
    echo "Inicialize com: git init"
    exit 1
fi

# Mensagem de commit
COMMIT_MSG="${1:-Update $(date +%Y-%m-%d\ %H:%M:%S)}"

echo ""
echo "📝 Commit: $COMMIT_MSG"
echo "📍 Branch: $BRANCH"
echo "🔗 Repositório: $REPO_URL"
echo ""

# Mostrar status
echo "📊 Estado do repositório:"
git status --short | head -10

echo ""
read -p "✅ Continuar com push? (s/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Adicionando arquivos..."
    git add -A
    
    echo "💾 Commit..."
    git commit -m "$COMMIT_MSG" || echo "ℹ️  Nada novo para commitar"
    
    echo "📤 Push para $BRANCH..."
    git push origin "$BRANCH" 2>&1
    
    echo ""
    echo "✅ Push concluído!"
    echo ""
    echo "🔗 Acompanhe o build em:"
    echo "   https://github.com/SEU_USUARIO/vamos-la-tickets/actions"
    echo ""
    echo "⏱️  Tempo estimado: 15-20 minutos"
    echo ""
    echo "💡 Dica: Volte aqui em 20 minutos para download do APK"
else
    echo "❌ Cancelado."
    exit 1
fi
