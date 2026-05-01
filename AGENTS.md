# AutoVagas - Guia para Agentes

## Visao Geral
Sistema Elixir/Phoenix + BEAM para automatizacao de busca e inscricao de vagas.
- Busca: APIs LinkedIn (RapidAPI/Rockapis/JSearch/Guest) -> Mnesia -> LiveView
- Inscricao: Crawler -> IA (Ollama/OpenAI/Gemini) -> preenchimento via `user_info.json`

## Comandos Essenciais
- `mix setup` — Instala deps + configura Mnesia
- `mix phx.server` — Servidor na porta 4000
- `mix clean && mix deps.get && mix compile` — Rebuild completo
- `nohup mix phx.server &` — Resiste a SIGTERM

## Arquitetura Importante
### Backend
- **Banco**: Mnesia (nativo Erlang/OTP, **nao** Ecto/PostgreSQL)
  - Tabelas: `:jobs_cache_*` (uma por worker), `:searches`, `:jobs`, `:notifications`, `:user_sessions`, `:filters`
  - `:mnesia.start()` antes de operacoes (feito em `application.ex`)
- **HTTP**: Req (**nao** HTTPoison/Tesla)
- **Parsing**: Floki
- **Crawling Paralelo**: DynamicSupervisor + GenServer workers
- **Criptografia**: AES-256-GCM para credenciais em `priv/filters/auth_config.json`
- **Experiencia Dinamica**: `lib/auto_vagas/profiles/experience.ex` - calcula anos via `initial_year`

### Frontend
- **Framework**: Phoenix LiveView + Tailwind + daisyUI (**sem** React/Vue)
- **I18n**: `AutoVagasWeb.I18n` para PT/EN/ES (detecta via browser)

### SSO / Autenticacao
- **Wallaby**: Requer Chrome/Chromium, Firefox **nao** funciona
- **Auth Callbacks**: `lib/auto_vagas_web/auth/[provider]/callback.ex` (linkedin, indeed, gupy)
- **LinkedIn**: OpenID Connect com scopes `openid profile email`, redirect via ngrok
- **Indeed**: OAuth 2.0, redirect configuravel via `INDEED_REDIRECT_URI`
- **Gupy**: SAML 2.0 para autenticacao corporativa
- **Firefox Developer Edition**: Configurado no Wallaby (`/usr/bin/firefox-developer-edition`)
- **Integracao**: Ao clicar em "Conectar", o sistema abre no Firefox DE via Wallaby

## Quirks do Framework
### Phoenix LiveView
- **CoreComponents.input**: **Nao** suporta `type="radio"` - use `<input type="radio">` nativo
- **Formularios**: `to_form/1,2` e `<.input>` do core_components.ex
- **Uploads**: `allow_upload` com `phx-drop` e `phx-upload`
- **LiveView mounts**: Dados carregados no `mount/3`

### Mnesia
- `:mnesia.transaction` para ACID
- `:mnesia.wait_for_tables/2` apos criar tabelas
- JobsCache: tabelas dinamicas `:jobs_cache_0`, `:jobs_cache_1`, etc.

### LinkedIn OAuth (Configuracao Atual)
- **App exemplo**: Client ID `77k7gf05ngamtq`
- **Redirect valido**: `https://animating-outdated-antitoxic.ngrok-free.dev/auth/linkedin/callback` (localhost inacessivel)
- **Scopes**: `openid`, `profile`, `email` (OpenID Connect)
- **Codigo atual**: `lib/auto_vagas/auth/linkedin.ex` usa scopes legados e redirect localhost — atualizar

## Gotchas Importantes
1. **Mnesia** precisa `:mnesia.start()` antes de operacoes
2. **URI.encode** precisa `to_string()` para charlists
3. **JobsLive** converte chaves string para atomos no `mount/3`
4. **NTP** usa UDP porta 123
5. **Compilacao** usa `--warnings-as-errors` no `mix.exs` (desative para debug)
6. **Wallaby** requer Chrome/Chromium instalado
