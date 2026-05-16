module Missoes
  class FinalizarTentativaService
    def self.call(...)
      new(...).call
    end

    def initialize(user:, atividade:, pontuacao:, total_perguntas:, tempo_gasto:, xp_ganho:)
      @user = user
      @atividade = atividade
      @pontuacao = pontuacao
      @total_perguntas = total_perguntas
      @tempo_gasto = tempo_gasto
      @xp_ganho = xp_ganho
    end

    def call
      Tentativa.transaction do
        concluida_em = Time.current
        ultima_tentativa = user.tentativas.where.not(concluida_em: nil).order(concluida_em: :desc).first

        tentativa = user.tentativas.create!(
          atividade: atividade,
          tipo_missao: atividade.tipo,
          pontuacao: pontuacao,
          tempo_gasto: tempo_gasto,
          xp_ganho: xp_ganho,
          concluida_em: concluida_em
        )

        user.xp_total += xp_ganho
        user.recalcular_nivel!
        user.atualizar_sequencia!(concluida_em, ultima_tentativa)
        user.save!

        tentativa
      end
    end

    private

    attr_reader :user, :atividade, :pontuacao, :total_perguntas, :tempo_gasto, :xp_ganho
  end
end
