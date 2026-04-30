# AutoVagas - Guia Completo para Agentes

## Visao Geral

AutoVagas e um sistema de automatizacao de busca e inscricao de vagas usando Elixir/Phoenix e BEAM (Erlang VM). O sistema utiliza dois casos principais de uso do BEAM:

### Caso 1: Busca de Vagas
1. Orquestracao de chamadas para APIs (RapidAPI, Rockapis, JSearch, Guest API)
2. Processamento de resultados e armazenamento no Mnesia
3. Aplicacao Phoenix consome dados do Mnesia para exibir na pagina Vagas
4. Apos completar a busca, o processo BEAM encerra

### Caso 2: Inscricao Automatica
1. Crawler acessa pagina do contratante
2. Analise com IA (Ollama/OpenAI/Gemini) usando perfil do usuario
3. Consumo de `user_info.json` para preenchimento de formularios
4. Realizacao de inscricao automatica na plataforma

## Comandos Essenciais

- `mix setup` - Instala deps + configura Mnesia (Linux: `setup.sh`, Windows: `setup.bat`)
- `mix phx.server` - Servidor na porta 4000
- `mix clean && mix deps.get && mix compile` - Rebuild completo
- `mix run test_linkedin_api.exs` - Teste manual API LinkedIn
- `mix run test_ai.exs` - Teste de integracao com IA
- Use `nohup mix phx.server &` para resistir a SIGTERM

## Arquitetura (Nao-Obvia)

### Backend (Elixir/Phoenix)
- **Banco**: Mnesia (nativo Erlang/OTP, nao Ecto/PostgreSQL)
  - Configurado como `:extra_applications` no mix.exs
  - Tabelas: `:searches`, `:jobs`, `:notifications`, `:user_sessions`, `:filters`
  - Storage: `:disc_copies` se node configurado, senao `:ram_copies`
- **Frontend**: Phoenix LiveView + Tailwind + daisyUI (sem React/Vue)
- **HTTP**: Req (nao HTTPoison/Tesla)
- **Parsing**: Floki
- **Crawling**: DynamicSupervisor + GenServer workers (paralelismo isolado)
- **Automacao**: Wallaby + Selenium + Firefox Developer Edition (**nao** Firefox normal ou Chrome)
- **Criptografia**: AES-256-GCM para credenciais em `priv/filters/auth_config.json`
- **I18n**: Modulo `AutoVagasWeb.I18n` para internacionalizacao (PT/EN)

### Estrutura de Arquivos

```
.
├── auto_vagas
│   ├── application.ex
│   ├── auth
│   │   ├── crypto.ex
│   │   ├── gupy.ex
│   │   ├── indeed.ex
│   │   ├── linkedin.ex
│   │   ├── RAPIDAPI_SETUP.md
│   │   └── README.md
│   ├── automation
│   │   ├── auto_complete.ex
│   │   ├── automation.ex
│   │   └── README.md
│   ├── crawler
│   │   ├── adapter.ex
│   │   ├── auth.ex
│   │   ├── auth_session.ex
│   │   ├── engine.ex
│   │   ├── filter.ex
│   │   ├── geolocation.ex
│   │   ├── jobs_cache.ex
│   │   ├── jobs_store.ex
│   │   ├── README.md
│   │   ├── worker.ex
│   │   └── worker_supervisor.ex
│   ├── LLM
│   │   ├── ai.ex
│   │   ├── explanation.ex
│   │   ├── gemini.ex
│   │   ├── ollama.ex
│   │   ├── openai.ex
│   │   └── README.md
│   ├── mnesia
│   │   ├── README.md
│   │   ├── schema.ex
│   │   └── search_manager.ex
│   ├── notifications
│   │   ├── channels.ex
│   │   ├── discord.ex
│   │   ├── mailer.ex
│   │   ├── pending_job_handler.ex
│   │   ├── telegram.ex
│   │   ├── user_info_updater.ex
│   │   └── whatsapp.ex
│   ├── ntp.ex
│   ├── profiles
│   │   ├── experience.ex
│   │   ├── filters.ex
│   │   ├── pdf.ex
│   │   ├── user_info.ex
│   │   └── user_profile.ex
│   ├── README.md
│   └── sites
│       ├── gupy.ex
│       ├── indeed.ex
│       └── linkedin_profile.ex
├── auto_vagas.ex
├── auto_vagas_web
│   ├── components
│   │   ├── core_components.ex
│   │   ├── layouts
│   │   │   └── root.html.heex
│   │   └── layouts.ex
│   ├── controllers
│   │   ├── auth_controller.ex
│   │   ├── error_html.ex
│   │   ├── error_json.ex
│   │   ├── page_controller.ex
│   │   ├── page_html
│   │   │   └── home.html.heex
│   │   └── page_html.ex
│   ├── endpoint.ex
│   ├── gettext.ex
│   ├── i18n.ex
│   ├── live
│   │   ├── help_live.ex
│   │   ├── home_live.ex
│   │   ├── job_search_live.ex
│   │   ├── jobs_live.ex
│   │   ├── settings_live.ex
│   │   ├── settings_live.ex.backup
│   │   ├── settings_live.ex.bak
│   │   ├── skills_live.ex
│   │   └── user_profile_live.ex
│   ├── README.md
│   ├── router.ex
│   └── telemetry.ex
└── auto_vagas_web.ex
```

