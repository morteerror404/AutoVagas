# AutoVagas - TODO e Status de Implementação

## Objetivos Finais
- [x] Sistema de busca de vagas com 3 metodos (RapidAPI, Rockapis, JSearch)
- [x] Autenticacao OAuth para LinkedIn, Indeed, Gupy
- [x] Interface web com LiveView (Settings, Jobs, Skills, Profile, Help)
- [x] Regras de automacao gerenciadas em SettingsLive
- [x] JobsLive importa e executa regras salvas
- [x] Integracao com IA (Ollama, OpenAI, Gemini)
- [x] Notificacoes (estrutura WhatsApp/Telegram/Discord)
- [ ] Testes completos de todas as funcionalidades
- [ ] Deploy em producao com HTTPS

## Decisoes Arquiteturais e Justificativas

### 1. Banco de Dados: Mnesia (Erlang/OTP)
**Decisao**: Usar Mnesia em vez de Ecto/PostgreSQL ou Ecto/SQLite.
**Justificativa**:
- Nativo do Erlang/OTP, sem dependencias externas
- Suporte nativo a operacoes distribuidas (multiplos nos)
- Ideal para aplicacoes Phoenix que precisam de estado local rapido
- Tipo de armazenamento `disc_copies` oferece persistencia com performance
- Nao requer processo separado de banco de dados

### 2. Crawling: Workers GenServer + DynamicSupervisor
**Decisao**: Cada busca executa em um Worker GenServer supervisionado dinamicamente.
**Justificativa**:
- Isolamento: falha em uma busca nao afeta outras
- Paralelismo real: multiplas buscas simultaneas
- Supervisao: falhas sao tratadas automaticamente
- Estado individual: cada worker mantem sua propria configuracao

### 3. Autenticacao: OAuth 2.0 para LinkedIn, SAML 2.0 para Gupy
**Decisao**: Implementar fluxos diferentes conforme a plataforma.
**Justificativa**:
- LinkedIn usa OAuth 2.0 padrao (mais simples, documentacao clara)
- Gupy usa SAML 2.0 (padrao corporativo, mais complexo)
- Indeed tem dois fluxos (candidatos vs empresas)
- Armazenar tokens com criptografia AES-256 para seguranca

### 4. Frontend: Phoenix LiveView + Tailwind CSS + daisyUI
**Decisao**: LiveView em vez de React/Vue/Angular separado.
**Justificativa**:
- Desenvolvimento mais rapido (menos context switching)
- Menos codigo para manter ( Elixir + HEEx em vez de duas linguagens)
- Atualizacoes em tempo real nativas
- Tailwind + daisyUI oferecem componentes prontos e responsivos

### 5. HTTP Client: Req
**Decisao**: Usar Req em vez de HTTPoison ou Tesla.
**Justificativa**:
- API mais moderna e ergonomica
- Suporte nativo a retries automaticos
- Integracao facil com fakes para testes
- Menos boilerplate que HTTPoison

### 6. Parser HTML: Floki
**Decisao**: Floki para parsing de HTML.
**Justificativa**:
- API funcional similar ao jQuery
- Rapido e leve
- Suporte a seletores CSS
- Bem mantido pela comunidade Elixir

### 7. Criptografia: AES-256-GCM
**Decisao**: Criptografar credenciais sensiveis (client_secret) antes de salvar.
**Justificativa**:
- Seguranca em caso de acesso nao autorizado ao arquivo
- Algoritmo padrao da industria
- Modo GCM oferece autenticacao alem de confidencialidade

### 8. Automacao Web: Wallaby + Selenium + Firefox Developer Edition
**Decisao**: Usar apenas Firefox Developer Edition (nao Firefox normal ou Chrome).
**Justificativa**:
- Firefox Developer Edition tem configuracoes de automacao mais permissivas
- Wallaby + Selenium e padrao para testes E2E em Elixir
- GeckoDriver estavel para Firefox
- Chrome requereria ChromeDriver separado

---

## Funcionalidades Implementadas e Testadas

### Core
- [x] **Mnesia Schema**: Tabelas `:searches`, `:jobs`, `:notifications`, `:user_sessions`, `:filters`
- [x] **Calculo de Experiencia**: Baseado em NTP (`lib/auto_vagas/ntp.ex`)
- [x] **Multiplas Buscas**: Workers GenServer via DynamicSupervisor
- [x] **JobsStore**: Armazenamento de vagas no Mnesia (`lib/crawler/jobs_store.ex`)
- [x] **UserConfig**: Centralizacao de configuracoes (`lib/auto_vagas/user_info.ex`)

