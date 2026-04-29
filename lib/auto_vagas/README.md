# AutoVagas - Módulo Principal

Este diretório contém os módulos centrais do sistema AutoVagas.

## Arquivos Principais

- **application.ex**: Inicialização da aplicação OTP (Open Telecom Platform). Configura o supervisor, inicia Mnesia, Experience e demais filhos (Arquivo que funciona como uma função Main).
- **experience.ex**: Cálculo de anos de experiência profissional baseado em NTP (Network Time Protocol), ou seja, se estamos em 2026 e você tem 2 anos de experiência em Python, 2026 - 2 = 2024, nesse você aprendeu python, portanto, não é necessário reatualizar essa informações, o próprio sistema já calcula automaticamente.
- **ntp.ex**: Cliente NTP para obter tempo preciso via rede (porta 123 UDP), com o objetivo de desobrigar o usuário de inserir a data manualmente, além de proteger contra manipulação do relógio do computador do usuário, que por ventura poderia ser facilmente explorado para "Mentir" o tempo de experiência (Apesar do esforço ser completamente desnecessário, sendo que o usuário pode alterar a qualquer momento o arquivo que armazena essas informações).
- **crypto.ex**: Criptografia AES-256 para proteção de credenciais sensíveis (Client Secret), apesar de não ser uma medida de "blindagem" é uma contramedida para dar um gap de tempo de resposta em caso de infecção.

## Subdiretórios

- **auth/**: Módulos de autenticação SSO (LinkedIn OAuth 2.0, Indeed, Gupy SAML 2.0).
- **automation/**: Módulo de automação de inscrições em vagas via Firefox Developer Edition.
- **mnesia/**: Esquema e gerenciamento do banco de dados distribuído Mnesia (Redis nativo do ELixir).
- **notifications/**: Canais de notificação (WhatsApp, Telegram, Discord).
- **crawler/**: Crawlers e adaptadores para plataformas de vagas (LinkedIn, Indeed, Gupy).