## Quirks do Framework

### Phoenix LiveView
- **CoreComponents.input**: **Nao** suporta `type="radio"` - use `<input type="radio">` nativo
- **Formularios**: Usam `to_form/1,2` e `<.input>` do core_components.ex
- **Uploads**: `allow_upload` com `phx-drop` e `phx-upload` (nao confundir)
- **LiveView mounts**: Dados geralmente carregados no `mount/3`

### LinkedIn OAuth
- **Producao**: Exige HTTPS; localhost funciona para testes
- **Redirect URI**: `http://localhost:4000/auth/linkedin/callback`
- **Escopos**: `r_liteprofile r_emailaddress`

### Crawlers
- **Estaticos quebrados**: LinkedIn/Indeed carregam via JavaScript - precisam API ou Selenium
- **Guest API**: `https://www.linkedin.com/jobs-guest/jobs/api/seeMoreJobPostings/search`
- **Rockapis**: `https://rockapis-rockapis-default.p.rapidapi.com/api/linkedin-data-api`
- **JSearch**: `https://letscrape-6bRBa3QguO5.p.rapidapi.com/jsearch`

### Mnesia
- **Tabelas**: `:searches`, `:jobs`, `:notifications`, `:user_sessions`, `:filters`
- **Storage condicional**: `:disc_copies` se node configurado, senao `:ram_copies`
- **Transacoes**: `:mnesia.transaction` para operacoes ACID
- **Mnesia.start()** antes de qualquer operacao

### Outros
- **NTP**: Usa UDP porta 123 para sincronizacao de tempo
- **Notificacoes**: Usam Phoenix.PubSub para broadcast interno
- **URI.encode** no linkedin.ex precisa `to_string()` para charlists
- **JobsLive**: Converte chaves string para atomos (`:title`, `:company`) no `mount/3`

## Estado da Implementacao

### Core (Completo)
- [x] **Mnesia Schema**: 5 tabelas criadas e testadas
- [x] **Calculo Experiencia**: Baseado em NTP (`lib/auto_vagas/profiles/experience.ex`)
- [x] **Multiplas Buscas**: Workers GenServer via DynamicSupervisor
- [x] **JobsStore**: Armazenamento no Mnesia
- [x] **UserConfig**: Centralizacao em `user_info.ex`

### APIs LinkedIn (4 Metodos)
- [x] `fetch_via_rapidapi/4` - RapidAPI (primario, testado)
- [x] `fetch_via_rockapis/4` - Rockapis LinkedIn Data API (nao testado)
- [x] `fetch_via_jsearch/4` - JSearch API (letscrape, nao testado)
- [x] `fetch_via_guest_api/4` - Guest API (fallback, testado)
- [x] `fetch_jobs/5` - Orquestrador com fallback automatico

### Autenticacao SSO
- [ ] **LinkedIn OAuth 2.0**: Estrutura criada, pendente
- [ ] **Indeed OAuth 2.0**: Estrutura criada, pendente
- [ ] **Gupy SAML 2.0**: Estrutura criada, pendente

### Interfaces Web (LiveView)
- [x] **HomeLive** (`/`): Stats + quick actions
- [x] **SettingsLive** (`/configuracoes`): Integracoes, notificacoes, **regras de automacao**
- [x] **JobsLive** (`/vagas`): Zabbix-style dashboard, importa regras
- [x] **SkillsLive** (`/habilidades`): **Perfil + Habilidades** (consolidado)
- [x] **HelpLive** (`/ajuda`): Guias OAuth e IA

### Regras de Automacao
- [x] **Criacao**: Via SettingsLive (botao "Nova Regra")
- [x] **Edicao**: Toggle ativar/desativar regras
- [x] **Exclusao**: Remocao de regras
- [x] **Importacao**: JobsLive importa regras do SettingsLive
- [x] **Execucao**: Botao "Executar" dispara busca

