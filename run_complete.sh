#!/bin/bash

# 🚀 SCRIPT PARA RODAR SERVIDOR E COMPILAR APP
# Uso: bash run_complete.sh [start-server|build-app|install-app|test]

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SERVER="$PROJECT_DIR/local_server"
MOBILE_APP="$PROJECT_DIR/mobile_app"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   🎫 VAMOS LÁ TICKETS - SCRIPT HELPER    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 não está instalado!"
        return 1
    fi
    print_success "$1 encontrado"
    return 0
}

# Função: Verificar pré-requisitos
check_requirements() {
    print_header
    echo "Verificando pré-requisitos..."
    echo ""
    
    local missing=0
    
    if ! check_command "node"; then
        print_error "Node.js não encontrado. Instale em: https://nodejs.org"
        missing=1
    fi
    
    if ! check_command "npm"; then
        print_error "npm não encontrado. Instale em: https://nodejs.org"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Instale os programas acima e tente novamente!"
        exit 1
    fi
    
    print_success "Todos os pré-requisitos OK!"
}

# Função: Rodar servidor
start_server() {
    print_header
    echo "Iniciando servidor..."
    echo ""
    
    check_requirements
    
    if [ ! -d "$LOCAL_SERVER/node_modules" ]; then
        print_info "Primeira vez? Instalando dependências..."
        cd "$LOCAL_SERVER"
        npm install
        print_success "Dependências instaladas!"
    fi
    
    print_info "Iniciando servidor em http://0.0.0.0:8000"
    print_info "Pressione Ctrl+C para parar"
    echo ""
    
    cd "$LOCAL_SERVER"
    npm start
}

# Função: Testar servidor
test_server() {
    print_header
    echo "Testando servidor..."
    echo ""
    
    if [ ! -d "$LOCAL_SERVER/node_modules" ]; then
        print_error "Servidor não foi instalado ainda!"
        print_info "Execute: bash run_complete.sh start-server"
        exit 1
    fi
    
    cd "$LOCAL_SERVER"
    print_info "Rodando testes..."
    echo ""
    
    node test-api.js
}

# Função: Compilar APK
build_app() {
    print_header
    echo "Compilando app Android..."
    echo ""
    
    if ! check_command "flutter"; then
        print_error "Flutter não está instalado!"
        print_info "Instale em: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    print_success "Flutter encontrado"
    
    cd "$MOBILE_APP"
    
    print_info "Atualizando dependências Flutter..."
    flutter pub get
    
    print_info "Compilando APK release..."
    print_info "Isso pode levar 5-10 minutos..."
    echo ""
    
    flutter build apk --release
    
    print_success "APK compilado com sucesso!"
    echo ""
    print_info "Localização: $MOBILE_APP/build/app/outputs/flutter-app-release.apk"
    ls -lh "$MOBILE_APP/build/app/outputs/flutter-app-release.apk"
}

# Função: Instalar APK
install_app() {
    print_header
    echo "Instalando app no dispositivo..."
    echo ""
    
    if ! check_command "flutter"; then
        print_error "Flutter não está instalado!"
        exit 1
    fi
    
    if [ ! -f "$MOBILE_APP/build/app/outputs/flutter-app-release.apk" ]; then
        print_error "APK não encontrado!"
        print_info "Execute primeiro: bash run_complete.sh build-app"
        exit 1
    fi
    
    print_info "Conecte seu dispositivo via USB e ative a depuração USB"
    print_info "Pressione Enter para continuar..."
    read
    
    cd "$MOBILE_APP"
    print_info "Instalando..."
    flutter install
    
    print_success "App instalado!"
}

# Função: Menu ajuda
show_help() {
    print_header
    cat << EOF
Uso: bash run_complete.sh [COMANDO]

COMANDOS:
  start-server    🚀 Rodar servidor local
  test-server     🧪 Testar servidor (requer que esteja rodando em outro terminal)
  build-app       🔨 Compilar APK Android
  install-app     📱 Instalar APK no dispositivo
  requirements    ✅ Verificar pré-requisitos
  help            ❓ Mostrar esta mensagem

EXEMPLOS:
  # Rodar servidor
  bash run_complete.sh start-server

  # Em outro terminal, testar
  bash run_complete.sh test-server

  # Compilar app
  bash run_complete.sh build-app

  # Instalar no telefone
  bash run_complete.sh install-app

DICAS:
  1. Abra 2 terminais: um para o servidor, outro para os comandos
  2. Mantenha o servidor rodando enquanto desenvolve
  3. Depois de compilar o APK, você pode copiar e instalar em múltiplos telefones

IMPORTANTE:
  - Verifique o IP do servidor em: mobile_app/lib/main.dart
  - Mude para o IP da sua rede antes de compilar!

EOF
}

# Main
case "${1:-help}" in
    start-server)
        start_server
        ;;
    test-server)
        test_server
        ;;
    build-app)
        build_app
        ;;
    install-app)
        install_app
        ;;
    requirements)
        check_requirements
        ;;
    help)
        show_help
        ;;
    *)
        print_error "Comando desconhecido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
