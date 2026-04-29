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

## Rotas Principais

| Rota | Descrição |
|------|-----------|
| `/` | Página inicial |
| `/buscar` | Busca de vagas com filtros |
| `/vagas` | Visualização de vagas salvas |
| `/configuracoes` | Configurações (autenticação, notificações, filtros) |
| `/ajuda` | Instruções para configurar integrações SSO |

## Status de Implementação

### Funcionando

- [x] Estrutura base com Mnesia (banco de dados distribuído)
- [x] Cálculo de experiência com NTP
- [x] Múltiplas buscas simultâneas (DynamicSupervisor + GenServer)
- [x] Filtros de busca (interface e lógica em `lib/auto_vagas/filter.ex`)
- [x] Rotas LiveView: `/buscar`, `/vagas`, `/configuracoes`
- [x] UI de SSO na página de configuração com indicadores visuais (ativo, inativo)
- [x] Botão "Adicionar Credenciais" para LinkedIn com modal
- [x] Criptografia AES-256 para Client Secret (`lib/auto_vagas/crypto.ex`)
- [x] Página de ajuda (`/ajuda`) com links para documentação oficial
- [x] Radio buttons nas notificações (apenas um canal ativo por vez)
- [x] Correção de bugs: `add_profile`, `JobSearchLive.flat_map`, `linkedin.ex` (encode_query)
- [x] Automação de inscrição via Firefox Developer Edition (`lib/auto_vagas/automation.ex`)
- [x] Wallaby + Selenium configurado para Firefox

### Em Progresso

- [ ] Troca de código por access_token (LinkedIn OAuth) - **Requer teste no navegador**
- [ ] Teste completo da API LinkedIn (perfil, busca de vagas)

### Pendente

- [ ] Processamento de mensagens para preenchimento automático (WhatsApp/Telegram)
- [ ] Migração completa de JobsCache para Mnesia
- [ ] Implementação completa do fluxo Indeed OAuth 2.0
- [ ] Implementação completa do fluxo Gupy SAML 2.0 (requer biblioteca `samly`)
- [ ] Configuração de canais de notificação (WhatsApp Business API, Telegram Bot, Discord Webhook)
- [ ] Deploy em produção (HTTPS obrigatório para LinkedIn OAuth)
- [ ] Crawler de vagas direto no Google
- [ ] Crawler de grupos de vagas (Telegram, WhatsApp e Discord).

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

## Dependências Principais

- Phoenix Framework 1.8.5
- Req (cliente HTTP)
- Floki (parser HTML)
- Jason (JSON)
- Mnesia (banco de dados distribuído)
- Phoenix LiveView 1.1.0

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