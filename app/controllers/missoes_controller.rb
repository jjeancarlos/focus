class MissoesController < ApplicationController
  before_action :require_aluno
  before_action :set_tipo
  before_action :set_tentativa, only: :resultado
  before_action :set_atividade, only: %i[show responder resultado]
  before_action :bloquear_limite_diario!, only: %i[show responder]

  def index
    @missoes_por_tipo = Atividade::TIPOS.index_with do |tipo|
      Atividade.ativas.por_tipo(tipo).exists?
    end
    @limite_diario_atingido = Current.user.limite_diario_atingido?
  end

  def show
    iniciar_missao!
    @tempo_visual = @atividade.tempo_base
    @perguntas = @atividade.perguntas
    @palavras_embaralhadas = palavras_embaralhadas
    @feedback_messages = feedback_messages
  end

  def responder
    return redirect_to missoes_path, alert: "Quase lá! Escolha uma missão para começar." unless missao_atual_valida?

    resultado = corrigir_respostas
    calculo_xp = XpCalculatorService.call(
      atividade: @atividade,
      acertos: resultado[:acertos],
      total_perguntas: resultado[:total_perguntas],
      tempo_gasto: tempo_gasto,
      perfil_acessibilidade: Current.user.perfil_acessibilidade
    )

    tentativa = Missoes::FinalizarTentativaService.call(
      user: Current.user,
      atividade: @atividade,
      pontuacao: resultado[:acertos],
      total_perguntas: resultado[:total_perguntas],
      tempo_gasto: tempo_gasto,
      xp_ganho: calculo_xp[:xp_ganho]
    )

    session.delete(:missao_atual)
    redirect_to resultado_missao_path(@atividade.tipo, tentativa_id: tentativa.id)
  end

  def resultado
    @total_perguntas = total_perguntas_da_tentativa
    @mensagem = mensagem_resultado(@tentativa.pontuacao, @total_perguntas)
    @missoes_hoje = Current.user.missoes_hoje
    @xp_hoje = Current.user.xp_hoje
    @mostrar_modal_conclusao = @missoes_hoje == 10
  end

  private

    def require_aluno
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para alunos." unless Current.user&.aluno?
    end

    def set_tipo
      @tipo = params[:tipo]
      return if @tipo.blank? || Atividade::TIPOS.include?(@tipo)

      redirect_to missoes_path, alert: "Quase lá! Escolha um tipo de missão disponível."
    end

    def set_atividade
      @atividade = @tentativa&.atividade || atividade_em_andamento || Atividade.sorteada_para(@tipo)
      return if @atividade.present?

      redirect_to missoes_path, alert: "Quase lá! Esta missão estará disponível em breve."
    end

    def set_tentativa
      @tentativa = Current.user.tentativas.find(params[:tentativa_id])
      return if @tentativa.tipo_missao == @tipo

      redirect_to missoes_path, alert: "Quase lá! Vamos abrir o resultado correto da sua missão."
    end

    def iniciar_missao!
      return if missao_atual_valida?

      session[:missao_atual] = {
        "atividade_id" => @atividade.id,
        "tipo" => @atividade.tipo,
        "token" => SecureRandom.hex(10),
        "iniciada_em" => Time.current.iso8601
      }
    end

    def missao_atual_valida?
      session[:missao_atual].present? && session[:missao_atual]["atividade_id"] == @atividade.id && session[:missao_atual]["tipo"] == @tipo
    end

    def tempo_gasto
      inicio = Time.zone.parse(session[:missao_atual]["iniciada_em"])
      [(Time.current - inicio).round, 1].max
    end

    def corrigir_respostas
      case @atividade.tipo
      when "desafio"
        corrigir_desafio
      else
        corrigir_multiplas_escolhas
      end
    end

    def corrigir_multiplas_escolhas
      respostas = params[:respostas] || {}
      acertos = @atividade.perguntas.count do |pergunta|
        respostas[pergunta["id"]] == pergunta["correta_index"].to_s
      end

      { acertos: acertos, total_perguntas: @atividade.perguntas.size }
    end

    def corrigir_desafio
      respostas = params[:desafio_respostas] || {}
      acertos = @atividade.perguntas.count do |pergunta|
        enviada = respostas[pergunta["id"]].to_s.split("||").reject(&:blank?)
        enviada == Array(pergunta["ordem_correta"])
      end

      { acertos: acertos, total_perguntas: @atividade.perguntas.size }
    end

    def palavras_embaralhadas
      return {} unless @atividade.tipo == "desafio"

      @atividade.perguntas.index_with do |pergunta|
        Array(pergunta["palavras"]).shuffle
      end
    end

    def atividade_em_andamento
      return if session[:missao_atual].blank?
      return if session[:missao_atual]["tipo"] != @tipo

      Atividade.find_by(id: session[:missao_atual]["atividade_id"], tipo: @tipo, ativo: true)
    end

    def total_perguntas_da_tentativa
      @tentativa.atividade&.perguntas&.size || 0
    end

    def mensagem_resultado(acertos, total)
      return "Você concluiu sua missão. Vamos para a próxima." if total.zero?
      return "Você mandou muito bem e avançou mais um passo." if acertos == total
      return "Você está evoluindo. Continue praticando no seu ritmo." if acertos.positive?

      "Você praticou hoje e isso já conta muito. Tente novamente quando quiser."
    end

    def bloquear_limite_diario!
      redirect_to missoes_path, alert: "limite_atingido" if Current.user.limite_diario_atingido?
    end

    def feedback_messages
      [
        { icon: "fa-solid fa-hand-fist", text: "Quase lá! Continue tentando." },
        { icon: "fa-solid fa-seedling", text: "Você está aprendendo. Continue praticando." },
        { icon: "fa-solid fa-star", text: "Boa tentativa! Na próxima você acerta." }
      ]
    end
end
