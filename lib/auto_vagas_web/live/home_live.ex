defmodule AutoVagasWeb.HomeLive do
  use AutoVagasWeb, :live_view

  def render(_assigns) do
  end

  @spec mount(any(), any(), any()) :: {:ok, any()}
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
