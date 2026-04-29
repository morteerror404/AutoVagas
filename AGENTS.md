# AutoVagas - Documentação do Projeto

## Visão Geral

O AutoVagas é uma aplicação web construída com Phoenix Framework (Elixir) para busca automatizada de vagas de emprego. O sistema permite crawlear múltiplas plataformas simultaneamente, com suporte a filtros avançados e notificações via múltiplos canais.

## Decisões Arquiteturais e Justificativas

### 1. Banco de Dados: Mnesia (Erlang/OTP)
**Decisão**: Usar Mnesia em vez de Ecto/PostgreSQL ou Ecto/SQLite.
**Justificativa**:
- Nativo do Erlang/OTP, sem dependências externas
- Suporte nativo a operações distribuídas (múltiplos nós)
- Ideal para aplicações Phoenix que precisam de estado local rápido
- Tipo de armazenamento `disc_copies` oferece persistência com performance
- Não requer processo separado de banco de dados

### 2. Crawling: Workers GenServer + DynamicSupervisor
**Decisão**: Cada busca executa em um Worker GenServer supervisionado dinamicamente.
**Justificativa**:
- Isolamento: falha em uma busca não afeta outras
- Paralelismo real: múltiplas buscas simultâneas
- Supervisão: falhas são tratadas automaticamente
- Estado individual: cada worker mantém sua própria configuração

### 3. Autenticação: OAuth 2.0 para LinkedIn, SAML 2.0 para Gupy
**Decisão**: Implementar fluxos diferentes conforme a plataforma.
**Justificativa**:
- LinkedIn usa OAuth 2.0 padrão (mais simples, documentação clara)
- Gupy usa SAML 2.0 (padrão corporativo, mais complexo)
- Indeed tem dois fluxos (candidatos vs empresas)
- Armazenar tokens com criptografia AES-256 para segurança

### 4. Frontend: Phoenix LiveView + Tailwind CSS + daisyUI
**Decisão**: LiveView em vez de React/Vue/Angular separado.
**Justificativa**:
- Desenvolvimento mais rápido (menos context switching)
- Menos código para manter ( Elixir + HEEx em vez de duas linguagens)
- Atualizações em tempo real nativas
- Tailwind + daisyUI oferecem componentes prontos e responsivos

### 5. HTTP Client: Req
**Decisão**: Usar Req em vez de HTTPoison ou Tesla.
**Justificativa**:
- API mais moderna e ergonômica
- Suporte nativo a retries automáticos
- Integração fácil com fakes para testes
- Menos boilerplate que HTTPoison

### 6. Parser HTML: Floki
**Decisão**: Floki para parsing de HTML.
**Justificativa**:
- API funcional similar ao jQuery
- Rápido e leve
- Suporte a seletores CSS
- Bem mantido pela comunidade Elixir

### 7. Criptografia: AES-256-GCM
**Decisão**: Criptografar credenciais sensíveis (client_secret) antes de salvar.
**Justificativa**:
- Segurança em caso de acesso não autorizado ao arquivo
- Algoritmo padrão da indústria
- Modo GCM oferece autenticação além de confidencialidade

### 8. Automação Web: Wallaby + Selenium + Firefox Developer Edition
**Decisão**: Usar apenas Firefox Developer Edition (não Firefox normal ou Chrome).
**Justificativa**:
- Firefox Developer Edition tem configurações de automação mais permissivas
- Wallaby + Selenium é padrão para testes E2E em Elixir
- GeckoDriver estável para Firefox
- Chrome requereria ChromeDriver separado

## Estrutura do Projeto

### Backend (Elixir/Phoenix)
- `lib/auto_vagas/` - Lógica principal da aplicação
  - `application.ex` - Inicialização da aplicação, Mnesia e cálculo de experiência
  - `experience.ex` - Cálculo de anos de experiência baseado em NTP
  - `user_info.ex` - Gerenciamento do arquivo `priv/user_info.json`
  - `ntp.ex` - Cliente NTP para sincronização de tempo
  - `crypto.ex` - Criptografia AES-256 para credenciais ⭐ NOVO
  - `automation.ex` - Inscrição automática via Firefox ⭐ NOVO
  - `mnesia/` - Módulos para banco de dados Mnesia
    - `schema.ex` - Criação de tabelas Mnesia
    - `search_manager.ex` - Gerenciamento de buscas simultâneas
  - `notifications/` - Módulos de notificações
    - `channels.ex` - Central de notificações
    - `whatsapp.ex` - Integração WhatsApp
    - `telegram.ex` - Integração Telegram
    - `discord.ex` - Integração Discord
    - `pending_job_handler.ex` - Tratamento de vagas pendentes
    - `user_info_updater.ex` - Atualização de user_info via mensagens

