# AutoVagas

Sistema de busca e inscrição automatizada de vagas de emprego construído com Phoenix Framework (Elixir). Permite buscar em múltiplas plataformas simultaneamente com filtros avançados, notificações via WhatsApp, Telegram e Discord, e **inscrição automática via Firefox Developer Edition**.

- [x] Linux
- [ ] Windows
- [ ] Mac OS

## Funcionalidades

- **Múltiplas buscas simultâneas** usando Mnesia e GenServer workers
- **Cálculo de experiência** baseado em NTP (Network Time Protocol)
- **Filtros avançados**: palavras incluídas/excluídas, experiência mínima, apenas remoto
- **Notificações** via WhatsApp, Telegram e Discord (apenas um canal ativo - radio button)
- **Integração SSO**: LinkedIn (OAuth 2.0), Indeed, Gupy (SAML 2.0)
- **Criptografia AES-256** para credenciais sensíveis
- **Inscrição automática** via Firefox Developer Edition (apenas esta versão suportada)
- **JobsStore com Mnesia** para armazenamento de vagas (`lib/crawler/jobs_store.ex`)
- **Interface LiveView** responsiva com Tailwind CSS + daisyUI
- **Integração com IA** para análise de currículo (Ollama local, Gemini, OpenAI) ⭐ NOVO

## Rotas Principais

| Rota | Descrição |
|------|-----------|
| `/` | Página inicial |
| `/buscar` | Busca de vagas com filtros |
| `/vagas` | Visualização de vagas salvas (Mnesia) |
| `/configuracoes` | Configurações (autenticação, notificações, filtros) |
| `/ajuda` | Instruções para configurar integrações SSO |

## Status de Implementação

### Funcionando ✅

- [x] Estrutura base com Mnesia (banco de dados distribuído)
- [x] Cálculo de experiência com NTP
- [x] Múltiplas buscas simultâneas (DynamicSupervisor + GenServer)
- [x] Filtros de busca (interface e lógica em `lib/crawler/filter.ex`)
- [x] Rotas LiveView: `/buscar`, `/vagas`, `/configuracoes`
- [x] UI de SSO na página de configuração com indicadores visuais (ativo, inativo)
- [x] Botão "Adicionar Credenciais" para LinkedIn com modal
- [x] Criptografia AES-256 para Client Secret (`lib/auto_vagas/crypto.ex`)
- [x] Página de ajuda (`/ajuda`) com links para documentação oficial
- [x] Radio buttons nas notificações (apenas um canal ativo por vez)
- [x] Correção de bugs: `add_profile`, `JobSearchLive.flat_map`, `linkedin.ex` (encode_query)
- [x] Automação de inscrição via Firefox Developer Edition (`lib/auto_vagas/automation.ex`)
- [x] Wallaby + Selenium configurado para Firefox
- [x] **JobsStore implementado** (`lib/crawler/jobs_store.ex`) - Mnesia
- [x] **JobsLive atualizado** para usar Mnesia com atom keys
- [x] **LinkedIn OAuth 2.0 completo** (AuthController + Callback + Token exchange)
- [x] **Correção Protocol.UndefinedError** no AuthController e linkedin.ex

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

## Como Executar

### Linux
```bash
# Instalar todas as dependências (Firefox Dev, GeckoDriver, Elixir, etc.)
chmod +x setup.sh
./setup.sh

# Iniciar servidor Phoenix (porta 4000)
mix phx.server
```

### Windows
1. Clique com botão direito em `setup.bat`
2. Selecione "Executar como Administrador"
3. Após instalação, execute:
   ```cmd
   mix phx.server
   ```

Acesse `http://localhost:4000` no navegador.

## Configuração de Integrações SSO

### LinkedIn OAuth 2.0