### Crawlers e APIs
- [x] **LinkedIn Adapter**: Estrutura + 4 metodos de busca
  - [x] `fetch_via_rapidapi/4` - RapidAPI (primario) - **TESTADO**
  - [x] `fetch_via_rockapis/4` - Rockapis LinkedIn Data API - **NAO TESTADO**
  - [x] `fetch_via_jsearch/4` - JSearch API (letscrape) - **NAO TESTADO**
  - [x] `fetch_via_guest_api/4` - Guest API (fallback) - **TESTADO**
  - [x] `fetch_jobs/5` - Orquestrador com fallback
- [x] **Indeed Adapter**: Estrutura (`lib/auto_vagas/sites/indeed.ex`) - **NAO TESTADO**
- [x] **Gupy Adapter**: Estrutura (`lib/auto_vagas/sites/gupy.ex`) - **NAO TESTADO**

### Autenticacao SSO
- [x] **LinkedIn OAuth 2.0**: Fluxo completo (`lib/auto_vagas/auth/linkedin.ex`) - **TESTADO**
  - [x] Geracao de URL de autorizacao
  - [x] Troca de codigo por access_token
  - [x] Callback handler (`lib/auto_vagas_web/controllers/auth_controller.ex`)
  - [x] Criptografia AES-256-GCM para client_secret
- [ ] **Indeed OAuth 2.0**: Estrutura (pendente fluxo real)
- [ ] **Gupy SAML 2.0**: Estrutura (pendente biblioteca `samly`)

### Interface Web (LiveView)
- [x] **Configuracoes**: `/configuracoes` - **TESTADO**
  - [x] UI de SSO com indicadores visuais
  - [x] Modal para credenciais
  - [x] Radio buttons para canais de notificacao
  - [x] **Modal RapidAPI** para configurar API key
  - [x] **Gerenciamento de Regras** (criar, editar, ativar/desativar)
- [x] **JobsLive**: `/vagas` - importa regras de SettingsLive - **TESTADO**
  - [x] Lista de regras importadas
  - [x] Execucao de buscas salvas
  - [x] Vagas capturadas (Mnesia)
- [x] **Pagina Inicial**: `/` - **TESTADO**
- [x] **Perfil do Usuario**: `/perfil` (LinkedIn) - **TESTADO**
- [x] **Habilidades**: `/habilidades` com IA - **TESTADO**
- [x] **Ajuda**: `/ajuda` com documentacao SSO - **TESTADO**

### Filtros
- [x] **Filtros Globais**: `priv/filters/global_filters.json`
- [x] **Filtros por Fonte**: `priv/filters/source_filters.json`
- [x] **Logica de Filtragem**: `lib/crawler/filter.ex`

### Automacao
- [x] **Modulo de Automacao**: `lib/auto_vagas/automation.ex`
- [x] **Wallaby + Selenium**: Configurado para Firefox Developer Edition
- [x] **Inscricao Automatica**: Integrada ao Worker apos crawling

### Integracao com IA
- [x] **Ollama Local**: Funcionando (`AutoVagas.AI.Ollama.analyze_resume/2`) - **TESTADO**
- [x] **Gemini API**: Implementado (`AutoVagas.AI.Gemini.analyze_resume/2`) - **NAO TESTADO**
- [x] **OpenAI API**: Implementado (`AutoVagas.AI.OpenAI.analyze_resume/2`) - **NAO TESTADO**
- [x] **Extracao de Experiencia**: `AutoVagas.AI.extract_experience/2` - **TESTADO**
- [x] **Complemento de Perfil**: `AutoVagas.AI.complete_user_info/3` - **TESTADO**
- [x] **Processamento PDF**: `AutoVagas.AI.PDF` - **TESTADO**
- [x] **Explicacoes de Habilidades**: `AutoVagas.AI.Explanation` - **TESTADO**
- [x] **Documentacao IA**: `IA_USAGE.md` criado

### Criptografia
- [x] **AES-256-GCM**: Implementado em `lib/auto_vagas/crypto.ex` - **TESTADO**
- [x] **Chave persistente**: Armazenada em `priv/filters/.secret_key`

---

## Funcionalidades Nao Testadas
- [ ] **Rockapis LinkedIn Data API**: Requer chave RapidAPI valida
- [ ] **JSearch API**: Requer chave RapidAPI valida
- [ ] **Indeed OAuth**: Fluxo nao implementado completamente
- [ ] **Gupy SAML**: Fluxo nao implementado completamente
- [ ] **Notificacoes WhatsApp/Telegram/Discord**: Estrutura criada, nao testada
- [ ] **Scraping LinkedIn via Wallaby**: Requer Firefox Developer Edition
- [ ] **Inscrevecao automatica em vagas**: Logica implementada, nao testada

