class Tentativa < ApplicationRecord
  belongs_to :aluno, class_name: "User", foreign_key: :aluno_id
  belongs_to :atividade, optional: true

  scope :da_semana,      -> { where(concluida_em: 7.days.ago..) }
  scope :semana_passada, -> { where(concluida_em: 14.days.ago..7.days.ago) }
  scope :por_tipo,       ->(tipo) { where(tipo_missao: tipo) }
end
