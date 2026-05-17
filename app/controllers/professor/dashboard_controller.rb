class Professor::DashboardController < ApplicationController
  def show
    @professor = Current.user
    @turmas = Turma.where(professor_id: @professor.id)
                   .includes(:alunos)

    @total_alunos = @turmas.sum { |t| t.alunos.count }
    @missoes_hoje = Tentativa.where(
      aluno_id: User.where(turma: @turmas).select(:id),
      concluida_em: Date.today.all_day
    ).count
  end
end