# AutoVagas

Sistema automatizado de busca e inscricao de vagas usando Elixir/Phoenix e BEAM.

## Casos de Uso do BEAM

### 1. Busca de Vagas
O BEAM gerencia o ciclo de vida das buscas:
- Orquestra chamadas para APIs (RapidAPI, Rockapis, JSearch, Guest API)
- Processa resultados e armazena no Mnesia
- Aplicacao consome dados do Mnesia para exibir na pagina Vagas
- Apos completar a busca, o processo BEAM encerra

### 2. Inscricao Automatica
Automacao de inscricoes em vagas:
- Crawler acessa pagina do contratante
- Analise com IA (Ollama/OpenAI/Gemini) usando perfil do usuario
- Consome `user_info.json` para preencher formularios
- Realiza inscricao automatica na plataforma

## Tecnologias

- **Backend**: Elixir/Phoenix LiveView
- **Banco**: Mnesia (Erlang/OTP nativo)
- **Frontend**: Tailwind CSS + daisyUI
- **Crawling**: GenServer + DynamicSupervisor
- **IA**: Ollama, OpenAI, Gemini
- **Criptografia**: AES-256-GCM

## Configuracao Rapida

```bash
# Instalar dependencias
mix setup

# Configurar RapidAPI (escolher uma das 3 opcoes)
# 1. RapidAPI: https://rapidapi.com/fantastic-jobs-fantastic-jobs-default/api/linkedin-job-search-api
# 2. Rockapis: https://rapidapi.com/rockapis-rockapis-default/api/linkedin-data-api
# 3. JSearch: https://rapidapi.com/letscrape-6bRBa3QguO5/api/jsearch

# Acesse /configuracoes e adicione sua API key

# Iniciar servidor
mix phx.server
```

Acesse: http://localhost:4000

## Estrutura

```
lib/
├── auto_vagas/
│   ├── application.ex      # Inicializacao BEAM
│   ├── crawler/          # Logica de busca (Workers, Engine)
│   ├── sites/            # Adapters (LinkedIn, Indeed, Gupy)
│   ├── ai/               # Integracao IA
│   ├── auth/             # OAuth/SAML
│   └── mnesia/           # Esquema Mnesia
└── auto_vagas_web/
    ├── live/
    │   ├── home_live.ex      # Pagina inicial (stats + acoes)
    │   ├── settings_live.ex  # Configuracoes + Regras de automacao
    │   ├── skills_live.ex    # Habilidades + Criacao de Perfil
    │   ├── jobs_live.ex     # Vagas (importa regras, Zabbix-style)
    │   └── help_live.ex      # Ajuda (guias OAuth/IA)
    └── router.ex           # 5 live paths + 3 callbacks
```

## Principais Funcionalidades

### Pagina de Habilidades (`/habilidades`)
- **Criacao de Perfil**: Nome, localizacao, URL LinkedIn
- **Conexao LinkedIn**: Botao "Conectar LinkedIn" sincroniza perfil
- **Importacao PDF**: Envie curriculo para extrair dados
- **Visualizacao**: Habilidades tecnicas, comportamentais, certificacoes
- **IA**: Atualizacao automatica com Ollama/OpenAI/Gemini

### Configuracoes (`/configuracoes`)
- **Integracoes**: LinkedIn OAuth, configuracao RapidAPI
- **Regras de Automacao**: Criar, editar, ativar/desativar
- **Notificacoes**: WhatsApp, Telegram, Discord (estrutura)

### Vagas (`/vagas`)
- **Importar Regras**: Traz regras criadas em Configuracoes
- **Executar Buscas**: Dispara busca automatica multi-API
- **Dashboard Zabbix-style**: Stats cards + grid layout

## Documentacao

- `AGENTS.md` - Guia completo para agentes
- `TODO.md` - Status e objetivos finais
- `RAPIDAPI_SETUP.md` - Configuracao RapidAPI
- `JSEARCH_SETUP.md` - Configuracao JSearch API
- `ROCKAPIS_SETUP.md` - Configuracao Rockapis
