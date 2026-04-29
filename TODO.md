# AutoVagas - TODO e Status de Implementação

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

---

## Funcionalidades Implementadas ✅

### Core
- [x] **Mnesia Schema**: Tabelas `:searches`, `:jobs`, `:notifications`, `:user_sessions`
- [x] **Cálculo de Experiência**: Baseado em NTP (`lib/auto_vagas/ntp.ex`)
- [x] **Múltiplas Buscas**: Workers GenServer via DynamicSupervisor
- [x] **JobsStore**: Armazenamento de vagas no Mnesia (`lib/crawler/jobs_store.ex`)

### Crawlers
- [x] **LinkedIn Adapter**: Estrutura + URL builder (`lib/auto_vagas/sites/linkedin.ex`)
- [x] **Indeed Adapter**: Estrutura (`lib/auto_vagas/sites/indeed.ex`)
- [x] **Gupy Adapter**: Estrutura + API client (`lib/auto_vagas/sites/gupy.ex`)

### Autenticação SSO
- [x] **LinkedIn OAuth 2.0**: Fluxo completo (`lib/auto_vagas/auth/linkedin.ex`)
  - [x] Geração de URL de autorização
  - [x] Troca de código por access_token
  - [x] Callback handler (`lib/auto_vagas_web/controllers/auth_controller.ex`)
  - [x] Criptografia AES-256 para client_secret
- [x] **Indeed OAuth 2.0**: Estrutura (pendente fluxo real)
- [x] **Gupy SAML 2.0**: Estrutura (pendente biblioteca `samly`)

### Interface Web (LiveView)
- [x] **Configurações**: `/configuracoes` (SSO, notificações, filtros)
  - [x] UI de SSO com indicadores visuais
  - [x] Modal para credenciais
  - [x] Radio buttons para canais de notificação
- [x] **Busca de Vagas**: `/buscar` com filtros
- [x] **Vagas Salvas**: `/vagas` (listagem, filtros, seleção)
- [x] **Página Inicial**: `/`
- [x] **Ajuda**: `/ajuda` com documentação SSO

### Filtros
- [x] **Filtros Globais**: `priv/filters/global_filters.json`
- [x] **Filtros por Fonte**: `priv/filters/source_filters.json`
- [x] **Lógica de Filtragem**: `lib/crawler/filter.ex`

### Automação
- [x] **Módulo de Automação**: `lib/auto_vagas/automation.ex`
- [x] **Wallaby + Selenium**: Configurado para Firefox Developer Edition
- [x] **Inscrição Automática**: Integrada ao Worker após crawling

### Correções de Bugs
- [x] **Bug 1**: `linkedin.ex` - `URI.encode` com charlist (corrigido com `to_string/1`)
- [x] **Bug 2**: `application.ex` - Warning `wait_for_tables` (corrigido pattern match)
- [x] **Bug 3**: `AuthController` - `Protocol.UndefinedError` (corrigido com `inspect/1`)
- [x] **Bug 4**: `JobsLive` - KeyError `:selected` (corrigido usando atom keys)
- [x] **Bug 5**: `filter.ex` - Módulo `JobsStore` aninhado (removido, criado arquivo separado)
- [x] **Bug 6**: `JobSearchLive` - `flat_map` erro (corrigido clauses adicionais)
- [x] **Bug 7**: `CoreComponents` - `input` não suporta `type="radio"` (usar HTML nativo)

---

## Em Progresso 🚧

### LinkedIn OAuth 2.0
- [ ] **Teste no Navegador**: Requer visita à URL de autorização
  - URL: `https://www.linkedin.com/oauth/v2/authorization?scope=r_liteprofile+r_emailaddress&client_id=77ye1svdvforpt&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Flinkedin%2Fcallback&response_type=code`
  - Após autorização, LinkedIn redireciona para `/auth/linkedin/callback?code=...`
  - **Status**: Código implementado, aguardando teste com conta real

### Integração com IA ✅ IMPLEMENTADO
- [x] **Ollama Local**: Funcionando (`AutoVagas.AI.Ollama.analyze_resume/2`)
  - Modelo `llama3.2` instalado e testado
  - Extração de experiência funcionando perfeitamente
- [x] **Gemini API**: Implementado (`AutoVagas.AI.Gemini.analyze_resume/2`)
  - Requer `GEMINI_API_KEY` configurada
- [x] **OpenAI API**: Implementado (`AutoVagas.AI.OpenAI.analyze_resume/2`)
- [x] **Extração de Experiência**: `AutoVagas.AI.extract_experience/2` ✅ Funcionando
- [x] **Complemento de Perfil**: `AutoVagas.AI.complete_user_info/3` ✅ Funcionando
- [x] **Processamento PDF**: `AutoVagas.AI.PDF` ✅ Criado
- [x] **Explicações de Habilidades**: `AutoVagas.AI.Explanation` ✅ Criado

### Perfil LinkedIn ✅ IMPLEMENTADO
- [x] **Extração de Perfil**: `AutoVagas.LinkedInProfile` ✅ Criado
- [x] **Scraping via Wallaby**: Implementado (requer Firefox Developer Edition)
- [x] **API LinkedIn**: Estrutura criada (requer token válido)
- [x] **Atualização de user_info**: `fetch_and_update/2` ✅ Funcionando

