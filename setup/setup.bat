@echo off
REM AutoVagas - Script de Instalação para Windows
REM Este script instala todas as dependências necessárias para o funcionamento do AutoVagas
REM Requer: PowerShell, Chocolatey (opcional), ou instalação manual

setlocal enabledelayedexpansion

echo ==========================================
echo AutoVagas - Instalação para Windows
echo ==========================================
echo.

REM Verifica se está rodando como Administrador
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [AVISO] Este script requer privilégios de Administrador.
    echo Clique com botão direito e selecione "Executar como Administrador"
    pause
    exit /b 1
)

REM 1. Verifica/Instala Chocolatey (gerenciador de pacotes para Windows)
echo [INFO] Verificando Chocolatey...
where choco >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [INFO] Chocolatey não encontrado. Instalando...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
) else (
    echo [INFO] Chocolatey encontrado.
)

REM 2. Instala Elixir e Erlang
echo [INFO] Verificando Elixir...
where elixir >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [INFO] Elixir não encontrado. Instalando via Chocolatey...
    choco install elixir -y
) else (
    echo [INFO] Elixir encontrado: 
    elixir --version
)

REM 3. Instala Node.js
echo [INFO] Verificando Node.js...
where node >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [INFO] Node.js não encontrado. Instalando...
    choco install nodejs-lts -y
) else (
    echo [INFO] Node.js encontrado: 
    node --version
)

REM 4. Instala Firefox Developer Edition (apenas esta versão é suportada)
echo [INFO] Verificando Firefox Developer Edition...
set "FIREFOX_PATH="
for %%i in (
    "C:\Program Files\Firefox Developer Edition\firefox.exe"
    "C:\Program Files (x86)\Firefox Developer Edition\firefox.exe"
    "%LOCALAPPDATA%\Mozilla Firefox Developer Edition\firefox.exe"
) do (
    if exist %%~i (
        set "FIREFOX_PATH=%~i"
        goto :found_firefox
    )
)

:found_firefox
if defined FIREFOX_PATH (
    echo [INFO] Firefox Developer Edition encontrado: %FIREFOX_PATH%
) else (
    echo [INFO] Firefox Developer Edition não encontrado. Instalando via Chocolatey...
    choco install firefox-dev -y
    REM Define caminho padrão após instalação
    set "FIREFOX_PATH=C:\Program Files\Firefox Developer Edition\firefox.exe"
)

REM 5. Instala GeckoDriver
echo [INFO] Verificando GeckoDriver...
where geckodriver >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [INFO] GeckoDriver não encontrado. Baixando...
    powershell -Command "& { Invoke-WebRequest -Uri 'https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-win64.zip' -OutFile 'geckodriver.zip' }"
    powershell -Command "& { Expand-Archive -Path 'geckodriver.zip' -DestinationPath 'C:\Windows' -Force }"
    del geckodriver.zip
    echo [INFO] GeckoDriver instalado.
) else (
    echo [INFO] GeckoDriver encontrado.
)

REM 6. Instala ChromeDriver (opcional)
echo [INFO] Verificando ChromeDriver...
where chromedriver >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [INFO] ChromeDriver não encontrado. Instalando...
    choco install chromedriver -y
) else (
    echo [INFO] ChromeDriver encontrado.
)

REM 7. Configura o projeto Elixir
echo [INFO] Configurando projeto Elixir...
cd /d "%~dp0"

REM Instala dependências do Elixir
echo [INFO] Instalando dependências Elixir (mix deps.get)...
call mix deps.get

REM Instala dependências Node.js
if exist "assets" (
    echo [INFO] Instalando dependências Node.js (npm install)...
    cd assets
    call npm install
    cd ..
) else (
    echo [AVISO] Diretório assets não encontrado.
)

REM Compila assets
echo [INFO] Compilando assets...
call mix assets.setup 2>nul || echo [AVISO] assets.setup não configurado
call mix assets.build 2>nul || echo [AVISO] assets.build não configurado

REM Compila o projeto
echo [INFO] Compilando projeto...
call mix compile

REM 8. Cria arquivos de configuração se não existirem
echo [INFO] Verificando arquivos de configuração...
if not exist "priv" (
    mkdir priv
)

if not exist "priv\user_info.json" (
    echo [INFO] Criando priv\user_info.json padrão...
    echo { > priv\user_info.json
    echo   "location": "Brazil", >> priv\user_info.json
    echo   "languages": ["Portuguese", "English"], >> priv\user_info.json
    echo   "searches": [], >> priv\user_info.json
    echo   "experience": {}, >> priv\user_info.json
    echo   "notification_channels": {}, >> priv\user_info.json
    echo   "filters": { >> priv\user_info.json
    echo     "global": { >> priv\user_info.json
    echo       "include_words": [], >> priv\user_info.json
    echo       "exclude_words": [], >> priv\user_info.json
    echo       "min_experience_years": 0, >> priv\user_info.json
    echo       "max_applications": 100, >> priv\user_info.json
    echo       "remote_only": false >> priv\user_info.json
    echo     }, >> priv\user_info.json
    echo     "by_source": {} >> priv\user_info.json
    echo   } >> priv\user_info.json
    echo } >> priv\user_info.json
)

if not exist "priv\filters" (
    mkdir priv\filters
    echo {} > priv\filters\global_filters.json
    echo {} > priv\filters\source_filters.json
    echo {} > priv\filters\auth_config.json
)

echo.
echo ==========================================
echo Instalação concluída!
echo ==========================================
echo.
echo Iniciando servidor Phoenix na porta 4000...
start "" mix phx.server
timeout /t 3 /nobreak >nul

echo Abrindo página de configuração SSO no Firefox Developer Edition...
start "" "%FIREFOX_PATH%" http://localhost:4000/configuracoes

echo.
echo Servidor rodando em: http://localhost:4000
echo Página de configuração SSO aberta em: http://localhost:4000/configuracoes
echo Para parar o servidor: Ctrl+C
echo.

pause
