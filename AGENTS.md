# AutoVagas - Documentação do Projeto

## Visão Geral

O AutoVagas é uma aplicação web construída com Phoenix Framework (Elixir) para busca automatizada de vagas de emprego. O sistema permite crawlear múltiplas plataformas simultaneamente, com suporte a filtros avançados e notificações via múltiplos canais.

## Estrutura do Projeto

### Backend (Elixir/Phoenix)
- `lib/auto_vagas/` - Lógica principal da aplicação
  - `application.ex` - Inicialização da aplicação, Mnesia e cálculo de experiência
  - `experience.ex` - Cálculo de anos de experiência baseado em NTP
  - `user_info.ex` - Gerenciamento do arquivo `priv/user_info.json`
  - `ntp.ex` - Cliente NTP para sincronização de tempo
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
  - `jobs_cache.ex` - Cache de vagas (será migrado para Mnesia)
  - `filter.ex` - Filtros de vagas
  - `geolocation.ex` - Cálculo de distâncias

- `lib/auto_vagas_web/live/` - LiveViews
  - `job_search_live.ex` - Página de busca com filtros avançados
  - `settings_live.ex` - Página de configurações (autenticação, notificações, filtros)
  - `jobs_live.ex` - Visualização de vagas salvas
  - `home_live.ex` - Página inicial

- `lib/auto_vagas/sites/` - Adaptadores de plataformas
  - `linkedin.ex` - Adapter LinkedIn
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
  - `auth_config.json` - Configurações de autenticação SSO
- `mix.exs` - Configuração do projeto e dependências

## Funcionalidades Principais

### 1. Múltiplas Buscas Simultâneas
- Cada busca é executada em um Worker GenServer separado
- Diferentes parâmetros por busca (keywords, location, filters)
- Exemplo: Buscar "analista de segurança" no LinkedIn e Indeed enquanto busca "desenvolvedor back-end" em outras plataformas

### 2. Cálculo de Experiência com NTP
- Usa protocolo NTP para obter tempo preciso
- Calcula anos de experiência baseado em `initial_year_experience`
- Atualiza automaticamente ao iniciar o sistema
- Exemplo: Se em 2016 você tinha 2 anos de experiência em Python, o sistema calcula que em 2026 você tem 12 anos

### 3. Mnesia para Armazenamento
- Tabelas: `:searches`, `:jobs`, `:notifications`, `:user_sessions`
- Armazenamento disc_copies para persistência
- Suporte a múltiplos workers simultâneos

### 4. Integração com Canais de Notificação
- **WhatsApp**: WhatsApp Business API (bidirecional)
- **Telegram**: Bot API (bidirecional com comandos)
- **Discord**: Webhooks (unidirecional, apenas envio)

### 5. Autenticação SSO

#### LinkedIn OAuth 2.0 Flow:
1. Usuário clica em "Entrar com LinkedIn"
2. Redirecionamento para `https://www.linkedin.com/oauth/v2/authorization`
3. Login e consentimento de escopos (r_liteprofile, r_emailaddress)
4. LinkedIn retorna código de autorização
5. Backend troca código por Access Token
6. Token é usado para acessar API do LinkedIn

#### Indeed e Gupy:
- Login via formulário tradicional
- Cookies são salvos e reutilizados nas requisições

### 6. Preenchimento via Mensagens
- Usuário pode responder vagas pendentes via WhatsApp/Telegram/Discord
- Exemplo: "minha experiência em Python é 2 anos"
- Sistema processa e atualiza `user_info.json` automaticamente

## Fluxo de Trabalho

1. **Inicialização**:
   - Mnesia inicia e cria tabelas
   - NTP sincroniza tempo
   - Experiência é calculada com base no ano atual

2. **Busca**:
   - Usuário configura buscas no `user_info.json` ou via interface
   - Workers são iniciados para cada busca ativa
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

1. `mix setup` - Instala dependências e configura banco
2. `mix phx.server` - Inicia servidor Phoenix na porta 4000
3. Acesse `http://localhost:4000`

## Dependências Principais
- Phoenix Framework 1.8.5
- Req (cliente HTTP)
- Floki (parser HTML)
- Jason (JSON)
- Mnesia (banco de dados distribuído)
- Phoenix LiveView 1.1.0

## Status de Implementação
- [x] Estrutura base com Mnesia
- [x] Cálculo de experiência com NTP
- [x] Múltiplas buscas simultâneas
- [x] Integração WhatsApp (estrutura)
- [x] Integração Telegram (estrutura)
- [x] Integração Discord (estrutura)
- [x] Filtros de busca (interface e lógica)
- [x] Autenticação SSO (estrutura no settings)
- [x] Implementação completa do fluxo OAuth LinkedIn (AutoVagas.Auth.LinkedIn)
- [x] Correção de sintaxe: headers tuple, notação de átomos, require :mnesia
- [x] Correção de warnings de compilação (nil.build_urls, unused vars, typing violations)
- [x] Rotas LiveView adicionadas (/buscar, /vagas, /configuracoes)
- [x] Mnesia Schema corrigido para single-node development
- [x] AuthSession refatorado para GenServer (sem dependência de Agent)
- [x] UI de SSO na página de configuração com indicadores visuais 
- [ ] Processamento de mensagens para preenchimento automático
- [ ] Migração completa de JobsCache para Mnesia

## Notas de Desenvolvimento
- O projeto usa `:mnesia` como extra_application no mix.exs
- Workers sao supervisionados dinamicamente via DynamicSupervisor
- NTP module usa UDP na porta 123 para sincronizacao de tempo
- Formularios LiveView usam `to_form/1,2` e `<.input>` do core_components.ex
- Notificacoes usam Phoenix.PubSub para broadcast interno

## Testes da API LinkedIn

### Credenciais Configuradas
- Client ID: `3x3mpl3`
- Client Secret: `[REMOVIDO - criptografado em auth_config.json]`
- Redirect URI: `http://localhost:4000/auth/linkedin/callback`

### Teste 1: Geracao de URL de Autorizacao
- Status: OK
- URL gerada corretamente com parametros:
  - `scope=r_liteprofile+r_emailaddress`
  - `response_type=code`
  - `client_id=3x3mpl3`
  - `redirect_uri=http://localhost:4000/auth/linkedin/callback`

### Teste 2: Troca de Codigo por Access Token
- Status: PENDENTE (requer visita ao navegador)
- Fluxo:
  1. Usuario visita URL de autorizacao
  2. Faz login e autoriza o app
  3. LinkedIn redireciona para `/auth/linkedin/callback?code=...`
  4. Sistema troca o codigo por access_token via POST para `https://www.linkedin.com/oauth/v2/accessToken`

### Teste 3: Criptografia AES-256
- Status: OK
- Modulo: `lib/auto_vagas/crypto.ex`
- Client Secret e criptografado antes de salvar no `auth_config.json`
- Funcao `encrypt/1` e `decrypt/1` implementadas

### Problemas Encontrados
1. **LinkedIn exige HTTPS em producao** - Para testes locais, usar `http://localhost` funciona
2. **phx-value no botao add_profile** - Evento estava enviando `%{"value" => ""}` incorretamente. Corrigido mudando o handler para aceitar `_params`
3. **CoreComponents.input nao suporta type="radio"** - Usar `<input type="radio">` nativo do HTML
4. **JobSearchLive.flat_map erro** - Pattern match falhava quando `Task.await_many` retornava erro. Corrigido adicionando clause para `_ -> []`

### Arquivos de Teste
- `test_linkedin_api.exs` - Script para testar API LinkedIn manualmente
- Execute: `mix run test_linkedin_api.exs`
