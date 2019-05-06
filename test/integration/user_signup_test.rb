require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
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

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post signup_path, params: {user: {name: "example user", email: "user@example.com",
                                password: "password", password_confirmaition: "password"}}
    end
    follow_redirect!
    assert_template 'static_pages/home'
    assert_select 'div', "メールアドレスにアカウント本登録用のurlを送信しました"
  end
end
