class StaticPagesController < ApplicationController
  include SessionsHelper

  def home
    if logged_in?
      @record = Record.new
      @records = Record.where(user_id: session[:user_id]).where(disabled: nil).order("created_at DESC").limit(10)
    end
  end

end
