defmodule AutoVagasWeb.AuthController do
  use AutoVagasWeb, :controller

  @doc """
  Trata o callback do LinkedIn OAuth 2.0 via OpenID Connect.
  """
  def linkedin_callback(conn, %{"code" => code, "state" => _state}) do
    case AutoVagasWeb.Auth.LinkedIn.Callback.handle(code) do
      {:ok, _userinfo} ->
        conn
        |> put_flash(:info, "LinkedIn conectado com sucesso via OpenID Connect!")
        |> redirect(to: "/configuracoes")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Erro ao conectar com LinkedIn: #{inspect(reason)}")
        |> redirect(to: "/configuracoes")
    end
  end

  def linkedin_callback(conn, _params) do
    conn
    |> put_flash(:error, "Parâmetros de callback inválidos")
    |> redirect(to: "/configuracoes")
  end

  @doc """
  Trata o callback do Indeed OAuth 2.0.
  """
  def indeed_callback(conn, %{"code" => code, "state" => _state}) do
    case AutoVagasWeb.Auth.Indeed.Callback.handle(code) do
      {:ok, _profile} ->
        conn
        |> put_flash(:info, "Indeed conectado com sucesso!")
        |> redirect(to: "/configuracoes")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Erro ao conectar com Indeed: #{inspect(reason)}")
        |> redirect(to: "/configuracoes")
    end
  end

  def indeed_callback(conn, _params) do
    conn
    |> put_flash(:error, "Parâmetros de callback inválidos")
    |> redirect(to: "/configuracoes")
  end

  @doc """
  Trata o callback do Gupy SAML 2.0.
  """
  def gupy_callback(conn, params) do
    case AutoVagasWeb.Auth.Gupy.Callback.handle(params) do
      {:ok, _profile} ->
        conn
        |> put_flash(:info, "Gupy conectado com sucesso!")
        |> redirect(to: "/configuracoes")

      {:error, reason} ->
        conn
        |> put_flash(:error, "Erro ao conectar com Gupy: #{inspect(reason)}")
        |> redirect(to: "/configuracoes")
    end
  end
end
