class StudentReportDataService
  def initialize(aluno, turma)
    @aluno = aluno
    @turma = turma
  end

  def coletar
    {
      aluno: dados_aluno,
      desempenho_geral: desempenho_geral,
      desempenho_por_tipo: desempenho_por_tipo,
      evolucao_semanal: evolucao_semanal,
      habitos_de_uso: habitos_de_uso,
      sinais_de_dificuldade: sinais_de_dificuldade
    }
  end

  private

  def todas_tentativas
    @todas_tentativas ||= @aluno.tentativas.includes(:atividade).order(:concluida_em)
  end

  def dados_aluno
    {
      nome: @aluno.name,
      turma: @turma.nome,
      nivel: @aluno.nivel,
      nome_nivel: User::NIVEIS[@aluno.nivel][:nome],
      xp_total: @aluno.xp_total,
      sequencia_dias: @aluno.sequencia_dias,
      perfil_acessibilidade: @aluno.perfil_acessibilidade,
      membro_desde: @aluno.created_at.strftime("%d/%m/%Y")
    }
  end

  def desempenho_geral
    return dados_vazios_geral if todas_tentativas.empty?

    {
      total_missoes: todas_tentativas.count,
      xp_total_ganho: todas_tentativas.sum(:xp_ganho),
      tempo_total_minutos: (todas_tentativas.sum(:tempo_gasto) / 60.0).round(1),
      media_pontuacao: todas_tentativas.average(:pontuacao).to_f.round(1),
      media_tempo_por_missao_segundos: todas_tentativas.average(:tempo_gasto).to_f.round(0).to_i,
      missoes_ultimos_7_dias: todas_tentativas.da_semana.count,
      missoes_ultimos_30_dias: todas_tentativas.where(concluida_em: 30.days.ago..).count,
      ultima_atividade: todas_tentativas.last&.concluida_em&.strftime("%d/%m/%Y às %H:%M")
    }
  end

  def dados_vazios_geral
    {
      total_missoes: 0, xp_total_ganho: 0, tempo_total_minutos: 0,
      media_pontuacao: 0, media_tempo_por_missao_segundos: 0,
      missoes_ultimos_7_dias: 0, missoes_ultimos_30_dias: 0,
      ultima_atividade: nil
    }
  end

  def desempenho_por_tipo
    %w[leitura foco desafio].each_with_object({}) do |tipo, hash|
      tentativas_tipo = todas_tentativas.select { |t| t.tipo_missao == tipo }
      next hash[tipo] = tipo_vazio if tentativas_tipo.empty?

      hash[tipo] = {
        total: tentativas_tipo.count,
        media_pontuacao: (tentativas_tipo.sum(&:pontuacao).to_f / tentativas_tipo.count).round(1),
        media_tempo_segundos: (tentativas_tipo.sum(&:tempo_gasto).to_f / tentativas_tipo.count).round(0).to_i,
        xp_ganho: tentativas_tipo.sum(&:xp_ganho),
        atividades_mais_dificeis: atividades_mais_dificeis(tentativas_tipo)
      }
    end
  end

  def tipo_vazio
    { total: 0, media_pontuacao: 0, media_tempo_segundos: 0, xp_ganho: 0, atividades_mais_dificeis: [] }
  end

  def atividades_mais_dificeis(tentativas_tipo)
    tentativas_tipo
      .group_by { |t| t.atividade&.titulo || "Atividade desconhecida" }
      .map { |titulo, ts| { titulo: titulo, media_pontuacao: (ts.sum(&:pontuacao).to_f / ts.count).round(1), tentativas: ts.count } }
      .sort_by { |a| a[:media_pontuacao] }
      .first(3)
  end

  def evolucao_semanal
    ultimas_4_semanas = (0..3).map do |semanas_atras|
      inicio = semanas_atras.weeks.ago.beginning_of_week
      fim    = semanas_atras.weeks.ago.end_of_week
      ts     = todas_tentativas.select { |t| t.concluida_em.between?(inicio, fim) }

      {
        semana: inicio.strftime("%d/%m"),
        missoes: ts.count,
        xp: ts.sum(&:xp_ganho),
        media_pontuacao: ts.empty? ? 0 : (ts.sum(&:pontuacao).to_f / ts.count).round(1)
      }
    end.reverse

    {
      por_semana: ultimas_4_semanas,
      tendencia: calcular_tendencia(ultimas_4_semanas)
    }
  end

  def calcular_tendencia(semanas)
    xps = semanas.map { |s| s[:xp] }
    return "sem dados suficientes" if xps.compact.sum == 0

    metade1 = xps.first(2).sum
    metade2 = xps.last(2).sum

    if metade2 > metade1 * 1.1
      "crescente"
    elsif metade2 < metade1 * 0.9
      "decrescente"
    else
      "estável"
    end
  end

  def habitos_de_uso
    sessions = @aluno.sessions.order(:created_at)
    tentativas_com_data = todas_tentativas.reject { |t| t.concluida_em.nil? }

    dias_ativos = tentativas_com_data.map { |t| t.concluida_em.to_date }.uniq.sort

    dias_sem_login = if dias_ativos.any?
      (dias_ativos.last - dias_ativos.first).to_i - dias_ativos.count + 1
    else
      0
    end

    ultimo_login = sessions.last&.created_at
    dias_inativo = ultimo_login ? (Date.today - ultimo_login.to_date).to_i : nil

    horarios = tentativas_com_data.group_by { |t| t.concluida_em.hour }
    hora_mais_ativa = horarios.max_by { |_, ts| ts.count }&.first

    dias_semana = tentativas_com_data.group_by { |t| t.concluida_em.wday }
    dia_mais_ativo_num = dias_semana.max_by { |_, ts| ts.count }&.first
    dia_mais_ativo = dia_nome(dia_mais_ativo_num)

    {
      total_sessoes: sessions.count,
      dias_ativos_total: dias_ativos.count,
      dias_sem_atividade: dias_sem_login,
      dias_inativo_ate_hoje: dias_inativo,
      hora_mais_ativa: hora_mais_ativa ? "#{hora_mais_ativa}h" : "não identificada",
      dia_semana_mais_ativo: dia_mais_ativo || "não identificado",
      primeiro_acesso: sessions.first&.created_at&.strftime("%d/%m/%Y"),
      ultimo_acesso: ultimo_login&.strftime("%d/%m/%Y")
    }
  end

  def dia_nome(wday)
    %w[Domingo Segunda Terça Quarta Quinta Sexta Sábado][wday] if wday
  end

  def sinais_de_dificuldade
    sinais = []

    # Tipo com pior desempenho
    por_tipo = desempenho_por_tipo
    pior_tipo = por_tipo.min_by { |_, d| d[:media_pontuacao] > 0 ? d[:media_pontuacao] : Float::INFINITY }
    if pior_tipo && pior_tipo[1][:media_pontuacao] > 0 && pior_tipo[1][:media_pontuacao] < 5
      sinais << "Desempenho abaixo da média em missões de #{pior_tipo[0]} (média #{pior_tipo[1][:media_pontuacao]} pontos)"
    end

    # Inatividade recente
    hab = habitos_de_uso
    if hab[:dias_inativo_ate_hoje] && hab[:dias_inativo_ate_hoje] > 5
      sinais << "Sem acessar o aplicativo há #{hab[:dias_inativo_ate_hoje]} dias"
    end

    # Pouca atividade na semana
    if desempenho_geral[:missoes_ultimos_7_dias] < 3
      sinais << "Menos de 3 missões concluídas nos últimos 7 dias"
    end

    # Tempo muito alto em algum tipo (pode indicar dificuldade)
    por_tipo.each do |tipo, dados|
      if dados[:media_tempo_segundos] > 120 && dados[:total] > 0
        sinais << "Tempo médio elevado nas missões de #{tipo} (#{(dados[:media_tempo_segundos] / 60.0).round(1)} min por missão)"
      end
    end

    sinais.empty? ? [ "Nenhum sinal de dificuldade crítico identificado no período analisado" ] : sinais
  end
end
