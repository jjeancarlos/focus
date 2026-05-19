class Professor::TurmaAlunosController < ApplicationController
  before_action :require_professor
  before_action :set_turma
  before_action :set_aluno

  def show
    @tentativas_semana = @aluno.tentativas.da_semana
    @xp_por_dia = @aluno.tentativas.da_semana.group_by_day(:concluida_em).sum(:xp_ganho)
    @missoes_por_tipo = @aluno.tentativas.da_semana.group(:tipo_missao).count
  end

  def destroy
    @aluno.update!(turma_id: nil)
    redirect_to professor_turma_path(@turma), notice: "Aluno removido da turma com sucesso."
  end

  def relatorio_ia
    dados = StudentReportDataService.new(@aluno, @turma).coletar
    analise = GeminiAnalysisService.new(dados).analisar
    pdf = ReportPdfService.new(dados, analise).gerar

    send_data pdf,
      filename: "relatorio_#{@aluno.name.parameterize}_#{Date.today}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  rescue => e
    Rails.logger.error("[RelatorioIA] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    redirect_to professor_turma_aluno_path(@turma, @aluno),
      alert: "Erro: #{e.message}"
  end

  private
    def set_turma
      @turma = Turma.find_by!(id: params[:turma_id], professor_id: Current.user.id)
    end

    def set_aluno
      @aluno = @turma.alunos.find(params[:id])
    end

    def require_professor
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
    end
end
