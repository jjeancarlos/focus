class Turma < ApplicationRecord
  belongs_to :professor, class_name: "User", foreign_key: :professor_id
  has_many :alunos, class_name: "User", foreign_key: :turma_id

  scope :do_professor, ->(professor) { where(professor_id: professor.id) }
  scope :buscar_por_nome_ou_aluno, ->(termo) do
    sanitized_term = sanitize_sql_like(termo.to_s.strip)
    next all if sanitized_term.blank?

    left_joins(:alunos)
      .where("turmas.nome ILIKE :query OR users.name ILIKE :query", query: "%#{sanitized_term}%")
      .distinct
  end

  before_create :gerar_invite_token

  def self.find_by_invite_token(token)
    normalized_token = token.to_s.upcase.strip
    return if normalized_token.blank?

    find_by(invite_token: normalized_token)
  end

  private

  def gerar_invite_token
    self.invite_token ||= SecureRandom.alphanumeric(8).upcase
  end
end