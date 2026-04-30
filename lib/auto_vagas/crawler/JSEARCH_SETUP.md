# JSearch API Setup - AutoVagas

## Visao Geral

JSearch API (letscrape) e uma alternativa para busca de vagas do LinkedIn via RapidAPI.

## Configuracao

1. Acesse: https://rapidapi.com/letscrape-6bRBa3QguO5/api/jsearch
2. Clique em "Subscribe to Test"
3. Escolha plano (Free tier disponivel)
4. Copie a API Key

## Configurar no AutoVagas

1. Acesse `/configuracoes` no AutoVagas
2. Clique em "Configurar" na secao "RapidAPI - LinkedIn Jobs"
3. Cole sua API Key
4. Salve

## Uso no Codigo

```elixir
# Busca via JSearch
AutoVagas.Crawler.Sites.LinkedIn.fetch_via_jsearch/4

# Fluxo automatico (fetch_jobs/5)
# Tenta: RapidAPI -> Rockapis -> JSearch -> Guest API -> Scraping
```

## Parametros Suportados

- `query` - Termos de busca
- `location` - Localizacao (ex: "Brazil")
- `page` - Numero da pagina
- `num_pages` - Quantidade de paginas
- `date_posted` - Filtro de data (past_24_hours, past_week, past_month)
- `employment_types` - Tipo de emprego (full_time, part_time, contract)

## Referencia

- Documentacao: https://rapidapi.com/letscrape-6bRBa3QguO5/api/jsearch
- Host: `letscrape-6bRBa3QguO5.p.rapidapi.com`
- Endpoint: `/jsearch`