- `lib/crawler/` - Módulos de crawling
  - `adapter.ex` - Behavior e utilitários para adaptadores
  - `engine.ex` - Engine central de crawling
  - `worker.ex` - Workers GenServer para buscas simultâneas
  - `worker_supervisor.ex` - Supervisor dinâmico de workers
  - `auth.ex` - Autenticação SSO (simplificada)
  - `jobs_store.ex` - Armazenamento Mnesia de vagas ⭐ NOVO (substitui jobs_cache.ex)
  - `filter.ex` - Filtros de vagas
  - `geolocation.ex` - Cálculo de distâncias

- `lib/auto_vagas_web/live/` - LiveViews
  - `job_search_live.ex` - Página de busca com filtros avançados
  - `settings_live.ex` - Página de configurações (autenticação, notificações, filtros)
  - `jobs_live.ex` - Visualização de vagas salvas ⭐ ATUALIZADO (usa JobsStore + atom keys)
  - `home_live.ex` - Página inicial
  - `help_live.ex` - Página de ajuda ⭐ NOVO

- `lib/auto_vagas_web/controllers/` - Controllers
  - `auth_controller.ex` - Callbacks OAuth ⭐ CORRIGIDO (Protocol.UndefinedError)

- `lib/auto_vagas/sites/` - Adaptadores de plataformas
  - `linkedin.ex` - Adapter LinkedIn ⭐ CORRIGIDO (URI.encode charlist)
  - `indeed.ex` - Adapter Indeed
  - `gupy.ex` - Adapter Gupy

### Frontend (Phoenix LiveView + Tailwind CSS)
- `assets/js/app.js` - Configuração principal do LiveSocket
- `assets/js/hooks/job_search.js` - Hooks para busca de vagas
- `assets/js/components/notification.js` - Componentes de notificação
- `assets/css/app.css` - Estilos customizados

### Configurações e Dados
- `priv/user_info.json` - Arquivo principal de configuração do usuário
- `priv/filters/` - Configurações de filtros
  - `global_filters.json` - Filtros globais (aplicados a todas as buscas)
  - `source_filters.json` - Filtros específicos por fonte (LinkedIn, Indeed, Gupy)
  - `auth_config.json` - Configurações de autenticação SSO (criptografado)
- `mix.exs` - Configuração do projeto e dependências

## Funcionalidades Principais

### 1. Múltiplas Buscas Simultâneas
**Justificativa**: Cada busca é executada em um Worker GenServer supervisionado dinamicamente.
- Isolamento: falha em uma busca não afeta outras
- Paralelismo real: múltiplas buscas simultâneas
- Estado individual: cada worker mantém sua própria configuração
- Exemplo: Buscar "analista de segurança" no LinkedIn e Indeed enquanto busca "desenvolvedor back-end" em outras plataformas

### 2. Cálculo de Experiência com NTP
**Justificativa**: Usa protocolo NTP para obter tempo preciso.
- Calcula anos de experiência baseado em `initial_year_experience`
- Atualiza automaticamente ao iniciar o sistema
- Exemplo: Se em 2016 você tinha 2 anos de experiência em Python, o sistema calcula que em 2026 você tem 12 anos

### 3. JobsStore com Mnesia para Armazenamento ⭐ NOVO
**Justificativa**: Migrado de arquivo JSON para Mnesia (banco nativo Erlang).
- Tabelas: `:searches`, `:jobs`, `:notifications`, `:user_sessions`
- Armazenamento `disc_copies` para persistência
- Suporte a múltiplos workers simultâneos
- Operações distribuídas nativas

### 4. Integração com Canais de Notificação
- **WhatsApp**: WhatsApp Business API (bidirecional) - estrutura implementada
- **Telegram**: Bot API (bidirecional com comandos) - estrutura implementada
- **Discord**: Webhooks (unidirecional, apenas envio) - estrutura implementada

