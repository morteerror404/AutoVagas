# Autenticação SSO - AutoVagas

Módulos de autenticação Single Sign-On (SSO) para plataformas de vagas.

## Arquivos

- **linkedin.ex**: Implementação completa do fluxo OAuth 2.0 com LinkedIn.
  - Gera URL de autorização
  - Troca código por access_token (Mais seguro)
  - Usa Req para chamadas HTTP

- **indeed.ex**: Estrutura para OAuth 2.0 do Indeed (não implementado completamente).
  - Requer configuração no portal de desenvolvedores
  - Dois fluxos: Candidatos vs Empresas

- **gupy.ex**: Estrutura para SAML 2.0 com Gupy (não implementado).
  - Requer biblioteca `samly` para suporte SAML no Phoenix
  - Necessita certificado X.509 (chave pública/privada)
  - Gupy pode exigir whitelist de IP/domínio

## Configuração

As credenciais são armazenadas criptografadas em `priv/filters/auth_config.json`:
```json
{
  "linkedin": {
    "client_id": "3x3mpl3",
    "client_secret": "<criptografado_com_AES-256>"
  }
}
```

## Fluxo LinkedIn OAuth 2.0

1. Usuário clica em "Integrar" na página `/configuracoes`
2. Redirecionamento para: `https://www.linkedin.com/oauth/v2/authorization`
3. Usuário autoriza o app
4. LinkedIn redireciona para: `http://localhost:4000/auth/linkedin/callback?code=...`
5. Sistema troca código por access_token
6. Token é usado para acessar API do LinkedIn

## Status

- ✅ LinkedIn OAuth 2.0: Implementado completamente
- ⚠️ Indeed OAuth 2.0: Apenas estrutura
- ⚠️ Gupy SAML 2.0: Apenas estrutura (requer `samly`)
