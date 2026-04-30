# Phoenix Framework - Documentação para AutoVagas

## O que é o Phoenix Framework?

O **Phoenix** é um framework web moderno para a linguagem **Elixir**, construído sobre o **Erlang/OTP**. Ele segue os princípios de arquitetura **MVC** (Model-View-Controller) e foi projetado para alta produtividade, manutenibilidade e performance.

### Características Principais

1. **Elixir/Erlang/OTP**: Aproveita a VM do Erlang (BEAM) para concorrência massiva e tolerância a falhas
2. **Channels**: Comunicação bidirecional via WebSockets
3. **LiveView**: Renderização server-side com atualizações reativas em tempo real (sem JavaScript complexo)
4. **Ecto**: Biblioteca de acesso a dados (opcional, substituído por Mnesia neste projeto)
5. **PubSub**: Sistema de publicação/assinatura nativo

---

## Por que o Phoenix foi escolhido para o AutoVagas?

### 1. **LiveView para Interface Reativa**
O AutoVagas usa **Phoenix LiveView** para:
- Atualizações em tempo real sem escrever JavaScript complexo
- Menos context switching (back-end e front-end em Elixir/HEEx)
- Componentes interativos (busca, filtros, configurações) com estado mantido no servidor
- Integração nativa com WebSockets para notificações

### 2. **Concorrência e Paralelismo**
- Cada busca de vagas roda em um **GenServer Worker** (processo leve Erlang)
- Múltiplas buscas simultâneas sem bloquear a interface
- Supervisão de processos: se uma busca falha, as outras continuam

### 3. **Mnesia em vez de Ecto/SQL**
O Phoenix suporta Ecto (SQL/NoSQL), mas o AutoVagas usa **Mnesia**:
- Banco de dados nativo Erlang/OTP (sem processo externo)
- Persistência com `disc_copies`
- Ideal para estado local rápido e operações distribuídas

### 4. **Arquitetura de Supervision**
- **DynamicSupervisor** gerencia workers de crawling dinamicamente
- Falhas em uma busca não derrubam o sistema
- Reinicio automático de processos com políticas de supervisão

---

## Particularidades do Phoenix na Implementação

### 1. **LiveView e HEEx (HTML Elixir)**
Templates `.heex` permitem embutir código Elixir diretamente no HTML:
```heex
<div :for={job <- @jobs}>
  <h3>{job.title}</h3>
  <p>{job.company}</p>
</div>
```

### 2. **Gerenciamento de Estado**
- `mount/3`: Inicializa estado quando o LiveView é carregado
- `handle_event/3`: Trata eventos do usuário (cliques, formulários)
- `handle_info/3`: Trata mensagens assíncronas (PubSub, GenServer)

### 3. **PubSub para Comunicação Inter-Type**
```elixir
# Worker envia mensagem
Phoenix.PubSub.broadcast(AutoVagas.PubSub, "jobs:1", {:new_jobs, jobs})

# LiveView inscreve-se
Phoenix.PubSub.subscribe(AutoVagas.PubSub, "jobs:1")
def handle_info({:new_jobs, jobs}, socket) do
  {:noreply, assign(socket, jobs: jobs)}
end
```

### 4. **Formulários com `to_form/1,2`**
O Phoenix 1.8+ usa `to_form/1,2` em vez de `form_for`:
```elixir
form = to_form(%{"q" => ""})
# No template:
<.form for={@form} phx-change="search">
  <input type="text" name="q" value={@form[:q].value} />
</.form>
```

### 5. **CoreComponents**
O Phoenix gera `core_components.ex` com componentes padrão:
- `<.input>` para campos de formulário (text, checkbox, radio, select)
- `<.button>` para botões estilizados
- `<.modal>` para modais

### 6. **Tailwind CSS + daisyUI**
O Phoenix integra facilmente com Tailwind:
- `assets/css/app.css` importa Tailwind
- `assets/js/app.js` inicializa LiveSocket com hooks
- daisyUI oferece componentes prontos (cards, buttons, modais)

---

## Estrutura de Pastas no Phoenix

```
lib/
├── auto_vagas/           # Lógica de negócio (contextos)
│   ├── application.ex    # Inicialização da aplicação OTP
│   ├── crawler/          # Módulos específicos (não é contexto padrão)
│   └── ai/               # Integração com IA (Ollama, Gemini)
├── auto_vagas_web/       # Camada web
│   ├── live/            # LiveViews (.ex + .heex)
│   ├── controllers/      # Controllers (.ex)
│   ├── router.ex        # Definição de rotas
│   └── endpoint.ex      # Configuração HTTP/HTTPS
└── auto_vagas_web.ex    # Definições de view (.heex helpers)

priv/
├── static/              # Arquivos estáticos (CSS, JS, imagens)
├── filters/             # Configurações JSON
└── user_info.json       # Dados do usuário

assets/
├── js/app.js            # Entry point JavaScript
└── css/app.css          # Estilos customizados
```