### 5. Autenticação SSO

#### LinkedIn OAuth 2.0 Flow ⭐ IMPLEMENTADO
**Justificativa**: Fluxo padrão OAuth 2.0 com Authorization Code.
1. Usuário clica em "Entrar com LinkedIn"
2. Redirecionamento para `https://www.linkedin.com/oauth/v2/authorization`
3. Login e consentimento de escopos (r_liteprofile, r_emailaddress)
4. LinkedIn retorna código de autorização
5. Backend troca código por Access Token (implementado em `lib/auto_vagas/auth/linkedin.ex`)
6. Callback handler em `lib/auto_vagas_web/controllers/auth_controller.ex`
7. Criptografia AES-256 para client_secret em `priv/filters/auth_config.json`

#### Indeed e Gupy:
- Indeed: OAuth 2.0 (estrutura, pendente fluxo real)
- Gupy: SAML 2.0 (estrutura, requer biblioteca `samly`)

### 6. Preenchimento via Mensagens (Pendente)
- Usuário pode responder vagas pendentes via WhatsApp/Telegram/Discord
- Exemplo: "minha experiência em Python é 2 anos"
- Sistema processa e atualiza `user_info.json` automaticamente

## Fluxo de Trabalho

1. **Inicialização**:
   - Mnesia inicia e cria tabelas (ou reconhece existentes)
   - NTP sincroniza tempo
   - Experiência é calculada com base no ano atual

2. **Busca**:
   - Usuário configura buscas no `user_info.json` ou via interface LiveView
   - Workers são iniciados para cada busca ativa (DynamicSupervisor)
   - Crawlers executam em paralelo para múltiplas plataformas
   - Filtros são aplicados (include/exclude words, min experience, etc.)

3. **Notificação**:
   - Novas vagas disparam alertas nos canais configurados
   - Vagas pendentes (que precisam de informações) notificam o usuário
   - Usuário responde via mensagem
   - Sistema preenche automaticamente

## Configuração de Filtros

### Filtros Globais (`priv/filters/global_filters.json`)
```json
{
  "include_words": ["python", "docker"],
  "exclude_words": ["estagio", "junior"],
  "min_experience_years": 3,
  "max_applications": 10,
  "remote_only": false
}
```

### Filtros por Fonte (`priv/filters/source_filters.json`)
```json
{
  "linkedin": {
    "include_words": [],
    "exclude_words": []
  },
  "indeed": {
    "include_words": [],
    "exclude_words": []
  }
}
```

## Arquitetura de Dados

### user_info.json
```json
{
  "location": "Brazil",
  "languages": ["Portuguese", "English"],
  "searches": [
    {
      "keywords": "analista de segurança",
      "sources": ["linkedin", "indeed"],
      "location": "Brazil",
      "active": true
    }
  ],
  "experience": {
    "python": {
      "initial_year_experience": 2014,
      "years_calculated": 12
    }
  },
  "notification_channels": {
    "telegram": {
      "enabled": true,
      "bot_token": "123456:ABC-DEF",
      "chat_id": "987654321"
    }
  }
}
```

## Como Executar

1. `mix setup` - Instala dependências e configura banco (Linux: `setup.sh`, Windows: `setup.bat`)
2. `mix phx.server` - Inicia servidor Phoenix na porta 4000
3. Acesse `http://localhost:4000`

## Dependências Principais
- Phoenix Framework 1.8.5
- Req (cliente HTTP) - **Escolhido por API moderna e retries automáticos**
- Floki (parser HTML) - **Escolhido por API funcional similar ao jQuery**
- Jason (JSON)
- Mnesia (banco de dados distribuído) - **Escolhido por ser nativo Erlang/OTP**
- Phoenix LiveView 1.1.0
- Wallaby + Selenium (automação web) - **Configurado para Firefox Developer Edition**

## Status de Implementação

