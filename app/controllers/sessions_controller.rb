class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create google_callback google_failure]
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
          fallback: missoes_path
        )
      end
    else
      redirect_to new_session_path(
        email_address: normalized_email_address,
        return_to: params[:return_to]
      ), alert: t("auth.login.invalid_password")
    end
  end

  def google_callback
    auth = request.env["omniauth.auth"]

    unless auth&.dig(:info, :email).present?
      redirect_to new_session_path, alert: t("auth.google.no_email") and return
    end

    email    = auth.info.email.strip.downcase
    provider = auth.provider
    uid      = auth.uid
    name     = auth.info.name.presence || email.split("@").first

    user = User.find_by(provider: provider, uid: uid)
    user ||= User.find_by(email_address: email)

    if user
      if user.professor?
        redirect_to new_session_path, alert: t("auth.google.professor_blocked") and return
      end

      user.update_columns(provider: provider, uid: uid) if user.provider.blank?
    else
      user = User.new(
        name:                  name,
        email_address:         email,
        provider:              provider,
        uid:                   uid,
        role:                  "aluno",
        password:              SecureRandom.hex(24),
        perfil_acessibilidade: nil
      )

      unless user.save
        redirect_to new_session_path, alert: t("auth.google.create_failed") and return
      end
    end

    start_new_session_for user

    if user.onboarding_pending?
      redirect_to perfil_registration_path
    else
      redirect_to missoes_path
    end
  end

  def google_failure
    redirect_to new_session_path, alert: t("auth.google.failure")
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