class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :auto_log_in
  include ApplicationHelper
  include SessionsHelper

 private

  def auto_log_in
    if !session[:user_id] && cookies.permanent.signed[:user_id]
      log_in_by_id(cookies.permanent.signed[:user_id])
    end
  end

end