### Funcionando ✅
- [x] Estrutura base com Mnesia (banco de dados distribuído)
- [x] Cálculo de experiência com NTP
- [x] Múltiplas buscas simultâneas (DynamicSupervisor + GenServer)
- [x] Filtros de busca (interface e lógica em `lib/crawler/filter.ex`)
- [x] Rotas LiveView: `/buscar`, `/vagas`, `/configuracoes`, `/ajuda`
- [x] UI de SSO na página de configuração com indicadores visuais
- [x] Criptografia AES-256 para Client Secret (`lib/auto_vagas/crypto.ex`)
- [x] **JobsStore implementado** (`lib/crawler/jobs_store.ex`) - Mnesia
- [x] **JobsLive atualizado** para usar Mnesia com atom keys
- [x] **LinkedIn OAuth 2.0 completo** (AuthController + Callback + Token exchange)
- [x] **Correção de bugs**: Protocol.UndefinedError, KeyError, URI.encode, etc.
- [x] Automação de inscrição via Firefox Developer Edition (`lib/auto_vagas/automation.ex`)
- [x] Wallaby + Selenium configurado para Firefox

### Em Progresso 🚧
- [ ] **Teste LinkedIn OAuth no navegador** - Código implementado, aguardando teste com conta real
  - URL de autorização: `https://www.linkedin.com/oauth/v2/authorization?scope=r_liteprofile+r_emailaddress&client_id=77ye1svdvforpt&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Flinkedin%2Fcallback&response_type=code`
  - Callback: `http://localhost:4000/auth/linkedin/callback`
  - **Status**: Aguardando autorização no navegador

### Pendente ⏳
- [ ] Processamento de mensagens para preenchimento automático (WhatsApp/Telegram)
- [ ] Crawling real (LinkedIn/Indeed requerem JavaScript - considerar API oficial)
- [ ] Implementação completa do fluxo Indeed OAuth 2.0
- [ ] Implementação completa do fluxo Gupy SAML 2.0 (requer biblioteca `samly`)
- [ ] Configuração de canais de notificação (WhatsApp Business API, Telegram Bot, Discord Webhook)
- [ ] Deploy em produção (HTTPS obrigatório para LinkedIn OAuth)
- [ ] Crawler de vagas direto no Google
- [ ] Crawler de grupos de vagas (Telegram, WhatsApp e Discord)

## Notas de Desenvolvimento
- O projeto usa `:mnesia` como extra_application no mix.exs
- Workers são supervisionados dinamicamente via DynamicSupervisor
- NTP module usa UDP na porta 123 para sincronização de tempo
- Formularios LiveView usam `to_form/1,2` e `<.input>` do core_components.ex
- Notificacoes usam Phoenix.PubSub para broadcast interno
- **Servidor pode receber SIGTERM**: Usar `nohup mix phx.server &` ou `setsid mix phx.server &`
- **inotify-tools opcional**: Apenas para live-reload, não impacta funcionamento

## Testes da API LinkedIn

### Credenciais Configuradas
- Client ID: `77ye1svdvforpt`
- Client Secret: `[REMOVIDO - criptografado em auth_config.json]`
- Redirect URI: `http://localhost:4000/auth/linkedin/callback`

### Teste 1: Geracao de URL de Autorizacao
- Status: OK
- URL gerada corretamente com parametros:
  - `scope=r_liteprofile+r_emailaddress`
  - `response_type=code`
  - `client_id=77ye1svdvforpt`
  - `redirect_uri=http://localhost:4000/auth/linkedin/callback`

### Teste 2: Troca de Codigo por Access Token
- Status: IMPLEMENTADO (requer teste no navegador)
- Fluxo:
  1. Usuario visita URL de autorizacao
  2. Faz login e autoriza o app
  3. LinkedIn redireciona para `/auth/linkedin/callback?code=...`
  4. Sistema troca o codigo por access_token via POST para `https://www.linkedin.com/oauth/v2/accessToken`
  5. Token é salvo criptografado em `priv/filters/auth_config.json`

### Teste 3: Criptografia AES-256
- Status: OK
- Modulo: `lib/auto_vagas/crypto.ex`
- Client Secret é criptografado antes de salvar no `auth_config.json`
- Funcao `encrypt/1` e `decrypt/1` implementadas

### Bugs Corrigidos Hoje
1. **linkedin.ex**: `URI.encode` com charlist - Corrigido com `to_string/1`
2. **application.ex**: Warning `wait_for_tables` - Corrigido pattern match
3. **AuthController**: `Protocol.UndefinedError` - Corrigido com `inspect/1`
4. **JobsLive**: `KeyError :selected` - Corrigido usando atom keys consistentemente
5. **filter.ex**: Módulo `JobsStore` aninhado - Removido, criado arquivo separado
6. **JobsLive**: Acesso a jobs com string keys - Corrigido para atom keys (`:title`, `:company`, etc.)

