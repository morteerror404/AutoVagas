defmodule AutoVagas.Crypto do
  @moduledoc """
  Modulo para criptografia AES de credenciais.
  """

  @aes_key :crypto.strong_rand_bytes(32)
  @aes_iv :crypto.strong_rand_bytes(16)

  @doc """
  Criptografa um texto usando AES-256-CBC.
  """
  def encrypt(plaintext) when is_binary(plaintext) do
    ciphertext = :crypto.crypto_one_time(:aes_256_cbc, @aes_key, @aes_iv, plaintext, true)
    Base.encode64(ciphertext)
  end

  @doc """
  Descriptografa um texto criptografado com AES-256-CBC.
  """
  def decrypt(ciphertext) when is_binary(ciphertext) do
    decoded = Base.decode64!(ciphertext)
    :crypto.crypto_one_time(:aes_256_cbc, @aes_key, @aes_iv, decoded, false)
  end
end
