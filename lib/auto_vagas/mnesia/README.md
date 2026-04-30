# Mnesia - Banco de Dados Distribuído

Este diretório contém os módulos para gerenciamento do banco de dados Mnesia (nativo do Erlang/Elixir).

## Arquivos

- **schema.ex**: Gerencia o esquema Mnesia com todas as tabelas necessárias.
  - `init/0`: Inicializa Mnesia, cria esquema (se não existir)
  - `create_tables/0`: Cria tabelas: `:searches`, `:jobs`, `:notifications`, `:user_sessions`
  - `wait_for_tables/0`: Aguarda tabelas estarem disponíveis (timeout 10s)
  - `handle_result/2`: Trata resultados de criação de tabelas

## Tabelas Mnesia

| Tabela | Atributos | Tipo |
|--------|-----------|------|
| `:searches` | `:id`, `:keywords`, `:sources`, `:location`, `:filters`, `:status`, `:created_at`, `:updated_at` | `:set` |
| `:jobs` | `:id`, `:search_id`, `:external_id`, `:source`, `:title`, `:company`, `:location`, `:url`, `:status`, `:applied_at`, `:created_at` | `:bag` |
| `:notifications` | `:id`, `:type`, `:channel`, `:recipient`, `:content`, `:status`, `:created_at`, `:sent_at` | `:set` |
| `:user_sessions` | `:session_id`, `:user_info`, `:current_searches`, `:preferences`, `:created_at`, `:expires_at` | `:set` |

## Storage

- **`:disc_copies`**: Para nós com nome (`node() != :nonode@nohost`)
- **`:ram_copies`**: Para nós sem nome (desenvolvimento local)

## Inicialização

O Mnesia é iniciado em `lib/auto_vagas/application.ex`:
```elixir
AutoVagas.Mnesia.Schema.init()
AutoVagas.Mnesia.Schema.wait_for_tables()
```

## Tratamento de Erros

- `:already_exists`: Ignorado (esquema já existe)
- Timeout no `wait_for_tables`: Loga warning, tenta recriar tabelas
- Erros de criação: Loga erro, continua execução

## JobsStore ⭐ NOVO

O módulo `AutoVagas.Crawler.JobsStore` (`lib/crawler/jobs_store.ex`) substitui o antigo `jobs_cache.ex`:
- `save/1`: Salva lista de vagas usando `:mnesia.transaction`
- `load/0`: Carrega todas as vagas da tabela `:jobs`
- `clear/0`: Limpa todas as vagas da tabela `:jobs`

Usado no JobsLive para persistência de vagas capturadas.

## Status

- ✅ Estrutura base implementada
- ✅ Criação de tabelas funcionando
- ✅ Pattern match corrigido para records de 4 elementos
- ✅ JobsStore implementado e integrado
- ✅ Migração completa (JobsStore substituiu JSON)
