#!/bin/bash
#
# AutoVagas - Script de Instalação para Linux
# Este script instala todas as dependências necessárias para o funcionamento do AutoVagas
#

set -e

echo "=========================================="
echo "AutoVagas - Instalação para Linux"
echo "=========================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para imprimir mensagens
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# Verifica se está rodando como root (para apt)
if [ "$EUID" -eq 0 ]; then 
    SUDO=""
else
    SUDO="sudo"
fi

# 1. Atualiza o sistema
print_info "Atualizando lista de pacotes..."
$SUDO apt update -qq

# 2. Instala dependências básicas
print_info "Instalando dependências básicas (curl, wget, unzip)..."
$SUDO apt install -y -qq curl wget unzip

# 3. Instala Elixir e Erlang (via apt ou asdf)
print_info "Verificando Elixir/Erlang..."
if ! command -v elixir &> /dev/null; then
    print_warn "Elixir não encontrado. Instalando..."
    $SUDO apt install -y -qq elixir erlang
else
    print_info "Elixir encontrado: $(elixir --version | head -1)"
fi

# 4. Instala Node.js (para assets)
print_info "Verificando Node.js..."
if ! command -v node &> /dev/null; then
    print_warn "Node.js não encontrado. Instalando..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO -E bash -
    $SUDO apt install -y -qq nodejs
else
    print_info "Node.js encontrado: $(node --version)"
fi

# 5. Instala Firefox Developer Edition
print_info "Verificando Firefox Developer Edition..."
if ! command -v firefox-developer-edition &> /dev/null; then
    print_warn "Firefox Developer Edition não encontrado. Instalando via Snap..."
    if command -v snap &> /dev/null; then
        $SUDO snap install firefox --beta
        # Cria link simbólico
        $SUDO ln -sf /snap/bin/firefox /usr/local/bin/firefox-developer-edition 2>/dev/null || true
    else
        print_warn "Snap não disponível. Instalando Firefox normal..."
        $SUDO apt install -y -qq firefox
        $SUDO ln -sf /usr/bin/firefox /usr/local/bin/firefox-developer-edition 2>/dev/null || true
    fi
else
    print_info "Firefox Developer Edition encontrado: $(firefox-developer-edition --version 2>/dev/null | head -1)"
fi

# 6. Instala GeckoDriver (para Firefox + Selenium)
print_info "Verificando GeckoDriver..."
if ! command -v geckodriver &> /dev/null; then
    print_warn "GeckoDriver não encontrado. Baixando..."
    cd /tmp
    wget -q https://github.com/mozilla/geckodriver/releases/download/v0.36.0/geckodriver-v0.36.0-linux64.tar.gz
    tar -xzf geckodriver-v0.36.0-linux64.tar.gz
    chmod +x geckodriver
    $SUDO mv geckodriver /usr/local/bin/
    rm -f geckodriver-v0.36.0-linux64.tar.gz
    print_info "GeckoDriver instalado: $(geckodriver --version)"
else
    print_info "GeckoDriver encontrado: $(geckodriver --version)"
fi

# 7. Instala ChromeDriver (opcional, para Chrome)
print_info "Verificando ChromeDriver..."
if ! command -v chromedriver &> /dev/null; then
    print_warn "ChromeDriver não encontrado. Instalando..."
    $SUDO apt install -y -qq chromium-chromedriver 2>/dev/null || print_warn "Chromium ChromeDriver não disponível via apt"
else
    print_info "ChromeDriver encontrado: $(chromedriver --version 2>/dev/null || echo 'versão desconhecida')"
fi

# 8. Instala inotify-tools (opcional, para live-reload)
print_info "Verificando inotify-tools..."
if ! command -v inotifywait &> /dev/null; then
    print_warn "inotify-tools não encontrado. Instalando..."
    $SUDO apt install -y -qq inotify-tools
else
    print_info "inotify-tools encontrado"
fi

# 9. Configura o projeto Elixir
print_info "Configurando projeto Elixir..."
cd "$(dirname "$0")"

# Instala dependências do Elixir
print_info "Instalando dependências Elixir (mix deps.get)..."
mix deps.get

# Instala dependências Node.js
print_info "Instalando dependências Node.js (npm install)..."
cd assets 2>/dev/null && npm install || print_warn "Diretório assets não encontrado ou npm não configurado"
cd ..

# Compila assets
print_info "Compilando assets..."
mix assets.setup 2>/dev/null || print_warn "assets.setup não configurado"
mix assets.build 2>/dev/null || print_warn "assets.build não configurado"

# Compila o projeto
print_info "Compilando projeto..."
mix compile

# 10. Cria arquivos de configuração se não existirem
print_info "Verificando arquivos de configuração..."
if [ ! -f "priv/user_info.json" ]; then
    print_info "Criando priv/user_info.json padrão..."
    mkdir -p priv
    cat > priv/user_info.json << 'EOF'
{
  "location": "Brazil",
  "languages": ["Portuguese", "English"],
  "searches": [],
  "experience": {},
  "notification_channels": {},
  "filters": {
    "global": {
      "include_words": [],
      "exclude_words": [],
      "min_experience_years": 0,
      "max_applications": 100,
      "remote_only": false
    },
    "by_source": {}
  }
}
EOF'
fi

if [ ! -d "priv/filters" ]; then
    print_info "Criando diretório priv/filters..."
    mkdir -p priv/filters
    echo '{}' > priv/filters/global_filters.json
    echo '{}' > priv/filters/source_filters.json
    echo '{}' > priv/filters/auth_config.json
fi

echo ""
echo "=========================================="
echo "Instalação concluída!"
echo "=========================================="
echo ""
echo "Para iniciar o servidor, execute:"
echo "  mix phx.server"
echo ""
echo "Acesse: http://localhost:4000"
echo ""
