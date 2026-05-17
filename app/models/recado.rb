class Recado < ApplicationRecord
  belongs_to :professor, class_name: "User", foreign_key: :professor_id
  belongs_to :turma

  validates :mensagem, presence: true
  scope :recentes, -> { order(created_at: :desc).limit(5) }
end