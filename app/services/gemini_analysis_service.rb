require "net/http"
require "json"

class GeminiAnalysisService
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent".freeze

  def initialize(dados)
    @dados = dados
  end

  def analisar
  response = chamar_gemini(montar_prompt)
  Rails.logger.info("[Gemini] Status: #{response.code}")
  Rails.logger.info("[Gemini] Body: #{response.body[0..500]}")
  extrair_texto(response)
rescue => e
  Rails.logger.error("[Gemini] Erro: #{e.class}: #{e.message}")
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
      contents: [ { parts: [ { text: prompt } ] } ],
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
    "Nao foi possivel gerar a analise automatica no momento. Os dados quantitativos do relatorio foram gerados com sucesso."
  end

  def montar_prompt
    d = @dados
    aluno = d[:aluno]
    geral = d[:desempenho_geral]
    tipos = d[:desempenho_por_tipo]
    evolucao = d[:evolucao_semanal]
    habitos = d[:habitos_de_uso]
    sinais = d[:sinais_de_dificuldade]

    prompt = "Voce e um assistente pedagogico especializado em educacao inclusiva, com foco em alunos com dislexia e TDAH.\n"
    prompt += "Analise os dados de desempenho do aluno abaixo e gere um relatorio completo em portugues brasileiro,\n"
    prompt += "com linguagem clara e acessivel para professores sem formacao tecnica.\n\n"

    prompt += "=== DADOS DO ALUNO ===\n"
    prompt += "Nome: #{aluno[:nome]}\n"
    prompt += "Turma: #{aluno[:turma]}\n"
    prompt += "Perfil de acessibilidade: #{aluno[:perfil_acessibilidade] || 'nao informado'}\n"
    prompt += "Nivel atual: #{aluno[:nivel]} (#{aluno[:nome_nivel]})\n"
    prompt += "XP total acumulado: #{aluno[:xp_total]}\n"
    prompt += "Sequencia atual de dias: #{aluno[:sequencia_dias]} dias consecutivos\n"
    prompt += "Membro desde: #{aluno[:membro_desde]}\n\n"

    prompt += "=== DESEMPENHO GERAL ===\n"
    prompt += "Total de missoes concluidas: #{geral[:total_missoes]}\n"
    prompt += "Missoes nos ultimos 7 dias: #{geral[:missoes_ultimos_7_dias]}\n"
    prompt += "Missoes nos ultimos 30 dias: #{geral[:missoes_ultimos_30_dias]}\n"
    prompt += "Media geral de pontuacao: #{geral[:media_pontuacao]} pontos\n"
    prompt += "Tempo total dedicado: #{geral[:tempo_total_minutos]} minutos\n"
    prompt += "Tempo medio por missao: #{geral[:media_tempo_por_missao_segundos]} segundos\n"
    prompt += "Ultima atividade registrada: #{geral[:ultima_atividade] || 'nenhuma'}\n\n"

    prompt += "=== DESEMPENHO POR TIPO DE MISSAO ===\n"
    [ "leitura", "foco", "desafio" ].each do |tipo|
      d_tipo = tipos[tipo.to_sym] || tipos[tipo]
      next unless d_tipo
      prompt += "#{tipo.upcase}:\n"
      prompt += "  Total: #{d_tipo[:total]} missoes\n"
      prompt += "  Media de pontuacao: #{d_tipo[:media_pontuacao]} pontos\n"
      prompt += "  Tempo medio: #{d_tipo[:media_tempo_segundos]} segundos\n"
      prompt += "  XP ganho: #{d_tipo[:xp_ganho]}\n"
      dificeis = formatar_atividades_dificeis(d_tipo[:atividades_mais_dificeis])
      prompt += "  Atividades com mais dificuldade: #{dificeis}\n\n"
    end

    prompt += "=== EVOLUCAO NAS ULTIMAS 4 SEMANAS ===\n"
    evolucao[:por_semana].each do |s|
      prompt += "Semana de #{s[:semana]}: #{s[:missoes]} missoes, #{s[:xp]} XP, media #{s[:media_pontuacao]} pts\n"
    end
    prompt += "Tendencia geral: #{evolucao[:tendencia]}\n\n"

    prompt += "=== HABITOS DE USO ===\n"
    prompt += "Total de sessoes: #{habitos[:total_sessoes]}\n"
    prompt += "Dias com atividade registrada: #{habitos[:dias_ativos_total]}\n"
    prompt += "Dias sem atividade no periodo: #{habitos[:dias_sem_atividade]}\n"
    prompt += "Dias inativo ate hoje: #{habitos[:dias_inativo_ate_hoje] || 'nao calculado'}\n"
    prompt += "Horario mais ativo: #{habitos[:hora_mais_ativa]}\n"
    prompt += "Dia da semana mais ativo: #{habitos[:dia_semana_mais_ativo]}\n"
    prompt += "Primeiro acesso: #{habitos[:primeiro_acesso] || 'nao registrado'}\n"
    prompt += "Ultimo acesso: #{habitos[:ultimo_acesso] || 'nao registrado'}\n\n"

    prompt += "=== SINAIS DE DIFICULDADE IDENTIFICADOS ===\n"
    sinais.each_with_index do |s, i|
      prompt += "#{i + 1}. #{s}\n"
    end
    prompt += "\n"

    prompt += "=== INSTRUCOES PARA O RELATORIO ===\n"
    prompt += "Gere um relatorio pedagogico com as seguintes secoes, usando exatamente esses titulos:\n\n"
    prompt += "RESUMO EXECUTIVO\n"
    prompt += "Escreva 2 a 3 paragrafos resumindo o perfil geral do aluno, seu engajamento e evolucao recente.\n\n"
    prompt += "ANALISE POR TIPO DE MISSAO\n"
    prompt += "Para cada tipo (leitura, foco e desafio), escreva um paragrafo interpretando o desempenho.\n\n"
    prompt += "PADROES DE COMPORTAMENTO E USO\n"
    prompt += "Interprete os habitos de uso: horarios, dias da semana, frequencia, periodos de inatividade.\n\n"
    prompt += "SINAIS DE ATENCAO\n"
    prompt += "Liste e explique os sinais que merecem atencao do professor.\n\n"
    prompt += "RECOMENDACOES PEDAGOGICAS\n"
    prompt += "De de 3 a 5 recomendacoes praticas e especificas para o professor,\n"
    prompt += "levando em conta o perfil de acessibilidade do aluno (#{aluno[:perfil_acessibilidade] || 'nao informado'}).\n\n"
    prompt += "CONCLUSAO\n"
    prompt += "Finalize com uma mensagem encorajadora sobre o progresso do aluno.\n\n"
    prompt += "Escreva em portugues brasileiro. Seja especifico, use os numeros dos dados fornecidos.\n"
    prompt += "Nao invente dados que nao foram fornecidos. Seja empatico e construtivo.\n"

    prompt
  end

  def formatar_atividades_dificeis(atividades)
    return "nenhuma registrada" if atividades.blank?
    atividades.map { |a| "#{a[:titulo]} (media #{a[:media_pontuacao]} pts em #{a[:tentativas]} tentativa(s))" }.join(", ")
  end
end
