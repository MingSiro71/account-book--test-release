class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      # checkbox hands '1' when it is checked, or '0' it's not checked.
      redirect_to controller: 'static_pages', action: 'home'
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