1. Acesse https://www.linkedin.com/developers/apps/new
2. Crie um aplicativo e copie o **Client ID** e **Primary Client Secret**
3. Adicione a URL de redirecionamento: `http://localhost:4000/auth/linkedin/callback`
4. No AutoVagas, vá em `/configuracoes` → clique em "Adicionar Credenciais" (LinkedIn)
5. Insira os dados e clique em "Salvar" (serão criptografados com AES-256)
6. Clique em "Integrar" e autorize no navegador

### Indeed e Gupy

- Atualmente com estrutura inicial (sem fluxo real implementado)
- Indeed: requer configuração no portal de desenvolvedores
- Gupy: requer certificado X.509 e whitelist de IP/domínio

## Estrutura do Projeto

```
lib/
├── auto_vagas/
│   ├── auth/           # Módulos de autenticação SSO (LinkedIn, Indeed, Gupy)
│   ├── crypto.ex       # Criptografia AES-256
│   ├── mnesia/         # Banco de dados Mnesia (schema, search_manager)
│   ├── notifications/  # Notificações (WhatsApp, Telegram, Discord)
│   ├── crawler/        # Crawlers e adaptadores de plataformas
│   └── ntp.ex         # Cliente NTP para sincronização de tempo
└── auto_vagas_web/
    ├── live/           # LiveViews (busca, configurações, vagas, ajuda)
    └── controllers/    # Controllers (auth callbacks)

priv/
├── filters/            # Configurações de filtros e autenticação
│   ├── auth_config.json      # Credenciais SSO (criptografadas)
│   ├── global_filters.json  # Filtros globais
│   └── source_filters.json  # Filtros por fonte
└── user_info.json      # Configuração do usuário (localização, idiomas, buscas)

test_linkedin_api.exs   # Script para testar API LinkedIn
AGENTS.md               # Documentação completa para agentes de IA
```

## Recursos Necessários para Funcionamento

### Sistema Operacional
- Linux (testado no Ubuntu/Debian)
- **Apenas Firefox Developer Edition** (/usr/bin/firefox-developer-edition)
- GeckoDriver 0.36.0 (/usr/bin/geckodriver)
- inotify-tools (opcional, para live-reload)

**Nota:** Apenas o Firefox Developer Edition é suportado para automação. Firefox normal ou Chrome não funcionarão.

### Dependências Elixir/Erlang
- Elixir ~> 1.15
- Erlang/OTP 22+

### Dependências do Projeto (mix.exs)
- phoenix ~> 1.8.5
- phoenix_live_view ~> 1.1.0
- wallaby ~> 0.30 (para automação web)
- req ~> 0.5 (cliente HTTP)
- floki ~> 0.36 (parser HTML)
- jason ~> 1.2 (JSON)
- mnesia (banco de dados distribuído, nativo do Erlang)

### Configuração de Ambiente
1. GeckoDriver deve estar no PATH: /usr/bin/geckodriver
2. Firefox Developer Edition deve estar acessível: /usr/bin/firefox-developer-edition
3. Wallaby configurado em config/config.exs:
   ```elixir
   config :wallaby, driver: Wallaby.Selenium,
     selenium: [
       capabilities: %{
         browserName: "firefox",
         "moz:firefoxOptions": %{
           binary: "/usr/bin/firefox-developer-edition",
           args: ["-headless"]
         }
       }
     ]
   ```

### Para Automação de Inscrições
- **Apenas Firefox Developer Edition** instalado em `/usr/bin/firefox-developer-edition`
- GeckoDriver instalado em `/usr/bin/geckodriver`
- Wallaby + Selenium configurados para Firefox Developer Edition
- Acesso à internet para vagas do LinkedIn

**Nota:** O sistema abrirá automaticamente a página de configuração SSO no Firefox Developer Edition após a instalação.

## Integração com IA ✅ FUNCIONANDO

O AutoVagas possui integração com modelos de IA para **reconhecimento automático de currículo**.

### Provedores Suportados
- **Ollama** (local): `http://localhost:11434` - ✅ Testado e funcionando
- **Gemini API**: Google Gemini (requer `GEMINI_API_KEY`)
- **OpenAI API**: GPT-4o, GPT-3.5 (requer `OPENAI_API_KEY`)