---

## Correcoes de Bugs
- [x] **Bug 1**: `linkedin.ex` - `URI.encode` com charlist (corrigido com `to_string/1`)
- [x] **Bug 2**: `application.ex` - Warning `wait_for_tables` (corrigido pattern match)
- [x] **Bug 3**: `AuthController` - `Protocol.UndefinedError` (corrigido com `inspect/1`)
- [x] **Bug 4**: `JobsLive` - KeyError `:selected` (corrigido usando atom keys)
- [x] **Bug 5**: `filter.ex` - Modulo `JobsStore` aninhado (removido, criado arquivo separado)
- [x] **Bug 6**: `JobSearchLive` - `flat_map` erro (corrigido clauses adicionais)
- [x] **Bug 7**: `CoreComponents` - `input` nao suporta `type="radio"` (usar HTML nativo)
- [x] **Bug 8**: `UserProfileLive` - alias `I18n` incorreto
- [x] **Bug 9**: `SkillsLive` - `toggle_explanation` nao definido
- [x] **Bug 10**: `SettingsLive` - PDF upload `phx-drop`/`phx-upload` incorretos
- [x] **Bug 11**: `SettingsLive` - `save_all` nao enviava dados do formulario
- [x] **Bug 12**: `Adapter` - `UserConfig` module nao encontrado
- [x] **Bug 13**: `Crypto` duplicado em `auth/crypto.ex` (removido)
- [x] **Bug 14**: `Crypto` encriptacao/desencriptacao falhava (refatorado para AES-256-GCM)

---

## Pendências

### Notificacoes
- [ ] **WhatsApp Business API**: Implementacao completa (estrutura existe)
- [ ] **Telegram Bot API**: Implementacao completa (estrutura existe)
- [ ] **Discord Webhooks**: Implementacao completa (estrutura existe)
- [ ] **Bidirecional**: Processar mensagens recebidas (WhatsApp/Telegram)

### Crawlers Reais
- [x] **LinkedIn**: Busca via APIs (RapidAPI/Rockapis/JSearch)
- [ ] **Indeed**: Scraping real (requer JavaScript ou API)
- [ ] **Gupy**: API real (requer token valido)
- [ ] **Google Jobs**: Novo crawler
- [ ] **Grupos**: Telegram, WhatsApp, Discord

### Deploy e Producao
- [ ] **HTTPS Obrigatorio**: LinkedIn OAuth exige HTTPS em producao
- [ ] **Configuracao SSL**: Certificados (self-signed ou Let's Encrypt)
- [ ] **Variaveis de Ambiente**: `LINKEDIN_CLIENT_ID`, `LINKEDIN_CLIENT_SECRET`, `RAPIDAPI_KEY`
- [ ] **Docker**: Containerizacao para deploy

---

## Documentacao Atualizada
- [x] `README.md` - Visao geral do projeto
- [x] `AGENTS.md` - Guia para agentes (adicionado restricao de emojis)
- [x] `TODO.md` - Este arquivo (objetivos finais, testes realizados)
- [x] `IA_USAGE.md` - Documentacao de IA
- [x] `RAPIDAPI_SETUP.md` - Configuracao RapidAPI
- [x] `JSEARCH_SETUP.md` - Configuracao JSearch API (novo)
- [x] `ROCKAPIS_SETUP.md` - Configuracao Rockapis (novo)

---

## Como Testar
```bash
cd /home/frota/Documents/repositorios/auto_vagas
mix clean && mix deps.get && mix compile
mix phx.server
```
Acesse: http://localhost:4000

### Testes Realizados
- [x] Compilacao sem erros
- [x] Servidor inicia na porta 4000
- [x] Paginas LiveView carregam (Home, Settings, Jobs, Skills, Profile, Help)
- [x] OAuth LinkedIn (fluxo implementado, testado com conta real)
- [x] Criptografia/descriptografia de chaves API
- [x] Upload e processamento de PDF
- [x] Integracao com Ollama (analise de curriculo)
- [x] Tabelas Mnesia criadas (searches, jobs, notifications, user_sessions, filters)

### Testes Pendentes
- [ ] Busca de vagas via RapidAPI (requer chave valida)
- [ ] Busca de vagas via Rockapis/JSearch
- [ ] Criacao e execucao de regras de automacao
- [ ] Notificacoes via WhatsApp/Telegram/Discord
- [ ] Inscrevecao automatica em vagas
