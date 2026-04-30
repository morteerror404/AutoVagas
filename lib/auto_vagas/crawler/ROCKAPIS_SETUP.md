# Rockapis LinkedIn Data API Setup - AutoVagas

## Visao Geral

Rockapis LinkedIn Data API oferece campos adicionais de IA comparado ao RapidAPI padrao.

## Configuracao

1. Acesse: https://rapidapi.com/rockapis-rockapis-default/api/linkedin-data-api
2. Clique em "Subscribe to Test"
3. Escolha plano (Free tier disponivel)
4. Copie a API Key

## Configurar no AutoVagas

1. Acesse `/configuracoes` no AutoVagas
2. Clique em "Configurar" na secao "RapidAPI - LinkedIn Jobs"
3. Cole sua API Key (mesma chave para todos metodos)
4. Salve

## Uso no Codigo

```elixir
# Busca via Rockapis
AutoVagas.Crawler.Sites.LinkedIn.fetch_via_rockapis/4

# Retorna campos adicionais:
# - ai_* fields
# - description_text
# - organization details
```

## Parametros Suportados

- `query` - Termos de busca
- `location` - Localizacao
- `limit` - Limite de resultados
- `freshness` - Filtro de data (past_24_hours, past_week, past_month)
- `employment_type` - Tipo de emprego

## Fluxo Automatico

O `fetch_jobs/5` tenta na ordem:
1. RapidAPI (fantastic-jobs)
2. Rockapis (linkedin-data-api)
3. JSearch (letscrape)
4. Guest API (nao oficial)
5. Scraping (ultima instancia)

## Referencia

- Documentacao: https://rapidapi.com/rockapis-rockapis-default/api/linkedin-data-api
- Host: `rockapis-rockapis-default.p.rapidapi.com`
- Endpoint: `/api/linkedin-data-api/search`
