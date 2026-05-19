class Professor::DashboardController < ApplicationController
  before_action :require_professor

  def show
    @professor = Current.user
    @query = params[:q].to_s.strip
    professor_turmas = Turma.do_professor(@professor).includes(:alunos)

    @turmas = professor_turmas.buscar_por_nome_ou_aluno(@query)
    @alunos_encontrados_por_turma = alunos_encontrados_por_turma(@turmas, @query)
    @total_alunos = professor_turmas.sum { |turma| turma.alunos.size }
    @missoes_hoje = Tentativa.where(
      aluno_id: User.where(turma: professor_turmas).select(:id),
      concluida_em: Time.zone.today.all_day
    ).count
  end

  private

    def alunos_encontrados_por_turma(turmas, query)
      return {} if query.blank?

      termo = query.downcase
      turmas.index_with do |turma|
        turma.alunos.select { |aluno| aluno.name.downcase.include?(termo) }
      end
    end

    def require_professor
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
    end
end
