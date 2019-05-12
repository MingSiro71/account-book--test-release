class StaticPagesController < ApplicationController
  def home
    current_user # enable @current_user if session[:user_id] isn't nil
  end

end
