class Recado < ApplicationRecord
  belongs_to :professor, class_name: "User", foreign_key: :professor_id
  belongs_to :turma

  validates :mensagem, presence: true

  scope :recentes,   -> { order(created_at: :desc) }
  scope :nao_lidos,  -> { where(lido: false) }
end