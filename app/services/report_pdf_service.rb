require "prawn"
require "prawn/table"

class ReportPdfService
  AZUL       = "2C4A7C"
  AZUL_CLARO = "4A6FA5"
  VERDE      = "4A8C5C"
  BEGE_CARD  = "EDE8DF"
  MARROM     = "7A726C"
  DOURADO    = "9C7A2E"
  ESCURO     = "2A2520"
  BRANCO     = "FFFFFF"

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
      margin: [50, 50, 50, 50]
    )

    font_path = Rails.root.join("app/assets/fonts")
    pdf.font_families.update(
      "FreeSans" => {
        normal:      font_path.join("FreeSans.ttf").to_s,
        bold:        font_path.join("FreeSansBold.ttf").to_s,
        italic:      font_path.join("FreeSans.ttf").to_s,
        bold_italic: font_path.join("FreeSansBold.ttf").to_s
      }
    )
    pdf.font "FreeSans"

    capa(pdf)
    pdf.start_new_page
    indicadores(pdf)
    desempenho_por_tipo(pdf)
    evolucao(pdf)
    habitos(pdf)
    sinais(pdf)
    analise_ia(pdf)
    rodape(pdf)

    pdf.render
  end

  private

  def titulo(pdf, texto)
    pdf.fill_color AZUL
    pdf.fill_rectangle [0, pdf.cursor], pdf.bounds.width, 24
    pdf.fill_color BRANCO
    pdf.draw_text texto, at: [8, pdf.cursor - 17], size: 11
    pdf.fill_color ESCURO
    pdf.move_down 32
  end

  def capa(pdf)
    pdf.move_down 80
    pdf.font("FreeSans", size: 22) do
      pdf.fill_color AZUL
      pdf.text "Relatório de Desempenho", align: :center
      pdf.text @aluno[:nome], align: :center
    end
    pdf.move_down 20
    pdf.font("FreeSans", size: 11) do
      pdf.fill_color MARROM
      pdf.text "Turma: #{@aluno[:turma]}", align: :center
      pdf.move_down 4
      pdf.text "Perfil: #{perfil_label(@aluno[:perfil_acessibilidade])}", align: :center
      pdf.move_down 4
      pdf.text "Membro desde: #{@aluno[:membro_desde]}", align: :center
      pdf.move_down 4
      pdf.text "Gerado em: #{Time.current.strftime('%d/%m/%Y as %H:%M')}", align: :center
      pdf.move_down 4
      pdf.text "Gerado com Inteligencia Artificial — Plataforma Focus", align: :center
    end
    pdf.fill_color ESCURO
  end

  def indicadores(pdf)
    titulo(pdf, "Indicadores Gerais")

    dados = [
      ["Missoes concluidas", @geral[:total_missoes].to_s],
      ["XP total acumulado", @aluno[:xp_total].to_s],
      ["Nivel atual", "#{@aluno[:nivel]} — #{@aluno[:nome_nivel]}"],
      ["Sequencia de dias", "#{@aluno[:sequencia_dias]} dias"],
      ["Missoes nos ultimos 7 dias", @geral[:missoes_ultimos_7_dias].to_s],
      ["Missoes nos ultimos 30 dias", @geral[:missoes_ultimos_30_dias].to_s],
      ["Tempo total dedicado", "#{@geral[:tempo_total_minutos]} minutos"],
      ["Media de pontuacao", @geral[:media_pontuacao].to_s],
      ["Ultima atividade", @geral[:ultima_atividade] || "Nenhuma"]
    ]

    pdf.table(dados, width: pdf.bounds.width,
      cell_style: { size: 10, padding: [6, 8], border_color: "D9D0C4" }) do |t|
      t.column(0).background_color = BEGE_CARD
      t.column(0).text_color = AZUL
      t.column(0).font_style = :bold
      t.column(1).text_color = ESCURO
    end
    pdf.move_down 20
  end

  def desempenho_por_tipo(pdf)
    titulo(pdf, "Desempenho por Tipo de Missao")

    cabecalho = [["Tipo", "Missoes", "Media Pts", "Tempo Medio", "XP Ganho"]]
    linhas = []

    { "leitura" => "Leitura Guiada", "foco" => "Missao de Foco", "desafio" => "Desafio" }.each do |tipo, label|
      d = @tipos[tipo.to_sym] || @tipos[tipo]
      next unless d
      tempo = d[:media_tempo_segundos] > 0 ? "#{(d[:media_tempo_segundos] / 60.0).round(1)} min" : "—"
      linhas << [label, d[:total].to_s, d[:media_pontuacao].to_s, tempo, d[:xp_ganho].to_s]
    end

    pdf.table(cabecalho + linhas, width: pdf.bounds.width,
      cell_style: { size: 10, padding: [6, 8], border_color: "D9D0C4" }) do |t|
      t.row(0).background_color = AZUL
      t.row(0).text_color = BRANCO
      t.row(0).font_style = :bold
      t.rows(1..-1).background_color = BEGE_CARD
      t.columns(1..4).align = :center
    end
    pdf.move_down 20
  end

  def evolucao(pdf)
    titulo(pdf, "Evolucao nas Ultimas 4 Semanas")

    cabecalho = [["Semana", "Missoes", "XP Ganho", "Media Pts"]]
    linhas = @evolucao[:por_semana].map do |s|
      ["Sem. #{s[:semana]}", s[:missoes].to_s, s[:xp].to_s, s[:media_pontuacao].to_s]
    end

    pdf.table(cabecalho + linhas, width: pdf.bounds.width,
      cell_style: { size: 10, padding: [6, 8], border_color: "D9D0C4" }) do |t|
      t.row(0).background_color = AZUL
      t.row(0).text_color = BRANCO
      t.row(0).font_style = :bold
      t.rows(1..-1).background_color = BEGE_CARD
      t.columns(1..3).align = :center
    end

    pdf.move_down 10
    pdf.font("FreeSans", size: 10) do
      pdf.fill_color MARROM
      tendencia = case @evolucao[:tendencia]
        when "crescente"   then "Tendencia: Crescente — o aluno esta evoluindo."
        when "decrescente" then "Tendencia: Decrescente — atencao necessaria."
        else "Tendencia: Estavel — desempenho consistente."
      end
      pdf.text tendencia
    end
    pdf.move_down 20
  end

  def habitos(pdf)
    titulo(pdf, "Habitos de Uso e Frequencia")

    dados = [
      ["Total de sessoes",         @habitos[:total_sessoes].to_s],
      ["Dias com atividade",       @habitos[:dias_ativos_total].to_s],
      ["Horario mais ativo",       @habitos[:hora_mais_ativa]],
      ["Dia da semana mais ativo", @habitos[:dia_semana_mais_ativo]],
      ["Primeiro acesso",          @habitos[:primeiro_acesso] || "—"],
      ["Ultimo acesso",            @habitos[:ultimo_acesso] || "—"],
      ["Dias inativo ate hoje",    @habitos[:dias_inativo_ate_hoje]&.to_s || "—"]
    ]

    pdf.table(dados, width: pdf.bounds.width,
      cell_style: { size: 10, padding: [6, 8], border_color: "D9D0C4" }) do |t|
      t.column(0).background_color = BEGE_CARD
      t.column(0).text_color = AZUL
      t.column(0).font_style = :bold
      t.column(1).text_color = ESCURO
    end
    pdf.move_down 20
  end

  def sinais(pdf)
    return if @sinais.blank?
    titulo(pdf, "Sinais de Atencao")
    pdf.font("FreeSans", size: 10) do
      pdf.fill_color ESCURO
      @sinais.each do |sinal|
        pdf.text "• #{sinal}", leading: 4
        pdf.move_down 4
      end
    end
    pdf.move_down 20
  end

  def analise_ia(pdf)
    titulo(pdf, "Analise Pedagogica por Inteligencia Artificial")
    pdf.font("FreeSans", size: 10) do
      pdf.fill_color ESCURO
      texto = @analise.presence || "Analise nao disponivel no momento."
      texto_limpo = texto.gsub(/\*\*(.*?)\*\*/, '\1').gsub(/\*(.*?)\*/, '\1').strip
      pdf.text texto_limpo, align: :justify, leading: 5
    end
    pdf.move_down 20
  end

  def rodape(pdf)
    pdf.repeat(:all) do
      pdf.bounding_box([0, pdf.bounds.bottom + 20], width: pdf.bounds.width, height: 20) do
        pdf.stroke_color "D9D0C4"
        pdf.stroke_horizontal_rule
        pdf.move_down 4
        pdf.font("FreeSans", size: 7) do
          pdf.fill_color MARROM
          pdf.text "Plataforma Focus · #{@aluno[:nome]} · #{Time.current.strftime('%d/%m/%Y')}",
            align: :center
        end
      end
    end
    pdf.number_pages "<page> de <total>",
      at: [pdf.bounds.right - 60, pdf.bounds.bottom + 22],
      size: 7, color: MARROM
  end

  def perfil_label(perfil)
    case perfil
    when "dislexia" then "Dislexia"
    when "tdh"      then "TDAH"
    when "ambos"    then "Dislexia e TDAH"
    else "Nao informado"
    end
  end
end