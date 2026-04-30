# Guia de Uso da IA - AutoVagas

## Visão Geral

O AutoVagas usa IA para:
- **Geração de explicações** para habilidades, certificações e cursos
- **Análise de currículos** via PDF
- **Busca inteligente** de vagas (via RapidAPI)

## Módulos de IA Disponíveis

### 1. AutoVagas.AI (Módulo Central)
Localização: `lib/auto_vagas/ai/ai.ex`

**Funcionalidades:**
- `analyze_resume/2` - Analisa texto de currículo
- Suporte a múltiplas tarefas: `explain_skill`, `explain_certification`, etc.

**Configuração:**
```elixir
# O arquivo usa Req para chamadas HTTP
# Configure sua API key em priv/filters/auth_config.json:
{
  "openai": {
    "api_key": "sk-..."
  },
  "gemini": {
    "api_key": "..."
  }
}
```

### 2. AutoVagas.AI.Explanation
Localização: `lib/auto_vagas/ai/explanation.ex`

**O que faz:**
- Atualiza habilidades técnicas com explicações da IA
- Gera explicações para:
  - Habilidades técnicas (`technical`)
  - Habilidades comportamentais (`soft`)
  - Certificações (`certifications`)
  - Cursos (`courses`)
  - Desafios Hack The Box (`hack_the_box`)

**Uso no LiveView (SkillsLive):**
```elixir
# Botão "Atualizar c/ IA" chama:
handle_event("update_skills", _params, socket) do
  user_info = load_user_info()
  
  case AutoVagas.AI.Explanation.update_skills_with_explanations(user_info) do
    {:ok, updated} ->
      save_user_info(updated)
      {:noreply, put_flash(socket, :info, "Habilidades atualizadas!")}
    error ->
      {:noreply, put_flash(socket, :error, "Erro: #{inspect(error)}")}
  end
end
```

### 3. Integração com RapidAPI (Busca de Vagas)
Localização: `lib/auto_vagas/sites/linkedin.ex`

**Configuração da API Key:**
1. Obtenha sua chave em: https://rapidapi.com/fantastic-jobs-fantastic-jobs-default/api/linkedin-job-search-api
2. Salve em `SettingsLive` → "Integrações" → "RapidAPI - LinkedIn Jobs"

**Como funciona:**
1. RapidAPI (principal) → 2. Guest API (fallback) → 3. Scraping (última opção)

## Formatos Suportados

### Requisição para IA (OpenAI/Gemini):
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "user",
      "content": "Explique a habilidade: Elixir..."
    }
  ]
}
```

### Resposta esperada:
```
Elixir é uma linguagem funcional... (2-3 frases)
```

## Configurando no Front-End

### Página de Habilidades (`/habilidades`)
1. Clique em **"Atualizar c/ IA"**
2. A IA analisará:
   - Suas habilidades técnicas
   - Certificações
   - Cursos
   - Desafios Hack The Box
3. As explicações aparecerão abaixo de cada item

### Página de Vagas (`/vagas`)
1. Preencha o formulário de busca:
   - Palavras-chave: "elixir developer"
   - Localização: "Brazil"
2. Clique em **"Buscar Vagas"**
3. A busca usará:
   - RapidAPI (se configurada)
   - Guest API (fallback gratuito)
   - Scraping (se necessário)

## Estrutura de Arquivos

```
lib/auto_vagas/ai/
├── ai.ex                 # Módulo central
├── explanation.ex        # Geração de explicações
├── openai.ex            # Integração OpenAI
├── gemini.ex            # Integração Google Gemini
├── ollama.ex            # Integração Ollama (local)
└── IA_USAGE.md          # Este arquivo
```

## Solução de Problemas

### Erro: "AI service not configured"
- Verifique se a API key está em `priv/filters/auth_config.json`
- Use: `SettingsLive` → "Integrações" → Configurar

### Erro: "RapidAPI key invalid"
- Verifique se copiou a chave completa
- Teste em: https://rapidapi.com/fantastic-jobs-fantastic-jobs-default/api/linkedin-job-search-api/playground

### IA não gera explicações
- Verifique logs: `mix phx.server`
- Teste manual: `mix run test_ai.exs`
