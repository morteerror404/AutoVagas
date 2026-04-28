# AutoVagas

Sistema de busca automatizada de vagas de emprego construído com Phoenix Framework (Elixir). Permite buscar em múltiplas plataformas simultaneamente com filtros avançados e notificações via WhatsApp, Telegram e Discord.

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

## Rotas Principais

| Rota | Descrição |
|------|-----------|
| `/` | Página inicial |
| `/buscar` | Busca de vagas com filtros |
| `/vagas` | Visualização de vagas salvas |
| `/configuracoes` | Configurações (autenticação, notificações, filtros) |
| `/ajuda` | Instruções para configurar integrações SSO |

## Status de Implementação

### ✅ Funcionando

- [x] Estrutura base com Mnesia (banco de dados distribuído)
- [x] Cálculo de experiência com NTP
- [x] Múltiplas buscas simultâneas (DynamicSupervisor + GenServer)
- [x] Filtros de busca (interface e lógica em `lib/auto_vagas/filters.ex`)
- [x] Rotas LiveView: `/buscar`, `/vagas`, `/configuracoes`
- [x] UI de SSO na página de configuração com indicadores visuais (● ativo, ○ inativo)
- [x] Botão "Adicionar Credenciais" para LinkedIn com modal
- [x] Criptografia AES-256 para Client Secret (`lib/auto_vagas/crypto.ex`)
- [x] Página de ajuda (`/ajuda`) com links para documentação oficial
- [x] Radio buttons nas notificações (apenas um canal ativo por vez)
- [x] Correção de bugs: `add_profile`, `JobSearchLive.flat_map`, `linkedin.ex` (encode_query)

### 🔄 Em Progresso

- [ ] Troca de código por access_token (LinkedIn OAuth) - **Requer teste no navegador** (Observação, estou flertando com o Chromium)
- [ ] Teste completo da API LinkedIn (perfil, busca de vagas)

### ⏳ Pendente

- [ ] Processamento de mensagens para preenchimento automático (WhatsApp/Telegram)
- [ ] Migração completa de JobsCache para Mnesia
- [ ] Implementação completa do fluxo Indeed OAuth 2.0
- [ ] Implementação completa do fluxo Gupy SAML 2.0 (requer biblioteca `samly`)
- [ ] Configuração de canais de notificação (WhatsApp Business API, Telegram Bot, Discord Webhook)
- [ ] Deploy em produção (HTTPS obrigatório para LinkedIn OAuth)
- [ ] Crawler de vagas direto no google
- [ ] Crawler de grupos de vagas (Telegram, WhatsApp e Discord).

## Como Executar

```bash
# Instalar dependências e configurar banco
mix setup

# Iniciar servidor Phoenix (porta 4000)
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

## Contribuição

Consulte o arquivo `AGENTS.md` para detalhes completos sobre a arquitetura do projeto, fluxos de trabalho e status de implementação.

## Licença

[Apache V2.0](LICENSE.md)