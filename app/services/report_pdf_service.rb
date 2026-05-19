require "prawn"
require "prawn/table"

class ReportPdfService
  # Paleta de cores do Focus
  AZUL        = "2C4A7C"
  AZUL_CLARO  = "4A6FA5"
  VERDE       = "4A8C5C"
  BEGE        = "F5F0E8"
  BEGE_CARD   = "EDE8DF"
  MARROM      = "7A726C"
  DOURADO     = "9C7A2E"
  ESCURO      = "2A2520"
  BRANCO      = "FFFFFF"

  def initialize(dados, analise_gemini)
    @dados   = dados
    @analise = analise_gemini
    @aluno   = dados[:aluno]
    @geral   = dados[:desempenho_geral]
    @tipos   = dados[:desempenho_por_tipo]
    @evolucao = dados[:evolucao_semanal]
    @habitos = dados[:habitos_de_uso]
    @sinais  = dados[:sinais_de_dificuldade]
  end

  def gerar
    pdf = Prawn::Document.new(
      page_size: "A4",
      margin: [40, 50, 40, 50],
      info: {
        Title: "Relatório Focus — #{@aluno[:nome]}",
        Author: "Plataforma Focus",
        CreationDate: Time.current
      }
    )

    definir_fontes(pdf)
    pagina_capa(pdf)
    pdf.start_new_page
    secao_resumo_executivo(pdf)
    secao_kpis(pdf)
    secao_desempenho_por_tipo(pdf)
    secao_evolucao(pdf)
    secao_habitos(pdf)
    secao_sinais(pdf)
    secao_analise_gemini(pdf)
    secao_recomendacoes(pdf)
    rodape(pdf)

    pdf.render
  end

  private

  # ── FONTES ──────────────────────────────────────────────────────────────────

  def definir_fontes(pdf)
    pdf.font_families.update(
      "Helvetica" => {
        normal: "Helvetica",
        bold: "Helvetica-Bold",
        italic: "Helvetica-Oblique",
        bold_italic: "Helvetica-BoldOblique"
      }
    )
    pdf.font "Helvetica"
  end

  # ── CAPA ────────────────────────────────────────────────────────────────────

  def pagina_capa(pdf)
    # Fundo azul escuro
    pdf.fill_color AZUL
    pdf.fill_rectangle [pdf.bounds.left - 50, pdf.bounds.top + 40],
                       pdf.bounds.width + 100, pdf.bounds.height + 80
    pdf.fill_color BRANCO

    pdf.move_down 80

    # Logo / título da plataforma
    pdf.font("Helvetica", style: :bold, size: 13) do
      pdf.fill_color "B0C4DE"
      pdf.text "PLATAFORMA FOCUS", align: :center, character_spacing: 3
    end

    pdf.move_down 12

    # Linha decorativa
    pdf.fill_color AZUL_CLARO
    pdf.fill_rectangle [pdf.bounds.width / 2 - 30, pdf.cursor], 60, 3
    pdf.fill_color BRANCO

    pdf.move_down 40

    # Título principal
    pdf.font("Helvetica", style: :bold, size: 28) do
      pdf.fill_color BRANCO
      pdf.text "Relatório de", align: :center
      pdf.text "Desempenho do Aluno", align: :center
    end

    pdf.move_down 24

    # Nome do aluno em destaque
    pdf.fill_color DOURADO
    pdf.fill_rounded_rectangle [pdf.bounds.width / 2 - 150, pdf.cursor], 300, 52, 10
    pdf.fill_color BRANCO
    pdf.move_up 40
    pdf.font("Helvetica", style: :bold, size: 20) do
      pdf.text @aluno[:nome], align: :center
    end
    pdf.move_down 8

    pdf.move_down 40

    # Informações do aluno
    pdf.font("Helvetica", size: 12) do
      pdf.fill_color "D0DCF0"
      pdf.text "Turma: #{@aluno[:turma]}", align: :center
      pdf.move_down 6
      pdf.text "Perfil: #{perfil_label(@aluno[:perfil_acessibilidade])}", align: :center
      pdf.move_down 6
      pdf.text "Membro desde: #{@aluno[:membro_desde]}", align: :center
    end

    pdf.move_down 60

    # Linha divisória
    pdf.fill_color AZUL_CLARO
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, 1

    pdf.move_down 20

    # Data de geração
    pdf.font("Helvetica", size: 10) do
      pdf.fill_color "B0C4DE"
      pdf.text "Relatório gerado em #{Time.current.strftime('%d/%m/%Y às %H:%M')}",
               align: :center
      pdf.move_down 6
      pdf.text "Gerado com inteligência artificial — Plataforma Focus",
               align: :center
    end

    pdf.fill_color ESCURO
  end

  # ── RESUMO EXECUTIVO ─────────────────────────────────────────────────────────

  def secao_resumo_executivo(pdf)
    titulo_secao(pdf, "Resumo Executivo")

    resumo = extrair_secao(@analise, "RESUMO EXECUTIVO")

    if resumo.present?
      pdf.font("Helvetica", size: 10) do
        pdf.fill_color ESCURO
        pdf.text resumo, align: :justify, leading: 4
      end
    else
      texto_padrao_resumo(pdf)
    end

    pdf.move_down 20
  end

  def texto_padrao_resumo(pdf)
    pdf.font("Helvetica", size: 10) do
      pdf.fill_color ESCURO
      texto = "#{@aluno[:nome]} está no nível #{@aluno[:nivel]} (#{@aluno[:nome_nivel]}) " \
              "com #{@aluno[:xp_total]} XP acumulados. " \
              "No total, concluiu #{@geral[:total_missoes]} missões na plataforma, " \
              "sendo #{@geral[:missoes_ultimos_7_dias]} nos últimos 7 dias."
      pdf.text texto, align: :justify, leading: 4
    end
  end

  # ── KPIs ────────────────────────────────────────────────────────────────────

  def secao_kpis(pdf)
    titulo_secao(pdf, "Indicadores Gerais")

    kpis = [
      { label: "Missões\nConcluídas",    valor: @geral[:total_missoes].to_s,                   cor: AZUL_CLARO },
      { label: "XP\nTotal",              valor: @aluno[:xp_total].to_s,                         cor: VERDE },
      { label: "Nível\nAtual",           valor: @aluno[:nivel].to_s,                             cor: DOURADO },
      { label: "Sequência\nde Dias",     valor: "#{@aluno[:sequencia_dias]}d",                  cor: AZUL },
      { label: "Tempo Total\n(min)",     valor: @geral[:tempo_total_minutos].to_s,              cor: MARROM },
      { label: "Média de\nPontuação",    valor: @geral[:media_pontuacao].to_s,                  cor: AZUL_CLARO }
    ]

    card_w = (pdf.bounds.width - 25) / 3.0
    card_h = 70

    kpis.each_slice(3).with_index do |linha, row|
      linha.each_with_index do |kpi, col|
        x = col * (card_w + 12.5)
        y = pdf.cursor

        pdf.fill_color BEGE_CARD
        pdf.fill_rounded_rectangle [x, y], card_w, card_h, 6

        pdf.fill_color kpi[:cor]
        pdf.fill_rounded_rectangle [x, y], card_w, 4, 2

        pdf.bounding_box([x + 8, y - 12], width: card_w - 16) do
          pdf.font("Helvetica", style: :bold, size: 16) do
            pdf.fill_color kpi[:cor]
            pdf.text kpi[:valor]
          end
          pdf.font("Helvetica", size: 8) do
            pdf.fill_color MARROM
            pdf.text kpi[:label]
          end
        end
      end
      pdf.move_down card_h + 10
    end

    pdf.move_down 10
  end

  # ── DESEMPENHO POR TIPO ──────────────────────────────────────────────────────

  def secao_desempenho_por_tipo(pdf)
    titulo_secao(pdf, "Desempenho por Tipo de Missão")

    tipos_config = {
      "leitura" => { label: "Leitura Guiada",  cor: AZUL_CLARO, icone: "L" },
      "foco"    => { label: "Missão de Foco",   cor: VERDE,      icone: "F" },
      "desafio" => { label: "Desafio",          cor: DOURADO,    icone: "D" }
    }

    dados_tabela = [["Tipo", "Missões", "Média Pts", "Tempo Médio", "XP Ganho"]]

    tipos_config.each do |tipo, config|
      d = @tipos[tipo.to_sym] || @tipos[tipo]
      next unless d

      tempo_fmt = d[:media_tempo_segundos] > 0 ? "#{(d[:media_tempo_segundos] / 60.0).round(1)} min" : "—"
      dados_tabela << [
        config[:label],
        d[:total].to_s,
        d[:media_pontuacao].to_s,
        tempo_fmt,
        d[:xp_ganho].to_s
      ]
    end

    pdf.table(dados_tabela,
      width: pdf.bounds.width,
      cell_style: { size: 9, padding: [8, 10], border_color: "D9D0C4" },
      header: true
    ) do |t|
      t.row(0).background_color = AZUL
      t.row(0).text_color = BRANCO
      t.row(0).font_style = :bold
      t.rows(1..-1).background_color = BEGE_CARD
      t.columns(1..4).align = :center
    end

    pdf.move_down 14

    # Análise textual por tipo
    analise_tipos = extrair_secao(@analise, "ANÁLISE POR TIPO DE MISSÃO")
    if analise_tipos.present?
      pdf.font("Helvetica", size: 10) do
        pdf.fill_color ESCURO
        pdf.text analise_tipos, align: :justify, leading: 4
      end
    end

    # Barras visuais de pontuação
    pdf.move_down 14
    pdf.font("Helvetica", style: :bold, size: 10) do
      pdf.fill_color MARROM
      pdf.text "Comparativo visual de pontuação média por tipo:"
    end
    pdf.move_down 8

    max_pts = 10.0
    tipos_config.each do |tipo, config|
      d = @tipos[tipo.to_sym] || @tipos[tipo]
      next unless d && d[:total] > 0

      pct = [(d[:media_pontuacao] / max_pts), 1.0].min
      barra_w = (pdf.bounds.width - 130) * pct

      pdf.font("Helvetica", size: 9) do
        pdf.fill_color ESCURO
        pdf.draw_text config[:label], at: [0, pdf.cursor - 10], size: 9
      end

      pdf.fill_color "E8E0D4"
      pdf.fill_rectangle [130, pdf.cursor - 2], pdf.bounds.width - 130, 14

      pdf.fill_color config[:cor]
      pdf.fill_rectangle [130, pdf.cursor - 2], [barra_w, 1].max, 14

      pdf.fill_color BRANCO
      pdf.draw_text "#{d[:media_pontuacao]} pts", at: [135, pdf.cursor - 11], size: 8

      pdf.move_down 22
    end

    pdf.move_down 10
  end

  # ── EVOLUÇÃO SEMANAL ─────────────────────────────────────────────────────────

  def secao_evolucao(pdf)
    titulo_secao(pdf, "Evolução nas Últimas 4 Semanas")

    semanas = @evolucao[:por_semana]
    return if semanas.blank?

    dados_tabela = [["Semana", "Missões", "XP Ganho", "Média Pts", "Avaliação"]]

    semanas.each do |s|
      avaliacao = if s[:missoes] == 0
        "Inativo"
      elsif s[:media_pontuacao] >= 7
        "Excelente"
      elsif s[:media_pontuacao] >= 5
        "Bom"
      elsif s[:media_pontuacao] >= 3
        "Regular"
      else
        "Abaixo"
      end

      dados_tabela << [
        "Sem. #{s[:semana]}",
        s[:missoes].to_s,
        s[:xp].to_s,
        s[:media_pontuacao].to_s,
        avaliacao
      ]
    end

    pdf.table(dados_tabela,
      width: pdf.bounds.width,
      cell_style: { size: 9, padding: [8, 10], border_color: "D9D0C4" },
      header: true
    ) do |t|
      t.row(0).background_color = AZUL
      t.row(0).text_color = BRANCO
      t.row(0).font_style = :bold
      t.rows(1..-1).background_color = BEGE_CARD
      t.columns(1..4).align = :center
    end

    pdf.move_down 10

    pdf.font("Helvetica", style: :bold, size: 10) do
      pdf.fill_color MARROM
      tendencia_texto = case @evolucao[:tendencia]
      when "crescente"  then "Tendência: Crescente — o aluno está evoluindo."
      when "decrescente" then "Tendência: Decrescente — atenção necessária."
      else "Tendência: Estável — desempenho consistente."
      end
      pdf.text tendencia_texto
    end

    pdf.move_down 20
  end

  # ── HÁBITOS DE USO ───────────────────────────────────────────────────────────

  def secao_habitos(pdf)
    titulo_secao(pdf, "Hábitos de Uso e Frequência")

    dados_tabela = [
      ["Total de sessões",           @habitos[:total_sessoes].to_s],
      ["Dias com atividade",         @habitos[:dias_ativos_total].to_s],
      ["Dias sem atividade",         @habitos[:dias_sem_atividade].to_s],
      ["Dias inativo até hoje",      @habitos[:dias_inativo_ate_hoje]&.to_s || "—"],
      ["Horário mais ativo",         @habitos[:hora_mais_ativa]],
      ["Dia da semana mais ativo",   @habitos[:dia_semana_mais_ativo]],
      ["Primeiro acesso",            @habitos[:primeiro_acesso] || "—"],
      ["Último acesso",              @habitos[:ultimo_acesso] || "—"]
    ]

    pdf.table(dados_tabela,
      width: pdf.bounds.width,
      cell_style: { size: 9, padding: [7, 10], border_color: "D9D0C4" }
    ) do |t|
      t.column(0).background_color = BEGE_CARD
      t.column(0).font_style = :bold
      t.column(0).text_color = AZUL
      t.column(1).background_color = BRANCO
      t.column(1).text_color = ESCURO
    end

    pdf.move_down 14

    habitos_analise = extrair_secao(@analise, "PADRÕES DE COMPORTAMENTO E USO")
    if habitos_analise.present?
      pdf.font("Helvetica", size: 10) do
        pdf.fill_color ESCURO
        pdf.text habitos_analise, align: :justify, leading: 4
      end
    end

    pdf.move_down 20
  end

  # ── SINAIS DE ATENÇÃO ────────────────────────────────────────────────────────

  def secao_sinais(pdf)
    titulo_secao(pdf, "Sinais de Atenção")

    sinais_analise = extrair_secao(@analise, "SINAIS DE ATENÇÃO")

    @sinais.each do |sinal|
      pdf.fill_color DOURADO
      pdf.fill_rounded_rectangle [0, pdf.cursor], pdf.bounds.width, 30, 5

      pdf.bounding_box([12, pdf.cursor - 8], width: pdf.bounds.width - 24) do
        pdf.font("Helvetica", size: 9) do
          pdf.fill_color ESCURO
          pdf.text "⚠  #{sinal}", leading: 2
        end
      end
      pdf.move_down 38
    end

    if sinais_analise.present?
      pdf.move_down 6
      pdf.font("Helvetica", size: 10) do
        pdf.fill_color ESCURO
        pdf.text sinais_analise, align: :justify, leading: 4
      end
    end

    pdf.move_down 20
  end

  # ── ANÁLISE GEMINI COMPLETA ──────────────────────────────────────────────────

  def secao_analise_gemini(pdf)
    titulo_secao(pdf, "Análise Pedagógica por Inteligência Artificial")

    pdf.fill_color BEGE_CARD
    pdf.fill_rounded_rectangle [0, pdf.cursor], pdf.bounds.width, 20, 4
    pdf.bounding_box([10, pdf.cursor - 5], width: pdf.bounds.width - 20) do
      pdf.font("Helvetica", style: :italic, size: 8) do
        pdf.fill_color MARROM
        pdf.text "Análise gerada automaticamente pelo modelo Gemini 1.5 Flash (Google AI) com base nos dados do aluno."
      end
    end
    pdf.move_down 28

    texto_limpo = limpar_analise(@analise)
    if texto_limpo.present?
      pdf.font("Helvetica", size: 10) do
        pdf.fill_color ESCURO
        pdf.text texto_limpo, align: :justify, leading: 5
      end
    end

    pdf.move_down 20
  end

  # ── RECOMENDAÇÕES ────────────────────────────────────────────────────────────

  def secao_recomendacoes(pdf)
    titulo_secao(pdf, "Recomendações Pedagógicas")

    recomendacoes = extrair_secao(@analise, "RECOMENDAÇÕES PEDAGÓGICAS")

    if recomendacoes.present?
      linhas = recomendacoes.split("\n").reject(&:blank?)
      linhas.each_with_index do |linha, i|
        y = pdf.cursor

        pdf.fill_color AZUL
        pdf.fill_circle [14, y - 8], 10

        pdf.fill_color BRANCO
        pdf.draw_text (i + 1).to_s, at: [11, y - 12], size: 9

        pdf.bounding_box([32, y], width: pdf.bounds.width - 32) do
          pdf.font("Helvetica", size: 10) do
            pdf.fill_color ESCURO
            pdf.text linha.gsub(/^\d+\.\s*/, ""), leading: 3
          end
        end

        pdf.move_down 28
      end
    end

    # Conclusão
    conclusao = extrair_secao(@analise, "CONCLUSÃO")
    if conclusao.present?
      pdf.move_down 10
      pdf.fill_color BEGE_CARD
      pdf.fill_rounded_rectangle [0, pdf.cursor], pdf.bounds.width, 4, 2
      pdf.move_down 16

      pdf.font("Helvetica", style: :bold, size: 11) do
        pdf.fill_color AZUL
        pdf.text "Conclusão"
      end
      pdf.move_down 6
      pdf.font("Helvetica", size: 10) do
        pdf.fill_color ESCURO
        pdf.text conclusao, align: :justify, leading: 4
      end
    end
  end

  # ── RODAPÉ ──────────────────────────────────────────────────────────────────

  def rodape(pdf)
    pdf.repeat(:all) do
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 20],
                       width: pdf.bounds.width, height: 20) do
        pdf.stroke_color "D9D0C4"
        pdf.stroke_horizontal_rule
        pdf.move_down 4
        pdf.font("Helvetica", size: 7) do
          pdf.fill_color MARROM
          pdf.text "Plataforma Focus · Relatório de #{@aluno[:nome]} · #{Time.current.strftime('%d/%m/%Y')}",
                   align: :center
        end
      end
    end

    pdf.number_pages "<page> de <total>",
      at: [pdf.bounds.right - 60, pdf.bounds.bottom + 22],
      size: 7,
      color: MARROM
  end

  # ── HELPERS ──────────────────────────────────────────────────────────────────

  def titulo_secao(pdf, texto)
    pdf.fill_color AZUL
    pdf.fill_rounded_rectangle [0, pdf.cursor], pdf.bounds.width, 28, 5
    pdf.bounding_box([12, pdf.cursor - 7], width: pdf.bounds.width - 24) do
      pdf.font("Helvetica", style: :bold, size: 12) do
        pdf.fill_color BRANCO
        pdf.text texto
      end
    end
    pdf.move_down 36
  end

  def extrair_secao(texto, titulo)
    return "" if texto.blank?

    titulos_todos = [
      "RESUMO EXECUTIVO",
      "ANÁLISE POR TIPO DE MISSÃO",
      "PADRÕES DE COMPORTAMENTO E USO",
      "SINAIS DE ATENÇÃO",
      "RECOMENDAÇÕES PEDAGÓGICAS",
      "CONCLUSÃO"
    ]

    proximo = titulos_todos[titulos_todos.index(titulo) + 1]
    padrao = if proximo
      /#{Regexp.escape(titulo)}\s*\n(.*?)(?=#{Regexp.escape(proximo)})/m
    else
      /#{Regexp.escape(titulo)}\s*\n(.*)/m
    end

    texto.match(padrao)&.captures&.first&.strip || ""
  end

  def limpar_analise(texto)
    return "" if texto.blank?
    texto.gsub(/\*\*(.*?)\*\*/, '\1')
         .gsub(/\*(.*?)\*/, '\1')
         .gsub(/#{Regexp.escape("RESUMO EXECUTIVO")}/, "")
         .strip
  end

  def perfil_label(perfil)
    case perfil
    when "dislexia" then "Dislexia"
    when "tdh"      then "TDAH"
    when "ambos"    then "Dislexia e TDAH"
    else "Não informado"
    end
  end
end