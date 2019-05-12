class StaticPagesController < ApplicationController
  def home
    @user = User.find_by(id: session[:user_id])
  end

  def division
  end
end
