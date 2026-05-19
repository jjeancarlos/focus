class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    return unless authenticated?

    if Current.user.professor?
      redirect_to professor_dashboard_path
    else
      redirect_to missoes_path
    end
  end
end
