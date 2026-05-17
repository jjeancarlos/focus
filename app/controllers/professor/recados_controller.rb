class Professor::RecadosController < ApplicationController
  before_action :require_professor

  def create
    if recado_params[:aluno_id].present?
      enviar_recado_individual
    else
      enviar_recado_para_turma
    end
  end

  private

  def enviar_recado_para_turma
    turma = Turma.find_by!(id: recado_params[:turma_id], professor_id: Current.user.id)
    recado = Recado.new(mensagem: recado_params[:mensagem].to_s.strip, professor: Current.user, turma: turma)

    if recado.save
      redirect_to professor_turma_path(turma), notice: "Recado enviado para a turma!"
    else
      redirect_to professor_turma_path(turma), alert: recado.errors.full_messages.to_sentence.presence || "Escreva uma mensagem antes de enviar."
    end
  end

  def enviar_recado_individual
    aluno = User.joins(:turma).find_by!(id: recado_params[:aluno_id], role: "aluno", turma: { professor_id: Current.user.id })
    recado = Recado.new(mensagem: recado_params[:mensagem].to_s.strip, professor: Current.user, aluno: aluno)

    if recado.save
      redirect_to professor_turma_aluno_path(aluno.turma, aluno), notice: "Recado enviado para o aluno!"
    else
      redirect_to professor_turma_aluno_path(aluno.turma, aluno), alert: recado.errors.full_messages.to_sentence.presence || "Escreva uma mensagem antes de enviar."
    end
  end

  def recado_params
    params.require(:recado).permit(:mensagem, :turma_id, :aluno_id)
  end

  def require_professor
    redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
  end
end
