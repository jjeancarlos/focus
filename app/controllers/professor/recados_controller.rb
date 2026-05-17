class Professor::RecadosController < ApplicationController
  def create
    turma = Turma.find_by(professor_id: Current.user.id)
    if turma && params[:mensagem].present?
      Recado.create!(
        mensagem: params[:mensagem],
        professor: Current.user,
        turma: turma
      )
      redirect_to professor_dashboard_path,
        notice: "Recado enviado para a turma! 📨"
    else
      redirect_to professor_dashboard_path,
        alert: "Escreva uma mensagem antes de enviar."
    end
  end
end