class Professor::TurmasController < ApplicationController
  def show
    @turma = Turma.find_by!(
      id: params[:id],
      professor_id: Current.user.id
    )
    @alunos = @turma.alunos.order(:name)
  end
end