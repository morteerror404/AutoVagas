defmodule AutoVagas.Auth.Crypto do
  @moduledoc """
  Modulo para criptografia AES de credenciais.
  Usa AES-256-GCM para criptografia autenticada.
  """

  @secret_key_path "priv/filters/.secret_key"
  @aad "AutoVagas"  # Additional authenticated data

  defp get_key do
    case File.read(@secret_key_path) do
      {:ok, key} ->
        Base.decode64!(key)

      _ ->
        key = :crypto.strong_rand_bytes(32)
        File.write!(@secret_key_path, Base.encode64(key))
        key
    end
  end

  @doc """
  Criptografa um texto usando AES-256-GCM.
  """
  def encrypt(plaintext) when is_binary(plaintext) do
    key = get_key()
    iv = :crypto.strong_rand_bytes(12)
    {ciphertext, tag} = :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, plaintext, @aad, true)
    "v2:" <> Base.encode64(iv <> tag <> ciphertext)
  end

  @doc """
  Descriptografa um texto criptografado com AES-256-GCM.
  """
  def decrypt(ciphertext) when is_binary(ciphertext) do
    key = get_key()

    case String.split(ciphertext, ":", parts: 2) do
      ["v2", encrypted] ->
        decoded = Base.decode64!(encrypted)
        <<iv::binary-12, tag::binary-16, ciphertext::binary>> = decoded
        :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ciphertext, @aad, tag, false)

      _ ->
        # Fallback para formato antigo (CBC)
        decrypt_legacy(ciphertext, key)
    end
  end

  defp decrypt_legacy(ciphertext, key) do
    decoded = Base.decode64!(ciphertext)
    :crypto.crypto_one_time(:aes_256_cbc, key, decoded, false)
  end
end
