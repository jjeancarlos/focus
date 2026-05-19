class Professor::TurmaAlunosController < ApplicationController
  before_action :require_professor

  def show
    @turma = Turma.find_by!(id: params[:turma_id], professor_id: Current.user.id)
    @aluno = @turma.alunos.find(params[:id])
    @tentativas_semana = @aluno.tentativas.da_semana
    @xp_por_dia = @aluno.tentativas.da_semana.group_by_day(:concluida_em).sum(:xp_ganho)
    @missoes_por_tipo = @aluno.tentativas.da_semana.group(:tipo_missao).count
  end

  def relatorio_ia
    @turma = Turma.find_by!(id: params[:turma_id], professor_id: Current.user.id)
    @aluno = @turma.alunos.find(params[:id])

    dados   = StudentReportDataService.new(@aluno, @turma).coletar
    analise = GeminiAnalysisService.new(dados).analisar
    pdf     = ReportPdfService.new(dados, analise).gerar

    send_data pdf,
      filename: "relatorio_#{@aluno.name.parameterize}_#{Date.today}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  rescue => e
    Rails.logger.error("[RelatorioIA] #{e.message}")
    redirect_to professor_turma_aluno_path(@turma, @aluno),
      alert: "Não foi possível gerar o relatório. Tente novamente."
  end

  private
    def require_professor
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
    end
end