class SessionsController < ApplicationController
  def new
    # Don't use it.
    # Users can log in from home.
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])
      if user.activated?
        log_in(user)
        params[:remember_me] == '1' ? remember(user) : forget(user)
        # checkbox hands '1' when it is checked, or '0' it's not checked.
        redirect_to controller: 'static_pages', action: 'home'
      else
        message = "アカウント有効化後にログイン出来るようになります"
        message += "メールを確認してください"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'パスワードとメールアドレスが一致しません'
      flash.now[:danger_additional] = 'または… アカウントは作成済みですか？'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to controller: 'static_pages', action: 'home'
  end
end
