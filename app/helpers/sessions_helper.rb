module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    session[:user_name] = user.name
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def logged_in?
    !session[:user_id].nil?
  end

  def forget(user_id)
    User.new.forget(user_id)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(session[:user_id])
    session.delete(:user_id)
    session.delete(:user_name)
    @current_user = nil  
  end

end
