class Professor::TurmasController < ApplicationController
  before_action :require_professor
  before_action :set_turma, only: %i[show destroy]

  def show
    @alunos = @turma.alunos.order(:name)
  end

  def new
    @turma = Turma.new
  end

  def create
    @turma = Turma.new(turma_params)
    @turma.professor_id = Current.user.id

    if @turma.save
      redirect_to professor_dashboard_path, notice: "Turma criada! Código: #{@turma.invite_token}"
    else
      flash.now[:alert] = "Verifique os campos e tente novamente."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @turma.destroy_with_students_unassigned!
    redirect_to professor_dashboard_path, notice: "Turma excluída e alunos desvinculados com sucesso."
  end

  private
    def set_turma
      @turma = Turma.find_by!(id: params[:id], professor_id: Current.user.id)
    end

    def turma_params
      params.require(:turma).permit(:nome)
    end

    def require_professor
      redirect_to root_path, alert: "Quase lá! Esta área é exclusiva para professores." unless Current.user&.professor?
    end
end
