class PerfilController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(perfil_params)
      redirect_to perfil_path, notice: "Perfil atualizado com sucesso!"
    else
      flash.now[:alert] = "Quase lá! Revise as informações."
      render :show, status: :unprocessable_entity
    end
  end

  def update_turma
    @user = Current.user
    return redirect_to perfil_path, alert: "Quase lá! Esta opção é exclusiva para alunos." unless @user.aluno?
    return redirect_to perfil_path, alert: "Você já está em uma turma." if @user.turma.present?

    turma = Turma.find_by_invite_token(params[:invite_token])

    if turma
      @user.update!(turma: turma)
      redirect_to perfil_path, notice: "Você entrou na turma #{turma.nome}!"
    else
      flash.now[:alert] = "Código inválido. Verifique e tente novamente."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def perfil_params
    params.require(:user).permit(:name, :email_address, :foto)
  end
end