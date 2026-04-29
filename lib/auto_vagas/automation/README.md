# Automação de Inscrições - AutoVagas

Módulo responsável pela inscrição automática em vagas de emprego.

## Arquivo

- **automation.ex**: Módulo principal de automação.
  - Usa **apenas Firefox Developer Edition** (`/usr/bin/firefox-developer-edition`)
  - Suporte para detectar Firefox Dev automaticamente
  - Se não encontrado, retorna erro (não usa modo simulação)

## Funcionalidades

### start_session/1
Inicia uma sessão de automação usando Firefox Developer Edition.

```elixir
case AutoVagas.Automation.start_session() do
  {:ok, session} ->
    # Sessão iniciada com sucesso
    # session = %{browser: :firefox, path: "/usr/bin/firefox-developer-edition"}
  
  {:error, :firefox_dev_not_found} ->
    # Firefox Developer Edition não encontrado
end
```

### apply_to_job/3
Realiza inscrição automática em uma vaga (atualmente em modo simulação).

```elixir
AutoVagas.Automation.apply_to_job(session, job_url, user_info)
# Retorna: {:ok, :simulated} ou {:error, reason}
```

### end_session/1
Encerra a sessão de automação.

```elixir
AutoVagas.Automation.end_session(session)
```

## Requisitos

1. **Firefox Developer Edition** instalado em `/usr/bin/firefox-developer-edition`
   - Instalação via Snap: `snap install firefox --beta`
   - Ou via apt: `apt install firefox` e criar link simbólico

2. **GeckoDriver** instalado e no PATH
   - Versão atual: 0.36.0 em `/usr/bin/geckodriver`
   - Download: https://github.com/mozilla/geckodriver/releases

3. **Wallaby** configurado em `config/config.exs`:
```elixir
config :wallaby, driver: Wallaby.Selenium,
  selenium: [
    capabilities: %{
      browserName: "firefox",
      "moz:firefoxOptions": %{
        binary: "/usr/bin/firefox-developer-edition",
        args: ["-headless"]
      }
    }
  ]
```

## Status

- ✅ Estrutura criada
- ✅ Detecção automática do Firefox Developer Edition
- 🔄 Modo simulação funcionando (logs de inscrição)
- ⚠️ Inscrição real via Wallaby + Selenium (pendente - requer testes)

## Notas

- **Apenas Firefox Developer Edition** é suportado (não use Firefox normal ou Chrome)
- O sistema abre automaticamente a página `/configuracoes` no Firefox Dev após instalação
- Scripts `setup.sh` (Linux) e `setup/setup.bat` (Windows) configuram tudo automaticamente