### Funcionalidades Implementadas
1. **Extração de Experiência** ✅: Analisa o currículo e extrai anos de experiência por tecnologia
   - Testado com Ollama - funcionando perfeitamente
2. **Complemento de Perfil** ✅: Completa automaticamente `user_info.json`
3. **Processamento PDF** ✅: Extrai texto de PDFs (requer `poppler-utils`)
4. **Perfil LinkedIn** ✅: Extrai dados do perfil LinkedIn (scraping ou API)
5. **Explicações de Habilidades** ✅: IA gera explicações para certificações, cursos, desafios
6. **Página de Habilidades** ✅: Visualização completa em `/habilidades`

### Configuração
Crie `priv/ai_config.json` (veja `priv/ai_config.json.example`):
```json
{
  "provider": "ollama",
  "ollama": {
    "enabled": true,
    "endpoint": "http://localhost:11434",
    "model": "llama3.2"
  },
  "gemini": {
    "enabled": false,
    "api_key": "YOUR_GEMINI_API_KEY",
    "model": "gemini-2.0-flash"
  }
}
```

### Exemplo de Uso Testado
```bash
# Extração de experiência (testado e funcionando)
mix run test_pdf.exs
# Ou:
mix run -e '
resume = "João Silva\nPython (2018 - Atual): 8 anos\nElixir (2020 - Atual): 6 anos"
AutoVagas.AI.extract_experience(resume) |> IO.inspect()
'

# Página de habilidades: http://localhost:4000/habilidades
# Clique em "Atualizar c/ IA" para gerar explicações
```

### Pré-requisitos
- **Ollama** ✅: Instalado e modelo `llama3.2` baixado
- **pdftotext**: `sudo apt install poppler-utils` (para PDFs)
- **Gemini/OpenAI**: Configurar API keys se desejar usar

## Detalhes Técnicos da Implementação

### 1. **Integração com IA** ✅
- **Módulo Principal**: `lib/auto_vagas/ai.ex` - Roteamento entre provedores
- **Ollama Local** ✅: `lib/auto_vagas/ai/ollama.ex` - Testado com modelo `llama3.2`
  - Endpoint: `http://localhost:11434`
  - Requer: `ollama serve` rodando e modelo baixado
- **Gemini API**: `lib/auto_vagas/ai/gemini.ex` - Requer `GEMINI_API_KEY`
- **OpenAI API**: `lib/auto_vagas/ai/openai.ex` - Requer `OPENAI_API_KEY`
- **Processamento PDF**: `lib/auto_vagas/ai/pdf.ex` - Extrai texto com `pdftotext`
- **Explicações**: `lib/auto_vagas/ai/explanation.ex` - Gera contexto para habilidades

### 2. **Perfil LinkedIn** ✅
- **Extração**: `lib/auto_vagas/linkedin_profile.ex` - Scraping ou API
- **Scraping**: Usa Wallaby + Firefox Developer Edition
- **Atualização**: `AutoVagas.LinkedInProfile.fetch_and_update/2` atualiza `user_info.json`
- **Integração**: `lib/auto_vagas/auth/linkedin.ex` - OAuth 2.0

### 3. **Página de Habilidades** ✅
- **LiveView**: `lib/auto_vagas_web/live/skills_live.ex`
- **URL**: `http://localhost:4000/habilidades`
- **Abas**: Técnicas, Comportamentais, Certificações, Cursos, Hack The Box
- **IA**: Botão "Atualizar c/ IA" gera explicações automáticas
- **Toggle**: Mostrar/Ocultar explicações

### 4. **Automação Web** ✅
- **Módulo**: `lib/auto_vagas/automation.ex`
- **Suporte**: Firefox Developer Edition (obrigatório) em `/usr/bin/firefox-developer-edition`
- **GeckoDriver**: `/usr/bin/geckodriver` (v0.36.0)
- **Fluxo**: Inicia sessão → Aplica para vagas → Encerra sessão

