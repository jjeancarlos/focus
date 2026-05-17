class Recado < ApplicationRecord
  belongs_to :professor, class_name: "User", foreign_key: :professor_id
  belongs_to :turma, optional: true
  belongs_to :aluno, class_name: "User", optional: true

  validates :mensagem, presence: true
  validate :deve_ter_apenas_um_destino

  scope :recentes, -> { order(created_at: :desc) }
  scope :nao_lidos, -> { where(lido: false) }

  private

  def deve_ter_apenas_um_destino
    destinos = [turma_id.present?, aluno_id.present?].count(true)
    errors.add(:base, "Escolha uma turma ou um aluno para enviar o recado.") if destinos.zero?
    errors.add(:base, "Escolha apenas um destino para o recado.") if destinos > 1
  end
end
