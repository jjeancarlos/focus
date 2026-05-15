class User < ApplicationRecord
  PROFILES = %w[dislexia tdh ambos].freeze
  ROLES = %w[aluno professor].freeze

  attr_accessor :require_profile_completion

  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :turma, optional: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :perfil_acessibilidade, inclusion: { in: PROFILES }, allow_nil: true
  validates :perfil_acessibilidade, presence: true, if: :require_profile_completion?

  def onboarding_pending?
    perfil_acessibilidade.blank?
  end

  def require_profile_completion?
    require_profile_completion
  end
end