### Página de Habilidades ✅ IMPLEMENTADO
- [x] **LiveView**: `AutoVagasWeb.SkillsLive` ✅ Criado
- [x] **Abas**: Técnicas, Comportamentais, Certificações, Cursos, Hack The Box
- [x] **Explicações**: Geradas por IA (Ollama testado e funcionando)
- [x] **Toggle Explicações**: Mostrar/Ocultar explicações
- [x] **Atualização com IA**: Botão "Atualizar c/ IA" ✅

### Credenciais Configuradas
- [ ] **LinkedIn**: Client ID `77ye1svdvforpt`, Client Secret (criptografado)
- [ ] **Indeed**: Pendente
- [ ] **Gupy**: Pendente

---

## Pendências ⏳

### Notificações
- [ ] **WhatsApp Business API**: Implementação completa (estrutura existe)
- [ ] **Telegram Bot API**: Implementação completa (estrutura existe)
- [ ] **Discord Webhooks**: Implementação completa (estrutura existe)
- [ ] **Bidirecional**: Processar mensagens recebidas (WhatsApp/Telegram)

### Crawlers Reais
- [ ] **LinkedIn**: Scraping real (requer JavaScript ou API oficial)
- [ ] **Indeed**: Scraping real (requer JavaScript ou API)
- [ ] **Gupy**: API real (requer token válido)
- [ ] **Google Jobs**: Novo crawler
- [ ] **Grupos**: Telegram, WhatsApp, Discord

### Migração e Refatoração
- [ ] **JobsCache → Mnesia**: Migração completa (JobsStore criado, integrado no JobsLive)
- [ ] **UserConfig**: Centralizar leitura de configurações do usuário

### Configuração de Ambiente
- [ ] **inotify-tools**: Instalar para live-reload (`sudo apt install inotify-tools`)
- [ ] **Firefox Developer Edition**: Verificar instalação em `/usr/bin/firefox-developer-edition`
- [ ] **GeckoDriver**: Verificar em `/usr/bin/geckodriver`

### Deploy e Produção
- [ ] **HTTPS Obrigatório**: LinkedIn OAuth exige HTTPS em produção
- [ ] **Configuração SSL**: Certificados (self-signed ou Let's Encrypt)
- [ ] **Variáveis de Ambiente**: `LINKEDIN_CLIENT_ID`, `LINKEDIN_CLIENT_SECRET`
- [ ] **Docker**: Containerização para deploy

---

## Como Testar Hoje

### 1. Servidor Phoenix
```bash
cd /home/frota/Documents/repositorios/auto_vagas
mix clean && mix deps.get && mix compile
mix phx.server
```
Acesse: http://localhost:4000

### 2. LinkedIn OAuth (Requer Navegador)
1. Acesse a URL de autorização (copie do código acima)
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

---

## Scripts Disponíveis

### `setup.sh` (Linux)
- Instala Elixir, Node.js, Firefox Dev, GeckoDriver
- Configura projeto (`mix deps.get`, `mix assets.build`)

### `setup.bat` (Windows - Requer Admin)
- Instala via Chocolatey
- Configuração automática

### `test_linkedin_api.exs`
- Testa geração de URL
- Testa troca de código (manual)
- Testa API de perfil

---

## Estrutura de Arquivos Atualizada

```
lib/
├── auto_vagas/
│   ├── application.ex          # Inicialização, Mnesia, NTP
│   ├── experience.ex          # Cálculo de experiência
│   ├── user_info.ex          # Gerenciamento user_info.json
│   ├── ntp.ex                # Cliente NTP
│   ├── crypto.ex             # AES-256 criptografia
│   ├── auth/
│   │   ├── linkedin.ex      # OAuth 2.0 LinkedIn
│   │   ├── indeed.ex        # OAuth 2.0 Indeed (estrutura)
│   │   └── gupy.ex         # SAML 2.0 Gupy (estrutura)
│   ├── mnesia/
│   │   ├── schema.ex        # Tabelas Mnesia
│   │   └── search_manager.ex # Gerenciamento de buscas
│   ├── notifications/
│   │   ├── channels.ex      # Central de notificações
│   │   ├── whatsapp.ex      # WhatsApp (estrutura)
│   │   ├── telegram.ex      # Telegram (estrutura)
│   │   ├── discord.ex       # Discord (estrutura)
│   │   ├── pending_job_handler.ex
│   │   └── user_info_updater.ex
│   ├── automation.ex        # Inscrição automática
│   └── sites/
│       ├── linkedin.ex      # Adapter LinkedIn
│       ├── indeed.ex        # Adapter Indeed
│       └── gupy.ex         # Adapter Gupy
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

---

## Notas de Desenvolvimento

### Compilação sem Warnings
```bash
mix compile
# ✅ Generated auto_vagas app (sem warnings de código)
```

### Testes Manuais
- LinkedIn OAuth: Requer conta real e navegador
- Crawlers: LinkedIn/Indeed requerem JavaScript (scraping estático não funciona)
- Gupy: API retorna HTML (pode requerer autenticação)

### Problemas Conhecidos
1. **Servidor para após alguns segundos**: Recebe SIGTERM (sistema ou processo pai)
   - Solução: Usar `nohup mix phx.server &` ou `setsid mix phx.server &`
2. **inotify-tools não instalado**: Apenas afeta live-reload, não impacta funcionamento
3. **Mnesia já existe**: Warning normal, tabelas já foram criadas anteriormente

---

## Contribuição

Pull requests são bem-vindos! Consulte `AGENTS.md` para detalhes da arquitetura.

Licença: Apache 2.0
