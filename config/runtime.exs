import Config

# config/runtime.exs is executed for all environments, including
# during releases.

config :auto_vagas, AutoVagasWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    "TK//3YjQO7k34bp5pupNNzc97zMlj1eH0jjBRIS2ZcpWbP4w1AyI/+SUE4o+A7dB"

config :auto_vagas, AutoVagasWeb.Endpoint, secret_key_base: secret_key_base

if System.get_env("PHX_SERVER") do
  config :auto_vagas, AutoVagasWeb.Endpoint, server: true
end
