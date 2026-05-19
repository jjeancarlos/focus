class NotificacoesController < ApplicationController
  before_action :require_aluno

  def index
    @usuario = Current.user
    @recados = recados_do_aluno.recentes

    @alertas = gerar_alertas

    recados_do_aluno.nao_lidos.update_all(lido: true)
  end

  def contagem
    total = recados_nao_lidos + (missoes_hoje.zero? ? 1 : 0)
    render json: { total: total }
  end

  private

  def require_aluno
    redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para alunos." unless Current.user&.aluno?
  end

  def recados_do_aluno
    return Recado.where(aluno_id: Current.user.id) if Current.user.turma.blank?

    Recado.where(turma: Current.user.turma)
          .or(Recado.where(aluno_id: Current.user.id))
  end

  def recados_nao_lidos
    recados_do_aluno.nao_lidos.count
  end

  def missoes_hoje
    Current.user.tentativas
           .where(concluida_em: Date.today.all_day)
           .count
  end

  def gerar_alertas
    alertas = []
    hora = Time.current.hour

    if missoes_hoje.zero?
      if hora < 12
        alertas << {
          icone: "fa-sun",
          cor: "#9C7A2E",
          titulo: "Bom dia!",
          mensagem: "Que tal começar o dia com uma missão? Você consegue!"
        }
      elsif hora < 18
        alertas << {
          icone: "fa-bolt",
          cor: "#4A6FA5",
          titulo: "Boa tarde!",
          mensagem: "Ainda dá tempo de fazer suas missões hoje. Vamos lá?"
        }
      else
        alertas << {
          icone: "fa-moon",
          cor: "#7C5CBF",
          titulo: "Boa noite!",
          mensagem: "O dia ainda não acabou! Faça pelo menos uma missão antes de dormir."
        }
      end
    else
      alertas << {
        icone: "fa-circle-check",
        cor: "#4A8C5C",
        titulo: "Ótimo trabalho!",
        mensagem: "Você já fez #{missoes_hoje} #{missoes_hoje == 1 ? 'missão' : 'missões'} hoje. Continue assim!"
      }
    end

    alertas
  end
end