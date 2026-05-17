class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_authenticated_user
  before_action :set_pending_user, only: %i[perfil update_perfil codigo_turma entrar_turma pular_turma]

  def new
    @user = User.new(role: "aluno")
  end

  def create
    @user = User.new(registration_params.merge(role: "aluno"))
    if @user.save
      session[:pending_registration_user_id] = @user.id
      redirect_to cadastro_perfil_path
    else
      flash.now[:alert] = t("auth.registration.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def perfil
  end

  def update_perfil
    @user.require_profile_completion = true
    if @user.update(profile_params)
      redirect_to cadastro_turma_path
    else
      flash.now[:alert] = t("auth.registration.profile_invalid")
      render :perfil, status: :unprocessable_entity
    end
  end

  def codigo_turma
  end

  def entrar_turma
    turma = Turma.find_by(invite_token: params[:invite_token]&.upcase&.strip)

    if turma
      @user.update!(turma: turma)
      session.delete(:pending_registration_user_id)
      start_new_session_for(@user)
      redirect_to aluno_dashboard_path, notice: "Você entrou na turma #{turma.nome}!"
    else
      flash.now[:alert] = "Código inválido. Verifique e tente novamente."
      render :codigo_turma, status: :unprocessable_entity
    end
  end

  def pular_turma
    session.delete(:pending_registration_user_id)
    start_new_session_for(@user)
    redirect_to aluno_dashboard_path, notice: "Sua experiência está pronta para começar."
  end

  private
    def registration_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end

    def profile_params
      params.require(:user).permit(:perfil_acessibilidade)
    end

    def set_pending_user
      @user = User.find_by(id: session[:pending_registration_user_id])
      return if @user.present?

      session.delete(:pending_registration_user_id)
      redirect_to cadastro_path, alert: "Quase lá! Comece criando sua conta."
    end

    def redirect_authenticated_user
      redirect_to root_path if authenticated?
    end
end
