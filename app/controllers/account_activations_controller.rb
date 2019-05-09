class AccountActivationsController < ApplicationController
  def edit 
    user = User.find_by(email: params[:email])
    if user && user.authenticated?(:activation,params[:id])
      user.activate
      log_in user
      flash[:success] = "アカウントが有効化されました"
      redirect_to root_url
    else
      flash[:danger] = "urlが無効です"
      redirect_to root_url
    end
  end
end