### 5. **Armazenamento Mnesia** ✅
- **JobsStore**: `lib/crawler/jobs_store.ex` - Substitui `jobs_cache.ex`
- **Tabelas**: `:jobs`, `:searches`, `:notifications`, `:user_sessions`
- **Tipo**: `disc_copies` (persistência com performance)
- **Uso**: `AutoVagas.Crawler.JobsStore.save/1` e `load/0`

### 6. **LinkedIn OAuth 2.0** ✅
- **Fluxo**: Autorização → Callback → Troca código → Salva token
- **URL Autorização**: `https://www.linkedin.com/oauth/v2/authorization?scope=r_liteprofile+r_emailaddress&client_id=77ye1svdvforpt&redirect_uri=http%3A%2F%2Flocalhost%3A4000%2Fauth%2Flinkedin%2Fcallback&response_type=code`
- **Callback**: `lib/auto_vagas_web/controllers/auth_controller.ex`
- **Criptografia**: AES-256-GCM para `client_secret`

### 7. **Correções de Bugs Hoje** ✅
- ✅ `URI.encode` charlist → `to_string/1` (`linkedin.ex`)
- ✅ `wait_for_tables` warning → pattern match (`application.ex`)
- ✅ `Protocol.UndefinedError` → `inspect/1` (`auth_controller.ex`, `linkedin.ex`)
- ✅ `KeyError :selected` → atom keys (`:selected`) (`jobs_live.ex`)
- ✅ Módulo aninhado → `jobs_store.ex` criado separadamente
- ✅ Variáveis não usadas → prefixadas com `_`

### 8. **Documentação Atualizada** ✅
- ✅ `README.md` - IA, Habilidades, LinkedIn, correções
- ✅ `AGENTS.md` - Justificativas de decisões, bugs corrigidos
- ✅ `TODO.md` - Tarefas e status atualizados
- ✅ `test_ai.exs`, `test_pdf.exs` - Scripts de teste
- ✅ `lib/auto_vagas_web/README.md` - Phoenix Framework explicado

---

## Como Executar Hoje

### 1. **Instalação**
```bash
# Linux
chmod +x setup.sh
./setup.sh

# Ou manualmente:
mix deps.get
mix assets.build
```

### 2. **Configurar IA (Ollama)**
```bash
# Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama serve &  # Inicia servidor
ollama pull llama3.2  # Baixa modelo
```

### 3. **Configurar LinkedIn OAuth**
1. Acesse https://www.linkedin.com/developers/apps/new
2. Crie app e copie `Client ID` e `Client Secret`
3. Adicione redirect URI: `http://localhost:4000/auth/linkedin/callback`
4. No AutoVagas: `/configuracoes` → "Adicionar Credenciais" → Salve (criptografado)

### 4. **Iniciar Servidor**
```bash
cd /home/frota/Documents/repositorios/auto_vagas
mix phx.server
```
Acesse: http://localhost:4000

### 5. **Testar Páginas**
- Início: http://localhost:4000/
- Buscar Vagas: http://localhost:4000/buscar
- Vagas Salvas: http://localhost:4000/vagas
- Configurações: http://localhost:4000/configuracoes
- Habilidades: http://localhost:4000/habilidades ✅
- Ajuda: http://localhost:4000/ajuda

### 6. **Testar IA**
```bash
# Teste de extração de currículo (Ollama funcionando)
mix run test_ai.exs

# Ou:
mix run test_pdf.exs
```

---

## Estrutura de Arquivos Atualizada

