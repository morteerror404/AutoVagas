# Crawler - AutoVagas

Módulos para busca automatizada de vagas em múltiplas plataformas.

## Arquivos Principais

- **adapter.ex**: Behavior e utilitários para adaptadores de plataformas.
  - `crawl/2`: Callback para executar crawling
  - `config/0`: Callback para configuração
  - `build_url/1-5`: Callback para construir URL
  - `build_urls/2-3`: Callback para múltiplas URLs
  - `parse/1`: Callback para processar HTML

- **engine.ex**: Engine central de crawling ⭐ ATUALIZADO.
  - `run/2`: Executa crawling usando adaptador específico
  - `fetch_jobs/5`: Orquestrador com fallback para LinkedIn (RapidAPI → Guest API → Scraping)
  - Usa Req para requisições HTTP
  - Trata erros de rede

- **jobs_store.ex**: Armazenamento de vagas no Mnesia ⭐ NOVO.
  - `save/1`: Salva lista de vagas
  - `load/0`: Carrega todas as vagas
  - `clear/0`: Limpa todas as vagas
  - Usa `:mnesia.transaction` para ACID

- **worker.ex**: Workers GenServer para buscas simultâneas.
  - Cada busca tem um Worker independente
  - `start_link/1`: Inicia worker com search_id
  - `run_crawl/1`: Inicia crawling assíncrono
  - Executa crawling, salva vagas, notifica

- **worker_supervisor.ex**: Supervisor dinâmico para workers.
  - `start_worker/1`: Inicia novo worker dinamicamente
  - `terminate_worker/1`: Encerra worker

- **filter.ex**: Módulo de filtros e regras de exclusão.
  - `list_filters/0`: Lista todos os filtros
  - `get_filter/1`: Carrega filtro por nome
  - `save_filter/2`: Salva filtro
  - `delete_filter/1`: Exclui filtro
  - `apply/2`: Aplica filtros global ou por fonte
  - `reject_by_words/2`: Exclui por palavras
  - `require_include_words/2`: Exige palavras inclusas
  - `reject_by_experience/2`: Filtra por experiência
  - `reject_by_remote/2`: Filtra vagas remotas
  - `require_keywords_match/2`: Exige correspondência de palavras-chave

- **geolocation.ex**: Cálculo de distâncias entre localizações.
  - `calculate_distance/2`: Distância entre duas coordenadas
  - `is_within_radius?/3`: Verifica se está dentro do raio

## Adaptadores de Plataformas (`sites/`)

| Arquivo | Plataforma | Status |
|--------|------------|--------|
| `linkedin.ex` | LinkedIn | ✅ Implementado (3 métodos) ⭐ |
| `indeed.ex` | Indeed | ✅ Estrutura + fetch_jobs/4 |
| `gupy.ex` | Gupy | ✅ Estrutura + API client |

### LinkedIn Adapter ⭐ NOVO
Implementa 3 métodos de busca com fallback:
1. **RapidAPI** (`fetch_via_rapidapi/3`): Método primário via RapidAPI
2. **Guest API** (`fetch_via_guest_api/3`): Fallback não autenticado
3. **Scraping** (`fetch_via_scraping/3`): Última instância

Função orquestradora: `fetch_jobs/5` - tenta métodos em ordem até sucesso.

## Funcionamento

1. **Busca**: Usuário informa palavras-chave, localização, filtros
2. **Engine**: Para cada fonte, constrói URLs e faz requisição HTTP
3. **Adaptador**: Faz parse do HTML e extrai dados das vagas
4. **Filtros**: Aplica filtros globais e por fonte
5. **Workers**: Cada busca executa em worker independente (paralelo)
6. **Mnesia**: Armazena buscas e vagas para múltiplos workers

## Status

- ✅ LinkedIn: Implementado completamente (RapidAPI/Guest API/Scraping)
- ✅ Indeed: Estrutura + fetch_jobs/4
- ✅ Gupy: Estrutura + API client
- ✅ Workers: Múltiplas buscas simultâneas funcionando
- ✅ Filtros: Aplicação de filtros funcionando
- ✅ JobsStore: Migração para Mnesia completa (substituiu JSON)

## Arquivos de Configuração

- `priv/user_info.json`: Configurações do usuário (perfil, regras, buscas salvas)
- `priv/filters/global_filters.json`: Filtros globais
- `priv/filters/source_filters.json`: Filtros por fonte
- `priv/filters/auth_config.json`: Credenciais SSO e RapidAPI (criptografadas)
