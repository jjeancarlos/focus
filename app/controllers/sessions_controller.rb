class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: I18n.t("auth.login.rate_limited") } unless Rails.env.test?

  def new
  end

  def create
    user = User.find_by(email_address: normalized_email_address)
    if user.nil?
      redirect_to new_session_path(
        email_address: normalized_email_address,
        return_to: params[:return_to]
      ), alert: t("auth.login.email_not_found")
    elsif user.authenticate(params[:password])
      start_new_session_for user
      if user.professor?
        redirect_to professor_dashboard_path
      else
        redirect_to after_authentication_url(
          return_to: params[:return_to],
          fallback: root_path
        )
      end
    else
      redirect_to new_session_path(
        email_address: normalized_email_address,
        return_to: params[:return_to]
      ), alert: t("auth.login.invalid_password")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private

  def normalized_email_address
    params[:email_address].to_s.strip.downcase
  end
end
