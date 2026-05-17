class ConquistasController < ApplicationController
  before_action :require_aluno

  def index
    @user = Current.user
    @tentativas = @user.tentativas
    @totais_por_tipo = Atividade::TIPOS.index_with do |tipo|
      @tentativas.por_tipo(tipo).count
    end
    @xp_total = @tentativas.sum(:xp_ganho)
    @sequencia_atual = @user.sequencia_dias
    @conquistas = [
      {
        titulo: "Primeira missão",
        descricao: "Completou 1 missão qualquer.",
        icone: "fa-solid fa-star",
        cor: "#4A6FA5",
        desbloqueada: @tentativas.count >= 1
      },
      {
        titulo: "Leitor iniciante",
        descricao: "Completou 3 missões de leitura.",
        icone: "fa-solid fa-book-open-reader",
        cor: "#4A8C5C",
        desbloqueada: @totais_por_tipo["leitura"] >= 3
      },
      {
        titulo: "Foco total",
        descricao: "Completou 3 missões de foco.",
        icone: "fa-solid fa-brain",
        cor: "#4A6FA5",
        desbloqueada: @totais_por_tipo["foco"] >= 3
      },
      {
        titulo: "Desafiador",
        descricao: "Completou 3 desafios.",
        icone: "fa-solid fa-trophy",
        cor: "#CA8A04",
        desbloqueada: @totais_por_tipo["desafio"] >= 3
      },
      {
        titulo: "Uma semana focado",
        descricao: "Manteve sequência de 7 dias.",
        icone: "fa-solid fa-calendar-check",
        cor: "#7C5CBF",
        desbloqueada: @sequencia_atual >= 7
      }
    ]
  end

  private

  def require_aluno
    redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para alunos." unless Current.user&.aluno?
  end
end
