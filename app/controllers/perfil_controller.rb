class PerfilController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(perfil_params)
      redirect_to perfil_path, notice: "Perfil atualizado com sucesso! ✅"
    else
      flash.now[:alert] = "Quase lá! Revise as informações."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def perfil_params
    params.require(:user).permit(:name, :email_address, :foto)
  end
end