### IA (Completo)
- [x] **Ollama Local**: Funcionando (modelo llama3.2)
- [x] **Gemini API**: Implementado (requer GEMINI_API_KEY)
- [x] **OpenAI API**: Implementado (requer OPENAI_API_KEY)
- [x] **Extracao Experiencia**: `AutoVagas.Profiles.Experience`
- [x] **Complemento Perfil**: `AutoVagas.Profiles.UserProfile`
- [x] **Processamento PDF**: `AutoVagas.AI.PDF`
- [x] **Explicacoes**: `AutoVagas.AI.Explanation`

### Criptografia
- [x] **AES-256-GCM**: Implementado em `lib/auto_vagas/crypto.ex`
- [x] **Chave persistente**: Armazenada em `priv/filters/.secret_key`
- [x] **Fluxo**: Encrypt no save, Decrypt no load

### Notificacoes (Estrutura)
- [x] **WhatsApp**: Estrutura criada em `lib/auto_vagas/notifications/whatsapp.ex`
- [x] **Telegram**: Estrutura criada em `lib/auto_vagas/notifications/telegram.ex`
- [x] **Discord**: Estrutura criada em `lib/auto_vagas/notifications/discord.ex`
- [ ] **Ativacao**: Requer configuracao de canais

## Gotchas Importantes

1. **Nunca usar emojis** em codigo, comentarios ou documentacao
2. **CoreComponents.input** nao suporta `type="radio"` - usar HTML nativo
3. **URI.encode** precisa `to_string()` para charlists no linkedin.ex
4. **Mnesia** precisa `:mnesia.start()` antes de operacoes
5. **JobsLive** converte chaves string para atomos no `mount/3`
6. **NTP** usa UDP porta 123
7. **Formularios** usam `to_form/1,2` do Phoenix
8. **Upload PDF** usa `allow_upload` com `phx-drop` e `phx-upload`
9. **Notificacoes** usam Phoenix.PubSub para broadcast
10. **JobsStore** usa `:mnesia.transaction` para ACID

## Restricoes para Agentes

- **NUNCA usar emojis** em codigo, comentarios ou documentacao
- **Sempre usar portugues** em textos visiveis para o usuario
- **Usar portugues** tambem em nomes de arquivos e variaveis quando possivel
- **Seguir convencoes** do projeto (Tailwind + daisyUI para frontend)
- **Testar compilacao** sempre apos edicoes (`mix compile`)
- **Verificar servidor** rodando em http://localhost:4000

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

## Documentacao Disponivel

- `README.md` - Visao geral, casos de uso BEAM
- `AGENTS.md` - Este arquivo (guia completo)
- `TODO.md` - Status, objetivos finais, testes realizados
- `IA_USAGE.md` - Documentacao completa de IA
- `RAPIDAPI_SETUP.md` - Configuracao RapidAPI
- `JSEARCH_SETUP.md` - Configuracao JSearch API
- `ROCKAPIS_SETUP.md` - Configuracao Rockapis

## Fluxos Principais

### Fluxo de Busca de Vagas
1. Usuario cria regra em SettingsLive
2. Usuario importa regra em JobsLive
3. Usuario clica "Executar"
4. BEAM orquestra: RapidAPI -> Rockapis -> JSearch -> Guest API
5. Resultados salvos no Mnesia (tabela `:jobs`)
6. LiveView consome e exibe para usuario
7. Processo BEAM encerra

### Fluxo de Inscricao Automatica
1. Usuario configura perfil em `/habilidades` (consolidado)
2. Sistema extrai dados com IA (Ollama)
3. Crawler acessa pagina do contratante
4. IA analisa requisitos da vaga
5. Sistema preenche formularios com `user_info.json`
6. Inscricao realizada automaticamente

## Licoes Aprendidas

1. **Mnesia e poderoso** mas requer cuidado com tipos de storage
2. **LiveView** simplifica muito o frontend (sem React/Vue)
3. **Req** e melhor que HTTPoison para APIs modernas
4. **AES-256-GCM** e mais seguro que CBC (autenticacao + confidencialidade)
5. **Ollama local** funciona muito bem para analise de curriculo
6. **LinkedIn OAuth** funciona bem com localhost para testes
7. **Wallaby + Firefox Dev** e essencial para automacao web
8. **Mnesia tabelas** devem ser criadas na inicializacao (application.ex)
9. **Criacao de regras** deve ser isolada em SettingsLive, nao em JobsLive
10. **JobsLive** deve apenas importar e executar regras, nao criar
11. **Perfil do usuario** consolidado em SkillsLive (mais intuitivo)
12. **Nunca usar emojis** em nenhuma parte do codigo ou documentacao

## Principais Funcionalidades

### Pagina de Habilidades (`/habilidades`)
- **Criacao de Perfil**: Nome, localizacao, URL LinkedIn
- **Conexao LinkedIn**: Botao "Conectar LinkedIn" sincroniza perfil
- **Importacao PDF**: Envio de curriculo para extrair dados
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
