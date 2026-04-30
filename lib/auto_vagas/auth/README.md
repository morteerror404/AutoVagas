# Autenticação SSO - AutoVagas

Módulos de autenticação Single Sign-On (SSO) para plataformas de vagas.

## Arquivos

- **linkedin.ex**: Implementação completa do fluxo OAuth 2.0 com LinkedIn.
  - Gera URL de autorização
  - Troca código por access_token (Mais seguro)
  - Usa Req para chamadas HTTP
  - **Novo**: Estrutura para busca de vagas via API ⭐

- **indeed.ex**: Estrutura para OAuth 2.0 do Indeed (não implementado completamente).
  - Requer configuração no portal de desenvolvedores
  - Dois fluxos: Candidatos vs Empresas

- **gupy.ex**: Estrutura para SAML 2.0 com Gupy (não implementado).
  - Requer biblioteca `samly` para suporte SAML no Phoenix
  - Necessita certificado X.509 (chave pública/privada)
  - Gupy pode exigir whitelist de IP/domínio

## Configuração

### LinkedIn OAuth 2.0
As credenciais são armazenadas criptografadas em `priv/filters/auth_config.json`:
```json
{
  "linkedin": {
    "client_id": "77ye1svdvforpt",
    "client_secret": "<criptografado_com_AES-256>"
  }
}
```

### RapidAPI para LinkedIn Jobs ⭐ NOVO
Para busca de vagas (não para OAuth):
```json
{
  "rapidapi": {
    "linkedin_job_search": {
      "api_key": "<criptografado_com_AES-256>"
    }
  }
}
```

Configurado em `/configuracoes` → seção "RapidAPI"

## Fluxo LinkedIn OAuth 2.0

1. Usuário clica em "Integrar" na página `/configuracoes`
2. Redirecionamento para: `https://www.linkedin.com/oauth/v2/authorization`
3. Usuário autoriza o app
4. LinkedIn redireciona para: `http://localhost:4000/auth/linkedin/callback?code=...`
5. Sistema troca código por access_token
6. Token é usado para acessar API do LinkedIn

## Busca de Vagas LinkedIn ⭐ NOVO

Métodos disponíveis (em ordem de prioridade):
1. **RapidAPI** (`linkedin_job_search`) - Requer API key
2. **Guest API** (não autenticado) - Fallback
3. **Scraping** (última instância) - Fallback

Implementado em `lib/auto_vagas/sites/linkedin.ex`:
- `fetch_via_rapidapi/3`
- `fetch_via_guest_api/3`
- `fetch_via_scraping/3`
- `fetch_jobs/5` (orquestrador)

## Status

- ✅ LinkedIn OAuth 2.0: Implementado completamente
- ✅ LinkedIn Jobs Search: Implementado via RapidAPI/Guest API/Scraping
- ⚠️ Indeed OAuth 2.0: Apenas estrutura
- ⚠️ Gupy SAML 2.0: Apenas estrutura (requer `samly`)
