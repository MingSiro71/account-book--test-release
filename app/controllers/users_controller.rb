class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "メールアドレスにアカウント本登録用のurlを送信しました"
      redirect_to controller: 'static_pages', action: 'home'
    else
      render 'new'
    end
  end

 private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