### Problemas Conhecidos
1. **LinkedIn exige HTTPS em producao** - Para testes locais, usar `http://localhost` funciona
2. **CoreComponents.input nao suporta type="radio"** - Usar `<input type="radio">` nativo do HTML
3. **JobSearchLive.flat_map erro** - Pattern match falhava quando `Task.await_many` retornava erro. Corrigido adicionando clause para `_ -> []`
4. **Crawlers estáticos não funcionam**: LinkedIn/Indeed carregam vagas via JavaScript (considerar API oficial ou Selenium)

### Arquivos de Teste
- `test_linkedin_api.exs` - Script para testar API LinkedIn manualmente
- Execute: `mix run test_linkedin_api.exs`
- `TODO.md` - Lista completa de tarefas e decisões arquiteturais

## Estrutura de Arquivos Atualizada

```
lib/
├── auto_vagas/
│   ├── application.ex          # Inicialização, Mnesia, NTP
│   ├── experience.ex          # Cálculo de experiência
│   ├── user_info.ex          # Gerenciamento user_info.json
│   ├── ntp.ex                # Cliente NTP
│   ├── crypto.ex             # AES-256 criptografia
│   ├── automation.ex        # Inscrição automática ⭐ NOVO
│   ├── auth/
│   │   ├── linkedin.ex      # OAuth 2.0 LinkedIn ⭐ CORRIGIDO
│   │   ├── indeed.ex        # OAuth 2.0 Indeed (estrutura)
│   │   └── gupy.ex         # SAML 2.0 Gupy (estrutura)
│   ├── mnesia/
│   │   ├── schema.ex        # Tabelas Mnesia
│   │   └── search_manager.ex # Gerenciamento de buscas
│   └── notifications/
│       ├── channels.ex      # Central de notificações
│       ├── whatsapp.ex      # WhatsApp (estrutura)
│       ├── telegram.ex      # Telegram (estrutura)
│       ├── discord.ex       # Discord (estrutura)
│       ├── pending_job_handler.ex
│       └── user_info_updater.ex
├── crawler/
│   ├── adapter.ex           # Behavior para adaptadores
│   ├── engine.ex           # Engine central de crawling
│   ├── worker.ex           # Workers GenServer
│   ├── worker_supervisor.ex # Supervisor dinâmico
│   ├── filter.ex           # Filtros de vagas
│   ├── jobs_store.ex       # Armazenamento Mnesia ⭐ NOVO
│   └── geolocation.ex      # Cálculo de distâncias
└── auto_vagas_web/
    ├── live/
    │   ├── home_live.ex     # Página inicial
    │   ├── job_search_live.ex # Busca de vagas
    │   ├── jobs_live.ex     # Vagas salvas ⭐ ATUALIZADO
    │   ├── settings_live.ex # Configurações
    │   └── help_live.ex     # Ajuda
    ├── controllers/
    │   └── auth_controller.ex # Callbacks OAuth ⭐ CORRIGIDO
    └── router.ex           # Rotas
```

## Como Testar Hoje

### 1. Servidor Phoenix
```bash
cd /home/frota/Documents/repositorios/auto_vagas
mix clean && mix deps.get && mix compile
mix phx.server
```
Acesse: http://localhost:4000

### 2. LinkedIn OAuth (Requer Navegador)
1. Acesse a URL de autorização (copie do TODO.md ou AGENTS.md)
2. Faça login no LinkedIn e autorize o app
3. O LinkedIn redirecionará para `http://localhost:4000/auth/linkedin/callback?code=...`
4. O sistema trocará o código por access_token automaticamente
5. Você será redirecionado para `/configuracoes` com mensagem de sucesso

### 3. Teste de Vagas
```bash
# Adicionar vaga manualmente
mix run -e '
jobs = [%{"search_id" => "1", "external_id" => "123", "source" => "linkedin", "title" => "Elixir Developer", "company" => "Test", "location" => "Remote", "url" => "https://..."}]
AutoVagas.Crawler.JobsStore.save(jobs)
'

# Ver no navegador: http://localhost:4000/vagas
```
