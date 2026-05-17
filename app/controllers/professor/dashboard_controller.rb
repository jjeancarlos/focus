class Professor::DashboardController < ApplicationController
  before_action :require_professor

  def show
    @professor = Current.user
    @turmas = Turma.where(professor_id: @professor.id).includes(:alunos)
    @total_alunos = @turmas.sum { |turma| turma.alunos.size }
    @missoes_hoje = Tentativa.where(
      aluno_id: User.where(turma: @turmas).select(:id),
      concluida_em: Time.zone.today.all_day
    ).count
  end

  private
    def require_professor
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
    end
end
