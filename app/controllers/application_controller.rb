class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user
  helper_method :logged_in?

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    return if logged_in?

    redirect_to root_path, alert: 'ログインが必要です'
  end
end