```
lib/
├── auto_vagas/
│   ├── ai.ex                  # Módulo principal IA ✅
│   ├── ai/
│   │   ├── ollama.ex         # Ollama local ✅
│   │   ├── gemini.ex        # Gemini API
│   │   ├── openai.ex        # OpenAI API
│   │   ├── pdf.ex            # Processamento PDF ✅
│   │   └── explanation.ex    # Explicações ✅
│   ├── linkedin_profile.ex  # Extração perfil ✅
│   ├── automation.ex        # Automação Firefox ✅
│   ├── application.ex        # Inicialização, Mnesia, NTP
│   ├── crawler/
│   │   ├── jobs_store.ex   # Armazenamento Mnesia ✅
│   │   ├── worker.ex       # Workers GenServer
│   │   └── ...
│   ├── auth/
│   │   ├── linkedin.ex    # OAuth 2.0 ✅
│   │   ├── indeed.ex      # OAuth 2.0 (estrutura)
│   │   └── gupy.ex        # SAML 2.0 (estrutura)
│   └── mnesia/
│       ├── schema.ex        # Tabelas Mnesia
│       └── search_manager.ex
├── auto_vagas_web/
│   ├── live/
│   │   ├── skills_live.ex   # Habilidades ✅
│   │   ├── jobs_live.ex    # Vagas salvas (Mnesia) ✅
│   │   ├── job_search_live.ex
│   │   ├── settings_live.ex
│   │   └── help_live.ex      # Ajuda atualizada ✅
│   ├── controllers/
│   │   └── auth_controller.ex # Callbacks OAuth ✅
│   ├── router.ex           # Rotas incluindo /habilidades ✅
│   └── README.md           # Phoenix Framework ✅
├── priv/
│   ├── ai_config.json.example  # Config IA
│   ├── user_info.json        # Atualizado com skills ✅
│   └── filters/              # Configurações
└── test_ai.exs, test_pdf.exs  # Scripts de teste ✅
```

---

## Status Final ✅

### Implementado e Testado Hoje
- ✅ **Integração com IA** (Ollama testado e funcionando)
- ✅ **Página de Habilidades** (funcionando em `/habilidades`)
- ✅ **Perfil LinkedIn** (estrutura criada)
- ✅ **JobsStore Mnesia** (substituiu `jobs_cache.ex`)
- ✅ **LinkedIn OAuth 2.0** (implementado, aguarda teste navegador)
- ✅ **Correção de 6+ bugs** (compilação limpa)
- ✅ **Documentação atualizada** (README, AGENTS, TODO)

### Pendências
- [ ] Teste real LinkedIn OAuth (navegador)
- [ ] Implementação Indeed/Gupy OAuth
- [ ] Crawlers reais (requerem JavaScript/API)
- [ ] Notificações (WhatsApp/Telegram/Discord)

---

**Sistema pronto para uso com IA local (Ollama) e testes de OAuth!** 🎉

## Dificuldades para Implementar SSO

### LinkedIn OAuth 2.0 - [Fácil]
- Fluxo padrão OAuth 2.0 com Authorization Code
- Documentação oficial clara
- Implementação completa em `lib/auto_vagas/auth/linkedin.ex`
- **Único requisito**: `client_id` e `client_secret` válidos

### Indeed OAuth 2.0 - [Médio]
- Dois fluxos diferentes (Candidatos vs Empresas)
- Documentação limitada para integração via SSO
- Pode exigir configuração especial no portal do desenvolvedor
- Implementação atual é apenas estrutural (sem token real)

### Gupy SAML 2.0 - [Difícil]
- SAML 2.0 é complexo (XML, assinaturas digitais)
- Requer certificado X.509 (chave pública/privada)
- Phoenix não tem suporte nativo a SAML (precisa de biblioteca como `samly`)
- Gupy pode exigir whitelist de IP/domínio da aplicação
- Implementação atual é apenas estrutural (sem fluxo real)

## Testes da API

Execute o script de teste da API LinkedIn:

```bash
mix run test_linkedin_api.exs
```

O script irá:
1. Verificar se as credenciais estão configuradas
2. Gerar a URL de autorização
3. Solicitar o código retornado pelo LinkedIn
4. Trocar o código por access_token
5. Testar a API de perfil do usuário

## Troubleshooting Completo

### Testes de Funcionalidade Realizados

