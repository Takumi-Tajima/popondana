class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    user = User.find_auth_user(auth) || User.create_with_auth(auth)
    reset_session
    session[:user_id] = user.id
    redirect_to root_path, notice: 'ログインしました'
  end

  def destroy
    reset_session
    session[:user_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
