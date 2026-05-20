module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      redirect_to authentication_request_path
    end

    def authentication_request_path
      return_to = request.get? || request.head? ? safe_return_to_path(request.fullpath) : nil
      new_session_path(return_to:)
    end

    def after_authentication_url(return_to: nil, fallback: root_path)
      session.delete(:return_to_after_authenticating)
      safe_return_to_path(return_to) || fallback
    end

    def safe_return_to_path(path)
      return if path.blank?
      return unless path.start_with?("/")
      return if path.start_with?("//")
      return if path == new_session_path || path == session_path

      path
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
