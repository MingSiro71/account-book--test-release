require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:testman) # you should keep "testman" in "fixture/users.yml".
    @user.password = 'password'
    @user.password_confirmation = 'password'
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "  "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 21
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 81 + "@example.co.jp"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be saved in lower-case" do
    @user.email = "FOo@ExaMpLe.COM"
    @user.save
    assert_equal "foo@example.com", @user.reload.email
  end

  test "password should be present" do
    @user.password = "  "
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = "pass"
    assert_not @user.valid?
  end

  test "password_confirmation should be the same to password" do
    @user.password_confirmation = "passwodd"
    assert_not @user.valid?
  end

end