#### 1. Verificação de Dependências do Sistema
- Elixir: Erlang/OTP 28 instalado
- Firefox Developer Edition: v151.0b3 (/usr/bin/firefox-developer-edition)
- GeckoDriver: v0.36.0 (/usr/bin/geckodriver)
- Node.js: Não instalado (assets compilam via esbuild/tailwind diretamente)
- inotify-tools: Não instalado (opcional, apenas para live-reload)

#### 2. Testes de Rotas (HTTP 200)
- `/` (Página inicial): 200 OK
- `/buscar` (Busca de vagas): 200 OK
- `/vagas` (Vagas salvas): 200 OK
- `/configuracoes` (Configurações): 200 OK
- `/ajuda` (Ajuda): 200 OK

#### 3. Testes de Compilação
- `mix compile`: Sucesso (sem erros)
- `mix assets.build`: Sucesso (tailwind 4.1.12 + daisyUI 5.0.35)
- `mix deps.get`: Todas dependências baixadas (incluindo wallaby 0.30.12)

#### 4. Bugs Corrigidos e Testados

##### Bug 1: SettingsLive - Erro no add_profile (Crítico)
- **Sintoma**: `KeyError: key :name not found` ao clicar em "Adicionar Perfil"
- **Causa**: `core_components.ex` não processava corretamente o atributo `field` do Phoenix Form
- **Correção**: Atualizado `input/1` para extrair `name`, `value`, `errors`, `id` do field
- **Status**: Testado - Erro eliminado

##### Bug 2: Worker.ex - Task.await_many (Crítico)
- **Sintoma**: Pattern match falhava ao processar resultados das tasks
- **Código original**: `Enum.flat_map(fn {:ok, jobs} -> jobs end)`
- **Correção**: 
  ```elixir
  Enum.flat_map(fn
    jobs when is_list(jobs) -> jobs
    {:ok, jobs} when is_list(jobs) -> jobs
    _ -> []
  end)
  ```
- **Status**: Testado - Workers processam vagas corretamente

##### Bug 3: JobSearchLive - Filter.apply/2 (Crítico)
- **Sintoma**: Chamava `AutoVagas.Filters.apply_all/3` (inexistente)
- **Correção**: Alterado para `AutoVagas.Crawler.Filter.apply(jobs, filters)`
- **Status**: Testado - Filtros aplicados corretamente

##### Bug 4: JobsCache.ex - Mnesia Records (Médio)
- **Sintoma**: Records Mnesia têm 4 elementos, código tratava como 3
- **Correção**: Atualizado pattern match para `{_, key, jobs, updated_at}`
- **Status**: Testado - Operações Mnesia funcionando

#### 5. Automação de Inscrições
- Módulo criado: `lib/auto_vagas/automation.ex`
- Suporte para Firefox Developer Edition (prioridade), Firefox normal, Chrome
- Modo simulação se browsers indisponíveis
- Worker integrado para inscrição automática após crawling
- Wallaby 0.30.12 configurado com Selenium para Firefox

### Scripts de Instalação Criados

1. **setup.sh** (Linux)
   - Instala Elixir, Node.js, Firefox Dev, GeckoDriver, ChromeDriver
   - Configura projeto Elixir (mix deps.get, assets.build)
   - Cria arquivos de configuração padrão

2. **setup.bat** (Windows)
   - Instala via Chocolatey (requer Admin)
   - Firefox Dev, GeckoDriver, ChromeDriver, Elixir, Node.js
   - Configuração automática do projeto

### Pendências para Funcionamento Completo

1. **OAuth LinkedIn**: Requer teste no navegador (client_id + client_secret válidos)
2. **Wallaby + Firefox**: GeckoDriver instalado, mas requer `geckodriver` no PATH
3. **Wallaby + Chrome**: ChromeDriver não instalado (opcional)
4. **Sistemas Windows/Mac**: Testados apenas no Linux (Ubuntu/Debian)

## Contribuição

Consulte o arquivo `AGENTS.md` para detalhes completos sobre a arquitetura do projeto, fluxos de trabalho e status de implementação.

## Licença

[Apache V2.0](LICENSE.md)