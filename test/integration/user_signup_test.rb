require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup infomation" do
    get signup_path
    assert_no_difference 'User.count' do
      users = [
        {name: "  ", email: "valid@email.com", password: "validpass", password_confirmaition: "validpass"},
        {name: "testman", email: "invalid@email", password: "validpass", password_confirmaition: "validpass"},
        {name: "testman", email: "valid@email.com", password: "invalid", password_confirmaition: "invalid"},
#        {name: "testman", email: "valid@email.com", password: "validpass", password_confirmaition: "invalid"}
      ]
      users.each { |user|
        post signup_path, params: {user: user}
      }
    end
    assert_template "users/new"
    assert_select "#error_explanation"
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: {user: {name: "example user", email: "user@example.com",
                                password: "password", password_confirmaition: "password"}}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    post login_path, params: {session: {email: user.email, password: user.password}}
    assert_not is_logged_in?

    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?

    get edit_account_activation_path(user.activation_token, email: "invalid")
    assert_not is_logged_in?

    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'static_pages/home'
    assert is_logged_in?
  end
end
