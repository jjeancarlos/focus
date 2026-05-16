class Aluno::DashboardController < ApplicationController
  def show
    @tentativas_semana         = Current.user.tentativas.da_semana
    @tentativas_semana_passada = Current.user.tentativas.semana_passada

    @xp_por_dia = Current.user.tentativas
                               .da_semana
                               .group_by_day(:concluida_em)
                               .sum(:xp_ganho)

    @missoes_por_tipo = Current.user.tentativas
                                     .da_semana
                                     .group(:tipo_missao)
                                     .count
  end
end