module ApplicationHelper
  def full_title(page_title = '')
    base_title = "Account Book : 個人事業主のための簡易帳簿システム"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def copy_right
    message = "Created by : HENTECH"
    message
  end

  def current_user  # GET user_id from session/cookies, RETURN user object
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in_as_owner?(model)
    return false if !current_user
    @current_user.id == model.user_id ? true : false
  end

end
