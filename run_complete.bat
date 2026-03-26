@echo off
REM 🚀 SCRIPT PARA RODAR SERVIDOR E COMPILAR APP (Windows)
REM Uso: run_complete.bat [start-server|build-app|install-app|test]

setlocal enabledelayedexpansion

REM Cores e estilos (emulação básica)
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "RESET=[0m"

REM Caminhos
for %%i in ("%~dp0.") do set "PROJECT_DIR=%%~fi"
set "LOCAL_SERVER=%PROJECT_DIR%\local_server"
set "MOBILE_APP=%PROJECT_DIR%\mobile_app"

REM Funções
:print_header
cls
echo.
echo ╔════════════════════════════════════════════╗
echo ║   🎫 VAMOS LÁ TICKETS - SCRIPT HELPER    ║
echo ╚════════════════════════════════════════════╝
echo.
exit /b

:print_success
echo [✓] %~1
exit /b

:print_error
echo [✗] %~1
exit /b

:print_info
echo [i] %~1
exit /b

:check_command
where %~1 >nul 2>nul
if errorlevel 1 (
    echo [✗] %~1 não encontrado!
    exit /b 1
) else (
    echo [✓] %~1 encontrado
    exit /b 0
)

REM Main menu
call :print_header

if "%~1"=="" goto show_help
if "%~1"=="start-server" goto start_server
if "%~1"=="test-server" goto test_server
if "%~1"=="build-app" goto build_app
if "%~1"=="install-app" goto install_app
if "%~1"=="requirements" goto check_requirements
if "%~1"=="help" goto show_help

echo [✗] Comando desconhecido: %~1
echo.
goto show_help

:check_requirements
echo Verificando pré-requisitos...
echo.

call :check_command node
if errorlevel 1 (
    echo [✗] Node.js não encontrado. Instale em: https://nodejs.org
    exit /b 1
)

call :check_command npm
if errorlevel 1 (
    echo [✗] npm não encontrado. Instale em: https://nodejs.org
    exit /b 1
)

echo.
echo [✓] Todos os pré-requisitos OK!
exit /b 0

:start_server
call :print_header
echo Iniciando servidor...
echo.

call :check_requirements
if errorlevel 1 exit /b 1

if not exist "%LOCAL_SERVER%\node_modules" (
    echo [i] Primeira vez? Instalando dependências...
    cd /d "%LOCAL_SERVER%"
    call npm install
    echo [✓] Dependências instaladas!
)

echo.
echo [i] Iniciando servidor em http://0.0.0.0:8000
echo [i] Pressione Ctrl+C para parar
echo.

cd /d "%LOCAL_SERVER%"
call npm start
exit /b

:test_server
call :print_header
echo Testando servidor...
echo.

if not exist "%LOCAL_SERVER%\node_modules" (
    echo [✗] Servidor não foi instalado ainda!
    echo [i] Execute: run_complete.bat start-server
    exit /b 1
)

cd /d "%LOCAL_SERVER%"
echo [i] Rodando testes...
echo.

node test-api.js
exit /b

:build_app
call :print_header
echo Compilando app Android...
echo.

call :check_command flutter
if errorlevel 1 (
    echo [✗] Flutter não está instalado!
    echo [i] Instale em: https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo [✓] Flutter encontrado
echo.

cd /d "%MOBILE_APP%"

echo [i] Atualizando dependências Flutter...
call flutter pub get

echo.
echo [i] Compilando APK release...
echo [i] Isso pode levar 5-10 minutos...
echo.

call flutter build apk --release

echo.
echo [✓] APK compilado com sucesso!
echo.
echo [i] Localização: %MOBILE_APP%\build\app\outputs\flutter-app-release.apk
dir "%MOBILE_APP%\build\app\outputs\flutter-app-release.apk"
exit /b

:install_app
call :print_header
echo Instalando app no dispositivo...
echo.

call :check_command flutter
if errorlevel 1 (
    echo [✗] Flutter não está instalado!
    exit /b 1
)

if not exist "%MOBILE_APP%\build\app\outputs\flutter-app-release.apk" (
    echo [✗] APK não encontrado!
    echo [i] Execute primeiro: run_complete.bat build-app
    exit /b 1
)

echo [i] Conecte seu dispositivo via USB e ative a depuração USB
echo [i] Pressione uma tecla para continuar...
pause

cd /d "%MOBILE_APP%"
echo [i] Instalando...
call flutter install

echo.
echo [✓] App instalado!
exit /b

:show_help
echo Uso: run_complete.bat [COMANDO]
echo.
echo COMANDOS:
echo   start-server    🚀 Rodar servidor local
echo   test-server     🧪 Testar servidor
echo   build-app       🔨 Compilar APK Android
echo   install-app     📱 Instalar APK no dispositivo
echo   requirements    ✅ Verificar pré-requisitos
echo   help            ❓ Mostrar esta mensagem
echo.
echo EXEMPLOS:
echo   run_complete.bat start-server
echo   run_complete.bat build-app
echo   run_complete.bat install-app
echo.
echo DICAS:
echo   1. Abra 2 terminais: um para o servidor, outro para compilar
echo   2. Mantenha o servidor rodando enquanto testa
echo   3. Depois de compilar, você pode copiar o APK para vários telefones
echo.
echo IMPORTANTE:
echo   - Verifique o IP do servidor em: mobile_app\lib\main.dart
echo   - Mude para o IP da sua rede antes de compilar!
echo.
exit /b
