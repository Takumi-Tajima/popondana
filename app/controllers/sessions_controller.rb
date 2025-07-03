class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    
    if auth.present?
      user = User.find_auth_user(auth) || User.create_with_auth(auth)
      
      if user.persisted?
        reset_session
        session[:user_id] = user.id
        redirect_to root_path, notice: 'ログインしました'
      else
        redirect_to root_path, alert: 'ユーザー作成に失敗しました'
      end
    else
      redirect_to root_path, alert: '認証情報が取得できませんでした'
    end
  end

  def failure
    redirect_to root_path, alert: '認証に失敗しました'
  end

  def destroy
    reset_session
    session[:user_id] = nil
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
