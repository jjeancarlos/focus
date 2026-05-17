class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: "Muitas tentativas. Aguarde alguns minutos." }

  def new
  end

  def create
  if user = User.authenticate_by(params.permit(:email_address, :password))
    start_new_session_for user
    if user.professor?
      redirect_to professor_dashboard_path
    else
      redirect_to after_authentication_url
    end
  else
    if User.exists?(email_address: params[:email_address])
      redirect_to new_session_path, alert: "Senha incorreta. Tente novamente."
    else
      redirect_to new_session_path, alert: "Não encontramos uma conta com esse email."
    end
  end
end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end