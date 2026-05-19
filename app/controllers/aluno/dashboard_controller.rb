class Aluno::DashboardController < ApplicationController
  before_action :require_aluno

  def show
    @tentativas_semana = Current.user.tentativas.da_semana
    @tentativas_semana_passada = Current.user.tentativas.semana_passada

    @xp_por_dia = Current.user.tentativas
                              .da_semana
                              .group_by_day(:concluida_em)
                              .sum(:xp_ganho)

    @missoes_por_tipo = Current.user.tentativas
                                    .da_semana
                                    .group(:tipo_missao)
                                    .count

    range_start = 3.weeks.ago.beginning_of_week
    range_end = Time.zone.today.end_of_week
    weekly_counts = Current.user.tentativas
                              .where(concluida_em: range_start..range_end)
                              .group_by_week(:concluida_em, range: range_start..range_end)
                              .count

    @missoes_por_semana = weekly_counts.each_with_index.to_h do |(_, total), index|
      ["Semana #{index + 1}", total]
    end
  end

  private

  def require_aluno
    redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para alunos." unless Current.user&.aluno?
  end
end
