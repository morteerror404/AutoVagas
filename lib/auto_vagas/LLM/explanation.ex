defmodule AutoVagas.AI.Explanation do
  @moduledoc """
  Gera explicações para habilidades, certificações e cursos.
  Usa IA para interpretar desafios (como Hack The Box) e gerar contexto.
  """

  @doc """
  Atualiza habilidades com explicações geradas por IA.
  """
  def update_skills_with_explanations(user_info) do
    skills = Map.get(user_info, "skills", %{})

    updated = skills
              |> update_technical_with_ai()
              |> update_soft_with_ai()
              |> update_certifications_with_ai()
              |> update_courses_with_ai()
              |> update_hack_the_box_with_ai()

    updated_user_info = Map.put(user_info, "skills", updated)
    {:ok, updated_user_info}
  end

  defp update_technical_with_ai(skills) do
    technical = Map.get(skills, "technical", [])

    updated_technical = Enum.map(technical, fn skill ->
      if Map.get(skill, "explanation") do
        skill
      else
        explanation = generate_technical_explanation(skill)
        Map.put(skill, "explanation", explanation)
      end
    end)

    Map.put(skills, "technical", updated_technical)
  end

  defp update_soft_with_ai(skills) do
    soft = Map.get(skills, "soft", [])

    updated_soft = Enum.map(soft, fn skill ->
      if Map.get(skill, "explanation") do
        skill
      else
        explanation = generate_soft_explanation(skill)
        Map.put(skill, "explanation", explanation)
      end
    end)

    Map.put(skills, "soft", updated_soft)
  end

  defp update_certifications_with_ai(skills) do
    certs = Map.get(skills, "certifications", [])

    updated_certs = Enum.map(certs, fn cert ->
      if Map.get(cert, "explanation") do
        cert
      else
        explanation = generate_certification_explanation(cert)
        Map.put(cert, "explanation", explanation)
      end
    end)

    Map.put(skills, "certifications", updated_certs)
  end

  defp update_courses_with_ai(skills) do
    courses = Map.get(skills, "courses", [])

    updated_courses = Enum.map(courses, fn course ->
      if Map.get(course, "explanation") do
        course
      else
        explanation = generate_course_explanation(course)
        Map.put(course, "explanation", explanation)
      end
    end)

    Map.put(skills, "courses", updated_courses)
  end

  defp update_hack_the_box_with_ai(skills) do
    htb = Map.get(skills, "hack_the_box", [])

    updated_htb = Enum.map(htb, fn challenge ->
      if Map.get(challenge, "explanation") do
        challenge
      else
        explanation = generate_htb_explanation(challenge)
        Map.put(challenge, "explanation", explanation)
      end
    end)

    Map.put(skills, "hack_the_box", updated_htb)
  end

  defp generate_technical_explanation(skill) do
    prompt = """
    Explique a habilidade técnica abaixo em 2-3 frases, destacando sua importância e aplicação prática.

    Habilidade: #{skill["name"]}
    Nível: #{skill["level"] || "Intermediário"}
    Anos de experiência: #{skill["years"] || "N/A"}

    Responda de forma concisa e profissional.
    """

    case AI.analyze_resume(prompt, task: "explain_skill") do
      {:ok, text} -> String.trim(text)
      {:error, _} -> "Explicação não disponível"
    end
  end

  defp generate_soft_explanation(skill) do
    prompt = """
    Explique a habilidade comportamental abaixo em 2-3 frases, destacando sua importância no ambiente de trabalho.

    Habilidade: #{skill["name"]}
    Nível: #{skill["level"] || "Intermediário"}

    Responda de forma concisa e profissional.
    """

    case AI.analyze_resume(prompt, task: "explain_skill") do
      {:ok, text} -> String.trim(text)
      {:error, _} -> "Explicação não disponível"
    end
  end

  defp generate_certification_explanation(cert) do
    prompt = """
    Explique a certificação abaixo em 2-3 frases, destacando sua relevância e o que ela valida.

    Certificação: #{cert["name"]}
    Emissor: #{cert["issuer"] || "N/A"}
    Ano: #{cert["year"] || "N/A"}

    Responda de forma concisa e profissional.
    """

    case AI.analyze_resume(prompt, task: "explain_certification") do
      {:ok, text} -> String.trim(text)
      {:error, _} -> "Explicação não disponível"
    end
  end

  defp generate_course_explanation(course) do
    prompt = """
    Explique o curso abaixo em 2-3 frases, destacando o que foi aprendido e sua aplicação.

    Curso: #{course["name"]}
    Plataforma: #{course["platform"] || "N/A"}
    Ano: #{course["year"] || "N/A"}

    Responda de forma concisa e profissional.
    """

    case AI.analyze_resume(prompt, task: "explain_course") do
      {:ok, text} -> String.trim(text)
      {:error, _} -> "Explicação não disponível"
    end
  end

  defp generate_htb_explanation(challenge) do
    prompt = """
    Analise o desafio do Hack The Box abaixo e explique o que ele demonstra sobre as competências do profissional.
    Considere o nível de dificuldade e o que foi necessário para completá-lo.

    Desafio: #{challenge["name"]}
    Nível: #{challenge["level"] || "N/A"}
    Completado em: #{challenge["completed"] || "N/A"}

    Responda em 2-3 frases, destacando as competências técnicas validadas por este desafio.
    """

    case AI.analyze_resume(prompt, task: "explain_htb") do
      {:ok, text} -> String.trim(text)
      {:error, _} -> "Explicação não disponível"
    end
  end

  @doc """
  Alterna a inclusão de explicações para um tipo de habilidade.
  """
  def toggle_explanations(user_info, type, include) do
    path = ["skills", type, "include_explanations"]
    updated = put_in(user_info, path, include)
    UserInfo.save(updated)
    updated
  end

  @doc """
  Verifica se explicações estão ativadas para um tipo de habilidade.
  """
  def explanations_enabled?(user_info, type) do
    get_in(user_info, ["skills", type, "include_explanations"]) || false
  end
end
