defmodule AutoVagasWeb.I18n do
  @moduledoc """
  Módulo de internacionalização.
  Detecta o idioma do navegador e traduz textos.
  """

  @translations %{
    "pt" => %{
      "home" => "Início",
      "search" => "Buscar Vagas",
      "settings" => "Configurações",
      "profiles" => "Perfis/Currículos",
      "create_profile" => "Criar primeiro perfil",
      "new_profile" => "+ Novo Perfil",
      "profile_name" => "Nome do perfil",
      "keywords" => "Palavras-chave",
      "technologies" => "Tecnologias",
      "roles" => "Cargos",
      "languages" => "Idiomas",
      "add_language" => "Selecione...",
      "portuguese" => "Português",
      "english" => "Inglês",
      "spanish" => "Espanhol",
      "french" => "Francês",
      "german" => "Alemão",
      "italian" => "Italiano",
      "chinese" => "Chinês",
      "japanese" => "Japonês",
      "korean" => "Coreano",
      "arabic" => "Árabe",
      "russian" => "Russo",
      "hindi" => "Hindi",
      "general_settings" => "Configurações Gerais",
      "location" => "Localização padrão",
      "time_posted" => "Tempo de experiência",
      "work_type" => "Tipo de trabalho",
      "last_hour" => "Última hora",
      "last_24h" => "Últimas 24 horas",
      "last_week" => "Última semana",
      "last_month" => "Último mês",
      "all" => "Todos",
      "remote" => "Remoto",
      "on_site" => "Presencial",
      "hybrid" => "Híbrido",
      "work_config" => "Configuração por Tipo de Trabalho",
      "on_site_config" => "Presencial",
      "hybrid_config" => "Híbrido",
      "remote_config" => "Remoto",
      "max_distance" => "Distância máx (km)",
      "countries" => "Países",
      "import_resume" => "Importar Currículo",
      "help" => "? Ajuda",
      "close_help" => "✕ Fechar",
      "how_to_export" => "Como exportar seu currículo do LinkedIn:",
      "save_all" => "Salvar tudo",
      "find_jobs" => "Buscar Vagas",
      "configure_profile" => "Configurar Perfil",
      "how_it_works" => "Como funciona",
      "create_profile_step" => "Crie seu perfil",
      "create_profile_desc" => "Configure seus interesses, tecnologias e áreas de atuação.",
      "auto_search" => "Busca automática",
      "auto_search_desc" => "O sistema busca em múltiplas plataformas simultaneamente.",
      "receive_opportunities" => "Receba oportunidades",
      "receive_opportunities_desc" => "Encontre vagas que combinam com seu perfil e experiência.",
      "platforms" => "Plataformas suportadas",
      "title" => "Encontre vagas de emprego automaticamente",
      "subtitle" =>
        "Automatize sua busca de vagas em múltiplas plataformas como LinkedIn, Indeed e Gupy. Configure seus perfis e interesses para receber oportunidades personalizadas.",
      "process_resume" => "Processar Currículo",
      "upload_pdf" => "Arraste o PDF aqui"
    },
    "en" => %{
      "home" => "Home",
      "search" => "Search Jobs",
      "settings" => "Settings",
      "profiles" => "Profiles/Resumes",
      "create_profile" => "Create first profile",
      "new_profile" => "+ New Profile",
      "profile_name" => "Profile name",
      "keywords" => "Keywords",
      "technologies" => "Technologies",
      "roles" => "Roles",
      "languages" => "Languages",
      "add_language" => "Select...",
      "portuguese" => "Portuguese",
      "english" => "English",
      "spanish" => "Spanish",
      "french" => "French",
      "german" => "German",
      "italian" => "Italian",
      "chinese" => "Chinese",
      "japanese" => "Japanese",
      "korean" => "Korean",
      "arabic" => "Arabic",
      "russian" => "Russian",
      "hindi" => "Hindi",
      "general_settings" => "General Settings",
      "location" => "Default location",
      "time_posted" => "Time posted",
      "work_type" => "Work type",
      "last_hour" => "Past hour",
      "last_24h" => "Past 24 hours",
      "last_week" => "Past week",
      "last_month" => "Past month",
      "all" => "All",
      "remote" => "Remote",
      "on_site" => "On-site",
      "hybrid" => "Hybrid",
      "work_config" => "Work Type Configuration",
      "on_site_config" => "On-site",
      "hybrid_config" => "Hybrid",
      "remote_config" => "Remote",
      "max_distance" => "Max distance (km)",
      "countries" => "Countries",
      "import_resume" => "Import Resume",
      "help" => "? Help",
      "close_help" => "✕ Close",
      "how_to_export" => "How to export your LinkedIn resume:",
      "save_all" => "Save all",
      "find_jobs" => "Find Jobs",
      "configure_profile" => "Configure Profile",
      "how_it_works" => "How it works",
      "create_profile_step" => "Create your profile",
      "create_profile_desc" => "Configure your interests, technologies and areas of expertise.",
      "auto_search" => "Automatic search",
      "auto_search_desc" => "The system searches across multiple platforms simultaneously.",
      "receive_opportunities" => "Receive opportunities",
      "receive_opportunities_desc" => "Find jobs that match your profile and experience.",
      "platforms" => "Supported platforms",
      "title" => "Find jobs automatically",
      "subtitle" =>
        "Automate your job search across multiple platforms like LinkedIn, Indeed and Gupy. Configure your profiles and interests to receive personalized opportunities.",
      "process_resume" => "Process Resume",
      "upload_pdf" => "Drag PDF here"
    },
    "es" => %{
      "home" => "Inicio",
      "search" => "Buscar Empleos",
      "settings" => "Configuración",
      "profiles" => "Perfiles/Currículum",
      "create_profile" => "Crear primer perfil",
      "new_profile" => "+ Nuevo Perfil",
      "profile_name" => "Nombre del perfil",
      "keywords" => "Palabras clave",
      "technologies" => "Tecnologías",
      "roles" => "Cargos",
      "languages" => "Idiomas",
      "add_language" => "Seleccionar...",
      "portuguese" => "Portugués",
      "english" => "Inglés",
      "spanish" => "Español",
      "french" => "Francés",
      "german" => "Alemán",
      "italian" => "Italiano",
      "chinese" => "Chino",
      "japanese" => "Japonés",
      "korean" => "Coreano",
      "arabic" => "Árabe",
      "russian" => "Ruso",
      "hindi" => "Hindi",
      "general_settings" => "Configuración General",
      "location" => "Ubicación predeterminada",
      "time_posted" => "Tiempo publicado",
      "work_type" => "Tipo de trabajo",
      "last_hour" => "Última hora",
      "last_24h" => "Últimas 24 horas",
      "last_week" => "Última semana",
      "last_month" => "Último mes",
      "all" => "Todos",
      "remote" => "Remoto",
      "on_site" => "Presencial",
      "hybrid" => "Híbrido",
      "work_config" => "Configuración por Tipo de Trabajo",
      "on_site_config" => "Presencial",
      "hybrid_config" => "Híbrido",
      "remote_config" => "Remoto",
      "max_distance" => "Distancia máx (km)",
      "countries" => "Países",
      "import_resume" => "Importar Currículum",
      "help" => "? Ayuda",
      "close_help" => "✕ Cerrar",
      "how_to_export" => "Cómo exportar tu currículum de LinkedIn:",
      "save_all" => "Guardar todo",
      "find_jobs" => "Buscar Empleos",
      "configure_profile" => "Configurar Perfil",
      "how_it_works" => "Cómo funciona",
      "create_profile_step" => "Crea tu perfil",
      "create_profile_desc" => "Configura tus intereses, tecnologías y áreas de actuación.",
      "auto_search" => "Búsqueda automática",
      "auto_search_desc" => "El sistema busca en múltiples plataformas simultáneamente.",
      "receive_opportunities" => "Recibe oportunidades",
      "receive_opportunities_desc" =>
        "Encuentra empleos que combinen con tu perfil y experiencia.",
      "platforms" => "Plataformas soportadas",
      "title" => "Encuentra empleos automáticamente",
      "subtitle" =>
        "Automatiza tu búsqueda de empleos en múltiples plataformas como LinkedIn, Indeed y Gupy. Configura tus perfiles e intereses para recibir oportunidades personalizadas.",
      "process_resume" => "Procesar Currículum",
      "upload_pdf" => "Arrastra el PDF aquí"
    }
  }

  @language_options %{
    "pt" => [
      {"Português", "portuguese"},
      {"Inglês", "english"},
      {"Espanhol", "spanish"},
      {"Francês", "french"},
      {"Alemão", "german"},
      {"Italiano", "italian"},
      {"Chinês", "chinese"},
      {"Japonês", "japanese"},
      {"Coreano", "korean"},
      {"Árabe", "arabic"},
      {"Russo", "russian"},
      {"Hindi", "hindi"}
    ],
    "en" => [
      {"Portuguese", "portuguese"},
      {"English", "english"},
      {"Spanish", "spanish"},
      {"French", "french"},
      {"German", "german"},
      {"Italian", "italian"},
      {"Chinese", "chinese"},
      {"Japanese", "japanese"},
      {"Korean", "korean"},
      {"Arabic", "arabic"},
      {"Russian", "russian"},
      {"Hindi", "hindi"}
    ],
    "es" => [
      {"Portugués", "portuguese"},
      {"Inglés", "english"},
      {"Español", "spanish"},
      {"Francés", "french"},
      {"Alemán", "german"},
      {"Italiano", "italian"},
      {"Chino", "chinese"},
      {"Japonés", "japanese"},
      {"Coreano", "korean"},
      {"Árabe", "arabic"},
      {"Ruso", "russian"},
      {"Hindi", "hindi"}
    ]
  }

  @time_options %{
    "pt" => [
      {"Última hora", "r3600"},
      {"Últimas 24 horas", "r86400"},
      {"Última semana", "r604800"},
      {"Último mês", "r2592000"}
    ],
    "en" => [
      {"Past hour", "r3600"},
      {"Past 24 hours", "r86400"},
      {"Past week", "r604800"},
      {"Past month", "r2592000"}
    ],
    "es" => [
      {"Última hora", "r3600"},
      {"Últimas 24 horas", "r86400"},
      {"Última semana", "r604800"},
      {"Último mes", "r2592000"}
    ]
  }

  @work_options %{
    "pt" => [
      {"Todos", "all"},
      {"Remoto", "remote"},
      {"Presencial", "on_site"},
      {"Híbrido", "hybrid"}
    ],
    "en" => [
      {"All", "all"},
      {"Remote", "remote"},
      {"On-site", "on_site"},
      {"Hybrid", "hybrid"}
    ],
    "es" => [
      {"Todos", "all"},
      {"Remoto", "remote"},
      {"Presencial", "on_site"},
      {"Híbrido", "hybrid"}
    ]
  }

  @source_options %{
    "pt" => [
      {"Todas", "all"},
      {"LinkedIn", "linkedin"},
      {"Indeed", "indeed"},
      {"Gupy", "gupy"}
    ],
    "en" => [
      {"All", "all"},
      {"LinkedIn", "linkedin"},
      {"Indeed", "indeed"},
      {"Gupy", "gupy"}
    ],
    "es" => [
      {"Todas", "all"},
      {"LinkedIn", "linkedin"},
      {"Indeed", "indeed"},
      {"Gupy", "gupy"}
    ]
  }

  @doc """
  Detecta o idioma do navegador e retorna o código.
  Aceita Plug.Conn ou Phoenix.LiveView.Socket
  """
  def detect_language(conn_or_socket)

  def detect_language(%Phoenix.LiveView.Socket{} = socket) do
    case Map.get(socket.private, :conn) do
      nil -> "pt"
      conn -> detect_language(conn)
    end
  rescue
    _ -> "pt"
  end

  def detect_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [header | _] -> parse_accept_language(header)
      _ -> "pt"
    end
  end

  defp parse_accept_language(header) when is_binary(header) do
    header
    |> String.split(",")
    |> List.first()
    |> String.split("-")
    |> List.first()
    |> then(fn lang ->
      if lang in ["pt", "en", "es"], do: lang, else: "pt"
    end)
  end

  defp parse_accept_language(_), do: "pt"

  @doc """
  Retorna a tradução para uma chave no idioma detectado.
  """
  def t(locale, key) do
    @translations
    |> get_in([locale, key])
    |> then(&(&1 || @translations["pt"][key]))
  end

  @doc """
  Retorna todas as traduções para um idioma.
  """
  def allTranslations(locale) do
    @translations[locale] || @translations["pt"]
  end

  @doc """
  Retorna opções de idiomas para o select.
  """
  def language_options(locale) do
    @language_options[locale] || @language_options["pt"]
  end

  @doc """
  Retorna opções de tempo para o select.
  """
  def time_options(locale) do
    @time_options[locale] || @time_options["pt"]
  end

  @doc """
  Retorna opções de tipo de trabalho para o select.
  """
  def work_options(locale) do
    @work_options[locale] || @work_options["pt"]
  end

  @doc """
  Retorna opções de fonte para o select.
  """
  def source_options(locale) do
    @source_options[locale] || @source_options["pt"]
  end
end
