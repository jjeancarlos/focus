class User < ApplicationRecord
  PROFILES = %w[dislexia tdh ambos].freeze
  ROLES = %w[aluno professor].freeze
  NIVEIS = {
    1 => { nome: "Iniciante",      cor: "#9CA3AF", limite_xp: 100 },
    2 => { nome: "Explorador",     cor: "#4A8C5C", limite_xp: 250 },
    3 => { nome: "Focado",         cor: "#4A6FA5", limite_xp: 500 },
    4 => { nome: "Determinado",    cor: "#7C5CBF", limite_xp: 1000 },
    5 => { nome: "Mestre do Foco", cor: "#9C7A2E", limite_xp: 1000 }
  }.freeze

  attr_accessor :require_profile_completion

  has_secure_password
  has_many :turmas_como_professor,
         class_name: "Turma",
         foreign_key: :professor_id,
         dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :tentativas, foreign_key: :aluno_id, dependent: :destroy
  has_many :atividades, through: :tentativas
  belongs_to :turma, optional: true
  has_one_attached :foto

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: { message: "Esse email já está cadastrado. Tente fazer login." }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :perfil_acessibilidade, inclusion: { in: PROFILES }, allow_nil: true
  validates :perfil_acessibilidade, presence: true, if: :require_profile_completion?
  validate :foto_deve_ser_imagem

  def self.nivel_para_xp(xp_total)
    NIVEIS.each do |nivel, dados|
      return nivel if xp_total < dados[:limite_xp]
    end
    NIVEIS.keys.max
  end

  def professor?
    role == "professor"
  end

  def aluno?
    role == "aluno"
  end

  def onboarding_pending?
    perfil_acessibilidade.blank?
  end

  def recalcular_nivel!
    self.nivel = self.class.nivel_para_xp(xp_total)
  end

  def atualizar_sequencia!(
    concluida_em = Time.current,
    ultima_tentativa = tentativas.where.not(concluida_em: nil).order(concluida_em: :desc).first
  )
    data_atual = concluida_em.to_date
    self.sequencia_dias = if ultima_tentativa.nil?
      1
    elsif ultima_tentativa.concluida_em.to_date == data_atual
      sequencia_dias.presence || 1
    elsif ultima_tentativa.concluida_em.to_date == data_atual - 1.day
      sequencia_dias.to_i + 1
    else
      1
    end
  end

  private

  def require_profile_completion?
    require_profile_completion
  end

  def foto_deve_ser_imagem
    return unless foto.attached?

    unless foto.content_type.in?(%w[image/png image/jpeg image/jpg image/webp])
      errors.add(:foto, "deve ser uma imagem PNG, JPG ou WEBP")
    end

    if foto.byte_size > 5.megabytes
      errors.add(:foto, "deve ter menos de 5MB")
    end
  end
end
