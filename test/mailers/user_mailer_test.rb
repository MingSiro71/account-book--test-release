require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = User.first
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "アカウントを有効化しましょう", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@account.book.app"], mail.from
#    assert_match user.name, mail.body.encoded
#    assert_match user.activation_token, mail.body.encoded
#    assert_match CGI.escape(user.email), mail.body.encoded
  end

  test "password_reset" do

  end

end
