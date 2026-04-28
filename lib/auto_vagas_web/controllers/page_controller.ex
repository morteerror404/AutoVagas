defmodule AutoVagasWeb.PageController do
  use AutoVagasWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
