defmodule AutoVagasWeb.SkillsLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.UserConfig
  alias AutoVagas.LLM.Ollama
  alias AutoVagas.AI.PDF

  @upload_max_size 10_000_000

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_page={@active_page}>
      <div class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl font-bold text-base-content mb-2">Perfil e Habilidades</h1>
        <p class="text-base-content/60 mb-8">Gerencie seu perfil e importe seu curriculo</p>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Perfil Basico -->
          <div class="card bg-base-200 p-6">
            <h2 class="text-xl font-semibold mb-4">Dados Pessoais</h2>

            <.form for={@basic_form} phx-submit="save_basic" class="space-y-4">
              <div class="form-control">
                <label class="label">
                  <span class="label-text">Nome</span>
                </label>
                <.input field={@basic_form[:name]} type="text" class="w-full input-bordered" />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Localizacao</span>
                </label>
                <.input field={@basic_form[:location]} type="text" class="w-full input-bordered" />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">URL do LinkedIn</span>
                </label>
                <.input field={@basic_form[:linkedin_url]} type="text" class="w-full input-bordered" placeholder="https://linkedin.com/in/seu-perfil" />
              </div>

              <button type="submit" class="btn btn-primary">Salvar</button>
            </.form>

            <div class="mt-4">
              <.link>
                <button class="btn btn-outline btn-sm" phx-click="sync_linkedin">
                  Sincronizar com LinkedIn
                </button>
              </.link>
              <span class="text-xs text-base-content/60 ml-2">Requer URL configurada</span>
            </div>
          </div>

          <!-- Importar PDF -->
          <div class="card bg-base-200 p-6">
            <h2 class="text-xl font-semibold mb-4">Importar Curriculo (PDF)</h2>
            <p class="text-sm text-base-content/60 mb-4">
              Envie seu curriculo em PDF para extrair habilidades automaticamente usando IA.
            </p>
            <.live_file_input upload={@uploads.pdf} class="file-input file-input-bordered w-full" />
            <p class="text-base-content/60 mt-2">
              {if @uploading, do: "Processando...", else: "Clique ou arraste um arquivo PDF"}
            </p>
            {@upload_message}

            <.form for={@upload_form} id="upload-form" phx-submit="save_upload" class="mt-4">
              <button type="submit" class="btn btn-primary" disabled={@uploads.pdf.entries == []}>
                Processar PDF
              </button>
            </.form>
          </div>
        </div>

        <!-- Habilidades -->
        <div class="mt-8">
          <h2 class="text-xl font-semibold mb-4">Habilidades Tecnicas</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div :for={tech <- @technologies} class="card bg-base-100 shadow p-4">
              <h3 class="font-bold">{tech["name"]}</h3>
              <p class="text-sm text-base-content/70">{tech["years"]} anos</p>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    user_info = UserConfig.load()

    basic_form = to_form(%{
      "name" => Map.get(user_info, "name", ""),
      "location" => Map.get(user_info, "location", "Brazil"),
      "linkedin_url" => Map.get(user_info, "linkedin_profile_url", "")
    })

    upload_form = to_form(%{})

    technologies = extract_technologies(user_info)

    socket =
      socket
      |> assign(:active_page, "habilidades")
      |> assign(basic_form: basic_form, upload_form: upload_form)
      |> assign(technologies: technologies)
      |> assign(uploading: false, upload_message: nil, upload_error: false)
      |> allow_upload(:pdf, accept: [".pdf"], max_entries: 1, max_file_size: @upload_max_size)

    {:ok, socket}
  end

  def handle_event("save_basic", params, socket) do
    user_info = UserConfig.load()

    updated =
      user_info
      |> Map.put("name", params["name"])
      |> Map.put("location", params["location"])
      |> Map.put("linkedin_profile_url", params["linkedin_url"])

    UserConfig.save(updated)

    {:noreply, put_flash(socket, :info, "Perfil salvo!")}
  end

  def handle_event("sync_linkedin", _params, socket) do
    user_info = UserConfig.load()

    case AutoVagas.LinkedinProfile.fetch_and_update(user_info, use_scraping: true) do
      {:ok, updated} ->
        technologies = extract_technologies(updated)

        {:noreply,
         socket
         |> assign(technologies: technologies)
         |> put_flash(:info, "Perfil LinkedIn sincronizado!")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Erro ao sincronizar LinkedIn: #{reason}")}
    end
  end

  def handle_event("save_upload", _params, socket) do
    entries = socket.assigns.uploads.pdf.entries

    {entries_to_upload, socket} =
      Enum.reduce(entries, {[], socket}, fn entry, {acc, sock} ->
        [path] = consume_uploaded_entries(sock, :pdf, fn %{path: path}, _entry -> {:ok, path} end)
        Process.send(self(), {:process_pdf, path}, [])
        {[{entry.ref, path} | acc], sock}
      end)

    socket =
      socket
      |> cancel_upload(:pdf, entries_to_upload)
      |> assign(uploading: true, upload_message: nil)

    {:noreply, socket}
  end

  def handle_info({:process_pdf, path}, socket) do
    case extract_from_pdf(path) do
      {:ok, skills} ->
        user_info = UserConfig.load()
        updated = Map.put(user_info, "skills", skills)
        UserConfig.save(updated)

        technologies = extract_technologies(updated)

        {:noreply,
         socket
         |> assign(uploading: false, upload_message: "Curriculo importado com sucesso!")
         |> assign(technologies: technologies)}

      {:error, msg} ->
        {:noreply, assign(socket, uploading: false, upload_message: msg, upload_error: true)}
    end
  end

  defp extract_from_pdf(path) do
    with {:ok, text} <- PDF.extract_text(path),
         {:ok, response} <- Ollama.analyze_resume(text) do
      skills = parse_skills(response)
      {:ok, skills}
    else
      error -> error
    end
  end

  defp parse_skills(text) do
    common_techs = ["Elixir", "Phoenix", "Python", "Java", "JavaScript", "React", "Node.js"]

    Enum.filter(common_techs, fn tech ->
      String.contains?(String.downcase(text), String.downcase(tech))
    end)
    |> Enum.map(fn tech ->
      %{"name" => tech, "years" => AutoVagas.Profiles.Experience.get_years(tech)}
    end)
  end

  defp extract_technologies(user_info) do
    experience = Map.get(user_info, "experience", %{})

    Map.keys(experience)
    |> Enum.reject(&String.starts_with?(&1, "_"))
    |> Enum.map(fn tech ->
      years = AutoVagas.Profiles.Experience.get_years(tech)
      %{"name" => tech, "years" => years}
    end)
  end
end
