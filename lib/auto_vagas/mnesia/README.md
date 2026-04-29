# Mnesia - Banco de Dados Distribuído

Este diretório contém os módulos para gerenciamento do banco de dados Mnesia (nativo do Erlang/Elixir).

## Arquivos

- **schema.ex**: Gerencia o esquema Mnesia com todas as tabelas necessárias.
  - `init/0`: Inicializa Mnesia, cria esquema (se não existir)
  - `create_tables/0`: Cria tabelas: `:searches`, `:jobs`, `:notifications`, `:user_sessions`
  - `wait_for_tables/0`: Aguarda tabelas estarem disponíveis (timeout 10s)
  - `handle_result/2`: Trata resultados de criação de tabelas

- **search_manager.ex**: Gerencia múltiplas buscas simultâneas.
  - `create_search/3`: Cria nova busca com ID único
  - `list_searches/0`: Lista todas as buscas ativas
  - `get_search/1`: Obtém busca por ID
  - `update_search_status/2`: Atualiza status da busca
  - `delete_search/1`: Remove busca e vagas associadas
  - `add_job/2`: Adiciona vaga a uma busca
  - `list_jobs/1`: Lista vagas de uma busca
  - `update_job_status/2`: Atualiza status da vaga
  - `generate_search_id/0`: Gera ID único (hash SHA-256)
  - `generate_job_id/0`: Gera ID único para vaga

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

## Status

- ✅ Estrutura base implementada
- ✅ Criação de tabelas funcionando
- ✅ Pattern match corrigido para records de 4 elementos
- 🔄 Migração completa de JobsCache para Mnesia (pendente)
