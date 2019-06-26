module StaticPagesHelper
  def has_division?
    Division.find_by(user_id: session[:user_id]).present?
  end
end
