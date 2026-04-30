# AutoVagas - Guia Compacto para Agentes

## Comandos Essenciais
- `mix setup` - Instala deps + configura Mnesia (Linux: `setup.sh`, Windows: `setup.bat`)
- `mix phx.server` - Servidor na porta 4000
- `mix clean && mix deps.get && mix compile` - Rebuild completo
- `mix run test_linkedin_api.exs` - Teste manual API LinkedIn
- Use `nohup mix phx.server &` para resistir a SIGTERM

## Arquitetura (Não-Óbvia)
- **Banco**: Mnesia (nativo Erlang/OTP, não Ecto/PostgreSQL). Configurado como `:extra_applications` no mix.exs
- **Frontend**: Phoenix LiveView + Tailwind + daisyUI (sem React/Vue)
- **HTTP**: Req (não HTTPoison/Tesla)
- **Parsing**: Floki
- **Crawling**: DynamicSupervisor + GenServer workers (paralelismo isolado)
- **Automação**: Wallaby + Selenium + Firefox Developer Edition (**não** Firefox normal ou Chrome)
- **Criptografia**: AES-256-GCM para credenciais em `priv/filters/auth_config.json`

## Quirks do Framework
- **LinkedIn OAuth**: Exige HTTPS em produção; localhost funciona para testes
- **CoreComponents.input**: **Não** suporta `type="radio"` - use `<input type="radio">` nativo
- **Crawlers estáticos quebrados**: LinkedIn/Indeed carregam via JavaScript - precisam API ou Selenium
- **Mnesia tables**: `:searches`, `:jobs`, `:notifications`, `:user_sessions` (disc_copies)

## Estrutura (Entrypoints)
- `lib/auto_vagas/application.ex` - Start, Mnesia, NTP
- `lib/auto_vagas_web/router.ex` - Rotas: `/buscar`, `/vagas`, `/configuracoes`, `/ajuda`, `/habilidades`
- `lib/auto_vagas_web/live/` - Todos os LiveViews
- `lib/crawler/` - Lógica de crawling
- `lib/auto_vagas/sites/` - Adapters (linkedin.ex, indeed.ex, gupy.ex)
- `priv/user_info.json` - Config principal do usuário

## Gotchas
- JobsLive espera chaves átomos (`:title`, `:company`), não strings
- `URI.encode` no linkedin.ex precisa `to_string()` para charlists
- NTP usa UDP porta 123
- Formulários usam `to_form/1,2` e `<.input>` do core_components.ex
- Notificações usam Phoenix.PubSub para broadcast interno
