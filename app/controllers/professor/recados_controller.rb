class Professor::RecadosController < ApplicationController
  before_action :require_professor

  def create
    mensagem = params.dig(:recado, :mensagem).to_s.strip
    turmas = Turma.where(professor_id: Current.user.id)

    if turmas.any? && mensagem.present?
      turmas.find_each do |turma|
        Recado.create!(mensagem:, professor: Current.user, turma:)
      end

      redirect_to professor_dashboard_path, notice: "Recado enviado para as turmas!"
    else
      redirect_to professor_dashboard_path, alert: "Escreva uma mensagem antes de enviar."
    end
  end

  private
    def require_professor
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
    end
end
