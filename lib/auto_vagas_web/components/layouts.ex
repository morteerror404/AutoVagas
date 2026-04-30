defmodule AutoVagasWeb.Layouts do
  @moduledoc """
  Layouts do AutoVagas.
  """
  use AutoVagasWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :active_page, :string, default: "home"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar bg-base-200 border-b border-base-300 px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <.link navigate="/" class="flex items-center gap-2">
          <.icon name="hero-briefcase" class="w-8 h-8 text-primary" />
          <span class="text-xl font-bold text-base-content">AutoVagas</span>
        </.link>
      </div>
      <div class="flex-none">
        <ul class="menu menu-horizontal px-1 gap-1">
          <li>
            <.link navigate="/" class={"btn btn-sm " <> if(@active_page == "home", do: "btn-active", else: "btn-ghost")}>
              Início
            </.link>
          </li>
          <li>
            <.link navigate="/vagas" class={"btn btn-sm " <> if(@active_page == "vagas", do: "btn-active", else: "btn-ghost")}>
              Vagas
            </.link>
          </li>
          <li>
            <.link navigate="/habilidades" class={"btn btn-sm " <> if(@active_page == "habilidades", do: "btn-active", else: "btn-ghost")}>
              Habilidades
            </.link>
          </li>
          <li>
            <.link navigate="/configuracoes" class={"btn btn-sm " <> if(@active_page == "configuracoes", do: "btn-active", else: "btn-ghost")}>
              Config
            </.link>
          </li>
          <li>
            <.link navigate="/ajuda" class={"btn btn-sm " <> if(@active_page == "ajuda", do: "btn-active", else: "btn-ghost")}>
              Ajuda
            </.link>
          </li>
        </ul>
        <.theme_toggle />
      </div>
    </header>

    <main class="min-h-screen bg-base-100">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} class="fixed top-4 right-4 z-50">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <div class="dropdown dropdown-end">
      <div tabindex="0" role="button" class="btn btn-ghost btn-sm gap-1">
        <.icon name="hero-sun" class="w-4 h-4" />
        <.icon name="hero-chevron-down" class="w-3 h-3" />
      </div>
      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-200 rounded-box w-32">
        <li>
          <button
            onclick="document.documentElement.setAttribute('data-theme', 'light')"
            class="btn btn-ghost btn-sm w-full"
          >
            Light
          </button>
        </li>
        <li>
          <button
            onclick="document.documentElement.setAttribute('data-theme', 'dark')"
            class="btn btn-ghost btn-sm w-full"
          >
            Dark
          </button>
        </li>
        <li>
          <button
            onclick="document.documentElement.removeAttribute('data-theme')"
            class="btn btn-ghost btn-sm w-full"
          >
            System
          </button>
        </li>
      </ul>
    </div>
    """
  end
end
