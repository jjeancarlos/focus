class Turma < ApplicationRecord
  belongs_to :professor, class_name: "User", foreign_key: :professor_id
  has_many :alunos, class_name: "User", foreign_key: :turma_id

  before_create :gerar_invite_token

  private

  def gerar_invite_token
    self.invite_token ||= SecureRandom.alphanumeric(8).upcase
  end
end