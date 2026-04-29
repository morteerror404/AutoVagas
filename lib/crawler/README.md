# Crawler - AutoVagas

Módulos para busca automatizada de vagas em múltiplas plataformas.

## Arquivos Principais

- **adapter.ex**: Behavior e utilitários para adaptadores de plataformas.
  - `crawl/2`: Callback para executar crawling
  - `config/0`: Callback para configuração
  - `build_url/1-5`: Callback para construir URL
  - `build_urls/2-3`: Callback para múltiplas URLs
  - `parse/1`: Callback para processar HTML

- **engine.ex**: Engine central de crawling.
  - `run/2`: Executa crawling usando adaptador específico
  - Usa Req para requisições HTTP
  - Trata erros de rede

- **worker.ex**: Workers GenServer para buscas simultâneas.
  - Cada busca tem um Worker independente
  - `start_link/1`: Inicia worker com search_id
  - `run_crawl/1`: Inicia crawling assíncrono
  - Executa crawling, salva vagas, notifica

- **worker_supervisor.ex**: Supervisor dinâmico para workers.
  - `start_worker/1`: Inicia novo worker dinamicamente
  - `terminate_worker/1`: Encerra worker

- **auth.ex**: Autenticação SSO via browser automation (simplificado).
  - `start_session/2`: Inicia sessão
  - `login/3`: Faz login
  - `authenticated?/1`: Verifica se sessão ativa
  - `end_session/1`: Encerra sessão
  - `get_cookies/1`: Obtém cookies

- **jobs_cache.ex**: Cache distribuído de vagas usando Mnesia.
  - GenServer que gerencia tabela Mnesia por worker
  - `put/2`: Armazena vagas
  - `get/1`: Busca vagas por chave
  - `cleanup/1`: Remove vagas antigas
  - `all_keys/0`: Lista todas as chaves
  - `size/0`: Tamanho do cache

- **filter.ex**: Módulo de filtros e regras de exclusão.
  - `list_filters/0`: Lista todos os filtros
  - `get_filter/1`: Carrega filtro por nome
  - `save_filter/2`: Salva filtro
  - `delete_filter/1`: Exclui filtro
  - `apply/2`: Aplica filtros global ou por fonte
  - `reject_by_words/2`: Exclui por palavras
  - `require_include_words/2`: Exige palavras inclusas
  - `reject_by_experience/2`: Filtra por experiência
  - `reject_by_applications/2`: Filtra por número de candidatos
  - `reject_by_remote/2`: Filtra vagas remotas
  - `require_keywords_match/2`: Exige correspondência de palavras-chave

- **geolocation.ex**: Cálculo de distâncias entre localizações.
  - `calculate_distance/2`: Distância entre duas coordenadas
  - `is_within_radius?/3`: Verifica se está dentro do raio

- **user_config.ex**: Gerenciamento de `priv/user_info.json`.
  - `load/0`: Carrega configurações do usuário
  - `save/1`: Salva configurações
  - `default_location/0`: Localização padrão
  - `default_filters/0`: Filtros padrão
  - `source_config/1`: Configuração por fonte

## Adaptadores de Plataformas (`sites/`)

| Arquivo | Plataforma | Status |
|--------|------------|--------|
| `linkedin.ex` | LinkedIn | ✅ Implementado |
| `indeed.ex` | Indeed | ✅ Implementado |
| `gupy.ex` | Gupy | ✅ Implementado |

### Estrutura de um Adaptador

```elixir
defmodule AutoVagas.Crawler.Sites.Exemplo do
  @behaviour AutoVagas.Crawler.Adapter
  
  @impl true
  def config do
    %{name: "Exemplo", base_url: "https://exemplo.com/jobs", requires_auth: false, rate_limit: 10}
  end
  
  @impl true
  def build_url(search_term, location \\ nil, time_posted \\ nil, work_type \\ nil, user_config \\ %{}) do
    # Constrói URL de busca
  end
  
  @impl true
  def build_urls(keywords, opts \\ [], user_config \\ %{}) do
    # Constrói múltiplas URLs para lista de palavras-chave
  end
  
  @impl true
  def parse(html) do
    # Faz parse do HTML e retorna lista de vagas
    [
      %{
        title: "Vaga Exemplo",
        company: "Empresa",
        location: "Remoto",
        url: "https://exemplo.com/job/123",
        external_id: "123",
        source: "exemplo"
      }
    ]
  end
end
```

## Funcionamento

1. **Busca**: Usuário informa palavras-chave, localização, filtros
2. **Engine**: Para cada fonte, constrói URLs e faz requisição HTTP
3. **Adaptador**: Faz parse do HTML e extrai dados das vagas
4. **Filtros**: Aplica filtros globais e por fonte
5. **Workers**: Cada busca executa em worker independente (paralelo)
6. **Mnesia**: Armazena buscas e vagas para múltiplos workers

## Status

- ✅ LinkedIn: Implementado completamente (crawling via API/web)
- ✅ Indeed: Implementado (estrutura web)
- ✅ Gupy: Implementado (estrutura web)
- ✅ Workers: Múltiplas buscas simultâneas funcionando
- ✅ Filtros: Aplicação de filtros funcionando
- 🔄 JobsCache: Migração para Mnesia pendente (usando arquivo JSON atualmente)

## Arquivos de Configuração

- `priv/user_info.json`: Configurações do usuário
- `priv/filters/global_filters.json`: Filtros globais
- `priv/filters/source_filters.json`: Filtros por fonte
- `priv/filters/auth_config.json`: Credenciais SSO (criptografadas)
