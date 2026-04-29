defmodule AutoVagasWeb.JobSearchLive do
  use AutoVagasWeb, :live_view

  alias AutoVagas.Crawler.{Adapter, JobsStore, AuthSession}
  alias AutoVagas.Crawler.UserConfig

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-4xl mx-auto p-6">
        <h1 class="text-3xl font-bold text-base-content mb-2">AutoVagas</h1>
        <p class="text-base-content/60 mb-8">Busca automatizada de vagas de emprego</p>

        <.form for={@form} id="search-form" phx-submit="search" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-base-content mb-1">Palavras-chave</label>
            <.input
              field={@form[:keywords]}
              type="text"
              placeholder="ex: desenvolvedor elixir, analista..."
              class="w-full"
            />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-base-content mb-1">Localização</label>
              <.input
                field={@form[:location]}
                type="text"
                placeholder="Brazil"
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-base-content mb-1">Fonte</label>
              <.input
                field={@form[:source]}
                type="select"
                options={[
                  {"Todas", "all"},
                  {"LinkedIn", "linkedin"},
                  {"Indeed", "indeed"},
                  {"Gupy", "gupy"}
                ]}
                class="w-full"
              />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-base-content mb-1">
                 Tempo de experiência
              </label>
              <.input
                field={@form[:time_posted]}
                type="select"
                options={[
                  {"Última hora", "r3600"},
                  {"Últimas 24 horas", "r86400"},
                  {"Última semana", "r604800"},
                  {"Último mês", "r2592000"}
                ]}
                class="w-full"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-base-content mb-1">Tipo de trabalho</label>
              <.input
                field={@form[:work_type]}
                type="select"
                options={[
                  {"Todos", "1%2C2%2C3"},
                  {"Remoto", "2"},
                  {"Presencial", "1"},
                  {"Híbrido", "3"}
                ]}
                class="w-full"
              />
            </div>
          </div>

          <details class="bg-base-200 border border-base-300 rounded-lg p-4">
            <summary class="cursor-pointer font-medium text-base-content mb-2">
              Filtros Avançados
            </summary>
            <div class="space-y-4 mt-2">
              <div>
                <label class="block text-sm font-medium text-base-content mb-1">
                  Palavras para incluir
                </label>
                <.input
                  field={@form[:include_words]}
                  type="text"
                  placeholder="ex: python, docker, aws"
                  class="w-full"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-base-content mb-1">
                  Palavras para excluir
                </label>
                <.input
                  field={@form[:exclude_words]}
                  type="text"
                  placeholder="ex: estagio, junior"
                  class="w-full"
                />
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">
                    Experiência mínima (anos)
                  </label>
                  <.input
                    field={@form[:min_experience]}
                    type="number"
                    min="0"
                    class="w-full"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-base-content mb-1">
                    Máximo de aplicações
                  </label>
                  <.input
                    field={@form[:max_applications]}
                    type="number"
                    min="0"
                    class="w-full"
                  />
                </div>
              </div>
              <div class="flex items-center gap-2">
                <.input
                  field={@form[:remote_only]}
                  type="checkbox"
                  class="checkbox checkbox-primary"
                />
                <label class="text-sm text-base-content">
                  Apenas vagas remotas
                </label>
              </div>
            </div>
          </details>

          <button
            type="submit"
            class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-3 px-6 rounded-lg transition-colors disabled:opacity-50"
            disabled={@loading}
          >
            {if @loading, do: "Buscando...", else: "Buscar vagas"}
          </button>
        </.form>

        <div :if={@jobs != []} class="mt-8">
          <h2 class="text-xl font-semibold text-base-content mb-4">
            {length(@jobs)} vagas encontradas
          </h2>

          <div class="space-y-4" id="jobs" phx-update="stream">
            <div
              :for={{id, job} <- @streams.jobs}
              id={id}
              class="bg-base-200 border border-base-300 rounded-lg p-4 hover:shadow-md transition-shadow"
            >
              <div class="flex justify-between items-start">
                <div class="flex-1">
                  <h3 class="text-lg font-semibold text-base-content">{job.title}</h3>
                  <p class="text-base-content/60">{job.company}</p>
                  <p class="text-sm text-base-content/50 mt-1">{job.location}</p>
                </div>
                <span class="text-xs bg-base-300 text-base-content/60 px-2 py-1 rounded">
                  {job.source}
                </span>
              </div>
              <a
                href={job.url}
                target="_blank"
                class="mt-3 inline-block text-primary hover:text-primary/80 text-sm font-medium"
              >
                Ver vaga →
              </a>
            </div>
          </div>
        </div>

        <div
          :if={@jobs == [] and not @loading and @searched}
          class="mt-8 text-center py-8 text-base-content/50"
        >
          Nenhuma vaga encontrada. Tente buscar com outros termos.
        </div>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    user_config = UserConfig.load()
    filters = Map.get(user_config, "filters", %{})
    global_filters = Map.get(filters, "global", %{})

    form =
      to_form(%{
        "keywords" => "",
        "location" => "Brazil",
        "source" => "linkedin",
        "time_posted" => "r86400",
        "work_type" => "1%2C2%2C3",
        "include_words" => Enum.join(Map.get(global_filters, "include_words", []), ", "),
        "exclude_words" => Enum.join(Map.get(global_filters, "exclude_words", []), ", "),
        "min_experience" => Map.get(global_filters, "min_experience_years", ""),
        "max_applications" => Map.get(global_filters, "max_applications", ""),
        "remote_only" => Map.get(global_filters, "remote_only", false)
      })

    {:ok,
     socket
     |> assign(form: form, jobs: [], loading: false, searched: false)
     |> stream_configure(:jobs, dom_id: &"job-#{&1.external_id}")}
  end

  def handle_event(
        "search",
        %{
          "keywords" => keywords,
          "location" => location,
          "source" => source,
          "time_posted" => time_posted,
          "work_type" => work_type
        },
        socket
      ) do
    if keywords == "" do
      {:noreply, socket}
    else
      socket = assign(socket, loading: true, searched: true, jobs: [])
      Process.send(self(), {:run_search, keywords, location, source, time_posted, work_type}, [])

      {:noreply, socket}
    end
  end

  def handle_info({:run_search, keywords, location, source, time_posted, work_type}, socket) do
    sources = if source == "all", do: ["linkedin", "indeed", "gupy"], else: [source]

    user_info = UserConfig.load()

    all_jobs =
      sources
      |> Enum.map(&Adapter.adapter_for/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(fn adapter ->
        keywords_list = String.split(keywords, ",") |> Enum.map(&String.trim/1)

        urls =
          adapter.build_urls(keywords_list,
            location: location,
            time_posted: time_posted,
            work_type: work_type
          )

        jobs = fetch_jobs(adapter, urls)

        # Apply filters using Filter module
        AutoVagas.Crawler.Filter.apply(jobs, Map.get(user_info, "filters", %{}))
      end)
      |> Enum.uniq_by(fn job -> job["external_id"] end)
      |> Enum.map(&Map.put(&1, "selected", false))

    existing = JobsStore.load()
    updated = (existing ++ all_jobs) |> Enum.uniq_by(fn job -> job["external_id"] end)
    JobsStore.save(updated)

    socket =
      socket
      |> assign(loading: false, jobs: all_jobs)
      |> stream(:jobs, all_jobs, reset: true)

    {:noreply, socket}
  end

  defp fetch_jobs(adapter, urls) do
    source = adapter_source(adapter)

    urls
    |> Enum.map(fn {_keyword, url} ->
      Task.async(fn ->
        cookies = AuthSession.get_cookies(source)
        case fetch_with_cookies(url, cookies) do
          %{status: 200, body: body} ->
            adapter.parse(body)

          _ ->
            []
        end
      end)
    end)
    |> Task.await_many(30_000)
    |> Enum.flat_map(fn
      jobs when is_list(jobs) -> jobs
      {:ok, jobs} when is_list(jobs) -> jobs
      _ -> []
    end)
  end

  defp fetch_with_cookies(url, [] = _cookies) do
    Req.get!(url, follow_redirects: true)
  end

  defp fetch_with_cookies(url, cookies) do
    cookie_header =
      cookies
      |> Enum.map(fn %{"name" => name, "value" => value} -> "#{name}=#{value}" end)
      |> Enum.join("; ")

    Req.get!(url,
      follow_redirects: true,
      headers: [{"cookie", cookie_header}]
    )
  end

  defp adapter_source(AutoVagas.Crawler.Sites.LinkedIn), do: "linkedin"
  defp adapter_source(AutoVagas.Crawler.Sites.Indeed), do: "indeed"
  defp adapter_source(AutoVagas.Crawler.Sites.Gupy), do: "gupy"
  defp adapter_source(_), do: nil
end
