class StaticPagesController < ApplicationController
  include SessionsHelper

  def home
<<<<<<< HEAD
    @user = User.find_by(id: session[:user_id])
=======
    if logged_in?
      @record = Record.new
      @records = Record.where(user_id: session[:user_id]).where(disabled: nil).order("created_at DESC").limit(10)
    end
>>>>>>> tuned-session
  end
end
