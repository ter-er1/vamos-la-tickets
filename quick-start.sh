#!/bin/bash

# 🚀 SCRIPT RÁPIDO DE INSTALAÇÃO E TESTE
# VAMOS LÁ TICKETS - Sistema de Validação com QR Code
# 
# Uso: bash quick-start.sh

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   🎫 VAMOS LÁ TICKETS - QUICK START                           ║"
echo "║   Sistema de Validação com QR Code                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir sucesso
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Função para imprimir erro
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Função para imprimir warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# ========================================
# PASSO 1: Verificar pré-requisitos
# ========================================
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PASSO 1: Verificando pré-requisitos..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Verificar Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    success "Node.js instalado: $NODE_VERSION"
else
    error "Node.js não encontrado! Instale em: https://nodejs.org"
    exit 1
fi

# Verificar npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    success "npm instalado: $NPM_VERSION"
else
    error "npm não encontrado!"
    exit 1
fi

# Verificar Python (opcional)
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    success "Python 3 instalado: $PYTHON_VERSION"
else
    warning "Python 3 não encontrado (opcional para gerar QRs)"
fi

echo ""

# ========================================
# PASSO 2: Instalar servidor
# ========================================
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PASSO 2: Instalando servidor Node.js..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd "local_server"

if [ -d "node_modules" ]; then
    success "node_modules já existe, pulando npm install"
else
    echo "Instalando dependências..."
    npm install
    success "Dependências instaladas"
fi

cd ..

echo ""

# ========================================
# PASSO 3: Criar diretório do banco
# ========================================
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PASSO 3: Criando estrutura de banco de dados..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

mkdir -p database
success "Diretório database criado"

echo ""

# ========================================
# PASSO 4: Criar .env se não existir
# ========================================
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PASSO 4: Configurando variáveis de ambiente..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [ ! -f "local_server/.env" ]; then
    cat > local_server/.env << EOF
PORT=8000
SECRET_KEY=vamos-la-tickets-secret-key-production
DB_PATH=../database/tickets.db
NODE_ENV=development
EOF
    success "Arquivo .env criado"
else
    success "Arquivo .env já existe"
fi

echo ""
warning "⚠️  IMPORTANTE: Atualizar IP do servidor em mobile_app/lib/main.dart"
echo "   Procure por: const String SERVER_URL = 'http://192.168.1.100:8000'"
echo "   Trocar 192.168.1.100 pelo seu IP local"

echo ""

# ========================================
# PASSO 5: Oferecer início do servidor
# ========================================
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "PASSO 5: Iniciar servidor?"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "Deseja iniciar o servidor agora? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    echo "🚀 Iniciando servidor..."
    echo ""
    cd local_server
    npm start
else
    echo ""
    echo "Para iniciar o servidor manualmente, execute:"
    echo "  cd local_server"
    echo "  npm start"
    echo ""
fi
