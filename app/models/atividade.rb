class Atividade < ApplicationRecord
  TIPOS = %w[leitura foco desafio].freeze

  has_many :tentativas, dependent: :nullify

  scope :ativas, -> { where(ativo: true) }
  scope :por_tipo, ->(tipo) { where(tipo: tipo) }

  validates :tipo, presence: true, inclusion: { in: TIPOS }
  validates :titulo, :descricao, presence: true
  validates :xp_base, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ativo, inclusion: { in: [true, false] }
  validates :perguntas, presence: true

  def self.sorteada_para(tipo)
    ativas.por_tipo(tipo).order(Arel.sql("RANDOM()")).first
  end

  def tempo_base
    case tipo
    when "foco"
      perguntas.first&.fetch("tempo_exibicao", 8).to_i
    when "desafio"
      perguntas.first&.fetch("tempo_ideal", 30).to_i
    else
      0
    end
  end
end