---

## Funcionalidades do Phoenix usadas no AutoVagas

### 1. **LiveView para Páginas Interativas**
- `/buscar`: Formulário de busca com filtros em tempo real
- `/vagas`: Automação de vagas - regras e buscas salvas ⭐ NOVO
- `/configuracoes`: Configurações SSO, notificações, filtros, RapidAPI ⭐ ATUALIZADO
- `/perfil`: Perfil do usuário (LinkedIn)
- `/habilidades`: Habilidades com explicações de IA
- `/ajuda`: Página com documentação SSO

### 2. **Controllers para Callbacks OAuth**
```elixir
# router.ex
get "/auth/linkedin/callback", AuthController, :linkedin_callback

# Live routes
live "/", HomeLive
live "/buscar", JobSearchLive
live "/vagas", JobsLive  # Automação ⭐
live "/configuracoes", SettingsLive
live "/perfil", UserProfileLive
live "/habilidades", SkillsLive
live "/ajuda", HelpLive
```

### 3. **PubSub para Notificações**
```elixir
# Worker notifica novo job
Phoenix.PubSub.broadcast(AutoVagas.PubSub, "jobs:search_id", {:new_jobs, job})

# JobsLive recebe e atualiza interface
def handle_info({:new_jobs, jobs}, socket) do
  {:noreply, assign(socket, jobs: jobs)}
end
```

### 4. **Configuration via `config/`**
- `config/config.exs`: Configuração base (Endpoint, PubSub, etc.)
- `config/dev.exs`: Desenvolvimento (live-reload, debug)
- `config/prod.exs`: Produção (HTTPS, secret_key_base)

---

## Particularidades de Desenvolvimento

### 1. **Compilação Rápida**
```bash
mix compile  # Compila apenas o que mudou
mix phx.server  # Inicia servidor com live-reload (se inotify-tools instalado)
```

### 2. **REPL Interativo (iex)**
```bash
iex -S mix phx.server  # Servidor + console interativo
# No iex:
AutoVagas.AI.analyze_resume("meu currículo...") |> IO.inspect()
```

### 3. **Testes com ExUnit**
```bash
mix test  # Executa todos os testes
mix test test/auto_vagas/ai_test.exs  # Teste específico
```

### 4. **Assets com esbuild + Tailwind**
```bash
mix assets.build  # Compila JS/CSS
mix assets.deploy  # Prepara para produção
```

---

## Por que NÃO usamos React/Vue/Angular?

1. **Menos context switching**: Back-end e front-end em Elixir
2. **Estado centralizado**: No servidor, não precisa sincronizar cliente/servidor
3. **Tempo real nativo**: LiveView já faz WebSockets automaticamente
4. **Menos código**: Sem duplicação de lógica de validação/formulário
5. **Performance**: Menos JavaScript para baixar no cliente

---

## Dependências do Phoenix no mix.exs

```elixir
defp deps do
  [
    {:phoenix, "~> 1.8.5"},
    {:phoenix_live_view, "~> 1.1.0"},
    {:phoenix_html, "~> 4.1"},
    {:phoenix_live_reload, "~> 1.2", only: :dev},
    {:jason, "~> 1.2"},  # JSON
    {:req, "~> 0.5"},     # HTTP client
    {:floki, "~> 0.36"},  # HTML parser
    {:wallaby, "~> 0.30"}  # Testes E2E com Selenium
  ]
end
```

---

## Recursos Oficiais

- **Site**: https://www.phoenixframework.org/
- **Documentação**: https://hexdocs.pm/phoenix/
- **LiveView**: https://hexdocs.pm/phoenix_live_view/
- **Guides**: https://phoenixframework.readme.io/
- **Exemplos**: https://github.com/phoenixframework/

---

## Resumo para o AutoVagas

O Phoenix Framework foi escolhido por:
1. **LiveView** para interface reativa sem JavaScript complexo
2. **Concorrência Erlang** para múltiplas buscas simultâneas
3. **Supervisão OTP** para tolerância a falhas
4. **Mnesia** integrado (sem Ecto/SQL externo)
5. **Desenvolvimento rápido** com live-reload e HEEx
6. **Tempo real** nativo via PubSub/WebSockets

O resultado é uma aplicação web robusta, concorrente e fácil de manter, ideal para busca e automação de vagas.
