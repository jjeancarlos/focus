class Professor::TurmaAlunosController < ApplicationController
  def show
    @turma = Turma.find_by!(id: params[:turma_id], professor_id: Current.user.id)
    @aluno = @turma.alunos.find(params[:id])

    @tentativas_semana = @aluno.tentativas.da_semana
    @xp_por_dia = @aluno.tentativas
                        .da_semana
                        .group_by_day(:concluida_em)
                        .sum(:xp_ganho)
    @missoes_por_tipo = @aluno.tentativas
                              .da_semana
                              .group(:tipo_missao)
                              .count
  end
end