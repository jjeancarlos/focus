class XpCalculatorService
  PROFILE_MULTIPLIERS = {
    "dislexia" => 1.05,
    "tdh" => 1.05,
    "ambos" => 1.1
  }.freeze

  def self.call(...)
    new(...).call
  end

  def initialize(atividade:, acertos:, total_perguntas:, tempo_gasto:, perfil_acessibilidade:)
    @atividade = atividade
    @acertos = acertos
    @total_perguntas = [ total_perguntas.to_i, 1 ].max
    @tempo_gasto = tempo_gasto.to_i
    @perfil_acessibilidade = perfil_acessibilidade
  end

  def call
    {
      xp_ganho: [ xp_bruto.round, 5 ].max,
      multiplicador_acertos: multiplicador_acertos.round(2),
      multiplicador_tempo: multiplicador_tempo.round(2),
      multiplicador_perfil: multiplicador_perfil.round(2)
    }
  end

  private

  attr_reader :atividade, :acertos, :total_perguntas, :tempo_gasto, :perfil_acessibilidade

  def xp_bruto
    atividade.xp_base * multiplicador_acertos * multiplicador_tempo * multiplicador_perfil
  end

  def multiplicador_acertos
    0.4 + (taxa_acertos * 0.6)
  end

  def taxa_acertos
    acertos.to_f / total_perguntas
  end

  def multiplicador_tempo
    return 1.0 if atividade.tipo == "leitura"

    tempo_base = [ atividade.tempo_base, 1 ].max

    if tempo_gasto <= tempo_base
      1.1
    elsif tempo_gasto <= (tempo_base * 1.5)
      1.0
    else
      0.9
    end
  end

  def multiplicador_perfil
    PROFILE_MULTIPLIERS.fetch(perfil_acessibilidade, 1.0)
  end
end
