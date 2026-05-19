require "net/http"
require "json"

class GeminiAnalysisService
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent".freeze

  def initialize(dados)
    @dados = dados
  end

  def analisar
    response = chamar_gemini(montar_prompt)
    extrair_texto(response)
  rescue => e
    Rails.logger.error("[GeminiAnalysisService] Erro: #{e.message}")
    analise_fallback
  end

  private

  def chamar_gemini(prompt)
    uri = URI("#{GEMINI_URL}?key=#{ENV.fetch('GEMINI_API_KEY')}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = JSON.generate({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 2048
      }
    })

    http.request(request)
  end

  def extrair_texto(response)
    body = JSON.parse(response.body)
    body.dig("candidates", 0, "content", "parts", 0, "text") || analise_fallback
  rescue JSON::ParserError
    analise_fallback
  end

  def analise_fallback
    "Não foi possível gerar a análise automática no momento. Os dados quantitativos do relatório foram gerados com sucesso."
  end

  def montar_prompt
    d = @dados
    aluno = d[:aluno]
    geral = d[:desempenho_geral]
    tipos = d[:desempenho_por_tipo]
    evolucao = d[:evolucao_semanal]
    habitos = d[:habitos_de_uso]
    sinais = d[:sinais_de_dificuldade]

    <<~PROMPT
      Você é um assistente pedagógico especializado em educação inclusiva, com foco em alunos com dislexia e TDAH.
      Analise os dados de desempenho do aluno abaixo e gere um relatório completo em português brasileiro,
      com linguagem clara e acessível para professores sem formação técnica.

      === DADOS DO ALUNO ===
      Nome: #{aluno[:nome]}
      Turma: #{aluno[:turma]}
      Perfil de acessibilidade: #{aluno[:perfil_acessibilidade] || "não informado"}
      Nível atual: #{aluno[:nivel]} (#{aluno[:nome_nivel]})
      XP total acumulado: #{aluno[:xp_total]}
      Sequência atual de dias: #{aluno[:sequencia_dias]} dias consecutivos
      Membro desde: #{aluno[:membro_desde]}

      === DESEMPENHO GERAL ===
      Total de missões concluídas: #{geral[:total_missoes]}
      Missões nos últimos 7 dias: #{geral[:missoes_ultimos_7_dias]}
      Missões nos últimos 30 dias: #{geral[:missoes_ultimos_30_dias]}
      Média geral de pontuação: #{geral[:media_pontuacao]} pontos
      Tempo total dedicado: #{geral[:tempo_total_minutos]} minutos
      Tempo médio por missão: #{geral[:media_tempo_por_missao_segundos]} segundos
      Última atividade registrada: #{geral[:ultima_atividade] || "nenhuma"}

      === DESEMPENHO POR TIPO DE MISSÃO ===
      LEITURA:
        Total: #{tipos[:leitura][:total]} missões
        Média de pontuação: #{tipos[:leitura][:media_pontuacao]} pontos
        Tempo médio: #{tipos[:leitura][:media_tempo_segundos]} segundos
        XP ganho: #{tipos[:leitura][:xp_ganho]}
        Atividades com mais dificuldade: #{formatar_atividades_dificeis(tipos[:leitura][:atividades_mais_dificeis])}

      FOCO:
        Total: #{tipos[:foco][:total]} missões
        Média de pontuação: #{tipos[:foco][:media_pontuacao]} pontos
        Tempo médio: #{tipos[:foco][:media_tempo_segundos]} segundos
        XP ganho: #{tipos[:foco][:xp_ganho]}
        Atividades com mais dificuldade: #{formatar_atividades_dificeis(tipos[:foco][:atividades_mais_dificeis])}

      DESAFIO:
        Total: #{tipos[:desafio][:total]} missões
        Média de pontuação: #{tipos[:desafio][:media_pontuacao]} pontos
        Tempo médio: #{tipos[:desafio][:media_tempo_segundos]} segundos
        XP ganho: #{tipos[:desafio][:xp_ganho]}
        Atividades com mais dificuldade: #{formatar_atividades_dificeis(tipos[:desafio][:atividades_mais_dificeis])}

      === EVOLUÇÃO NAS ÚLTIMAS 4 SEMANAS ===
      #{formatar_evolucao(evolucao[:por_semana])}
      Tendência geral: #{evolucao[:tendencia]}

      === HÁBITOS DE USO ===
      Total de sessões: #{habitos[:total_sessoes]}
      Dias com atividade registrada: #{habitos[:dias_ativos_total]}
      Dias sem atividade no período: #{habitos[:dias_sem_atividade]}
      Dias inativo até hoje: #{habitos[:dias_inativo_ate_hoje] || "não calculado"}
      Horário mais ativo: #{habitos[:hora_mais_ativa]}
      Dia da semana mais ativo: #{habitos[:dia_semana_mais_ativo]}
      Primeiro acesso: #{habitos[:primeiro_acesso] || "não registrado"}
      Último acesso: #{habitos[:ultimo_acesso] || "não registrado"}

      === SINAIS DE DIFICULDADE IDENTIFICADOS ===
      #{sinais.map.with_index(1) { |s, i| "#{i}. #{s}" }.join("\n")}

      === INSTRUÇÕES PARA O RELATÓRIO ===
      Gere um relatório pedagógico com as seguintes seções, usando exatamente esses títulos:

      RESUMO EXECUTIVO
      Escreva 2 a 3 parágrafos resumindo o perfil geral do aluno, seu engajamento e evolução recente.
      Use linguagem humana e empática, como se estivesse conversando com o professor.

      ANÁLISE POR TIPO DE MISSÃO
      Para cada tipo (leitura, foco e desafio), escreva um parágrafo interpretando o desempenho.
      Compare os tipos entre si e destaque onde o aluno se sai melhor e onde tem mais dificuldade.

      PADRÕES DE COMPORTAMENTO E USO
      Interprete os hábitos de uso: horários, dias da semana, frequência, períodos de inatividade.
      Identifique padrões que possam indicar motivação, cansaço ou dificuldades externas.

      SINAIS DE ATENÇÃO
      Liste e explique os sinais que merecem atenção do professor.
      Se não houver sinais críticos, valorize os pontos positivos.

      RECOMENDAÇÕES PEDAGÓGICAS
      