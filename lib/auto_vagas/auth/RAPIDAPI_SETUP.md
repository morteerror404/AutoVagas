# Guia: Configurar RapidAPI para Busca de Vagas LinkedIn

## O que é a RapidAPI?

A RapidAPI é um marketplace que fornece acesso a milhares de APIs, incluindo a **LinkedIn Job Search API** que permite buscar vagas programaticamente sem precisar de scraping.

## Passo a Passo: Obter sua API Key

### 1. Criar Conta na RapidAPI
1. Acesse: https://rapidapi.com/
2. Clique em **"Sign Up"** (canto superior direito)
3. Crie uma conta usando:
   - Email e senha, ou
   - Google/GitHub (mais rápido)

### 2. Assinar a LinkedIn Job Search API
1. Apos logar, acesse: https://rapidapi.com/fantastic-jobs-fantastic-jobs-default/api/linkedin-job-search-api
2. Clique em **"Subscribe to Test"** (botão azul)
3. Escolha um plano:
   - **Basic (Grátis)**: 100 requisições/mês (recomendado para teste)
   - **Pro**: Planos pagos com mais requisições

### 3. Obter sua API Key
1. Após assinar, vá para a aba **"Endpoints"** ou **"Playground"**
2. No topo da página, você verá:
   ```
   X-RapidAPI-Key: SUA_CHAVE_AQUI
   X-RapidAPI-Host: fresh-linkedin-scraper-api.p.rapidapi.com
   ```
3. **Copie a chave** (o valor após `X-RapidAPI-Key:`)

### 4. Testar se a chave funciona
No RapidAPI, você pode testar diretamente na página:
1. Vá para **"Test Endpoint"**
2. Preencha os campos:
   - `keyword`: "software engineer"
   - `location`: "Brazil"
3. Clique em **"Test Endpoint"**
4. Se retornar JSON com vagas, sua chave está funcionando!

## Configurar no AutoVagas

### Método 1: Via Interface Web (Recomendado)
1. Inicie o servidor: `mix phx.server`
2. Acesse: http://localhost:4000/configuracoes
3. Vá para a aba **"Integrações"**
4. Clique em **"Credenciais"** na seção **"RapidAPI - LinkedIn Job Search"**
5. Cole sua API Key e clique **"Salvar"**

A chave será:
- Criptografada automaticamente com AES-256-GCM
- Armazenada em `priv/filters/auth_config.json`

### Método 2: Edição Manual (Avançado)
1. Gere um JSON com a estrutura:
   ```json
   {
     "rapidapi": {
       "linkedin_job_search": {
         "api_key": "SUA_CHAVE_AQUI"
       }
     }
   }
   ```

2. Salve em `priv/filters/auth_config.json`

3. **Importante**: A chave deve ser criptografada antes de salvar. Use o módulo `AutoVagas.Crypto`:
   ```elixir
   encrypted = AutoVagas.Crypto.encrypt("SUA_CHAVE_AQUI")
   # Salve o valor criptografado no JSON
   ```

## Verificar se está funcionando

1. Reinicie o servidor: `mix phx.server`
2. Acesse http://localhost:4000/vagas
3. Preencha o formulário de busca:
   - Palavras-chave: "elixir developer"
   - Localização: "Brazil"
4. Clique em **"Buscar Vagas"**
5. Se a busca retornar resultados, a integração está funcionando!

## Limites do Plano Grátis
- 100 requisições por mês
- Sem acesso a todos os filtros avançados
- Para uso intensivo, considere upgradar na RapidAPI

## Troubleshooting

### Erro: "Unauthorized" ou "Invalid API Key"
- Verifique se copiou a chave completa
- Certifique-se de que assinou a API na RapidAPI
- Tente gerar uma nova chave na RapidAPI

### Erro: "Rate Limit Exceeded"
- Você atingiu o limite de 100 requisições/mês
- Aguarde o reset (próximo mês) ou faca upgrade na RapidAPI

### A busca não retorna vagas
- Verifique os logs do servidor: `mix phx.server`
- Tente usar termos em inglês (ex: "software engineer" em vez de "desenvolvedor")
- Verifique se a localização está correta
