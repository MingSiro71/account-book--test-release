class PasswordResetsController < ApplicationController
  before_action :get_user, only:[:edit, :update]
  before_action :validate_user, only:[:edit, :update]  
  before_action :check_expiration, only:[:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワード初期化メールを送信しました"
      redirect_to root_url
    else
      flash.now[:danger] = "入力されたメールアドレスが見つかりません"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in(@user)
      flash[:success] = "パスワードをリセットしてログインしました"
      redirect_to root_url
    else
      render 'edit'
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

 private

  def validate_user
    unless valid_user?
      redirect_to root_url
    end
  end

  def valid_user?
    @user && @user.activated? && @user.authenticated?(:reset, params[:id]) ? true : false
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end

end
