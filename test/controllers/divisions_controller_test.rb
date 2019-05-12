require 'test_helper'

class DivisionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:testman)
    @division = @user.divisions.first
  end

  test "should not get index without login user" do
    get divisions_path
    follow_redirect!
    assert_template 'static_pages/home'
  end

  test "should get index" do
    log_in_as(@user)
    get divisions_path
    assert_response :success
    assert_select "h1", text: "あなたの事業一覧"
    assert_select "title", "事業一覧 | Account Book : 個人事業主のための簡易帳簿システム"    
  end

  test "should get new" do
    get new_division_path
    assert_response :success
  end

  test "should not get edit with invalid current user" do
    get edit_division_path(@division.id)
    follow_redirect!
    assert_template 'static_pages/home'
    @user = users(:testcat)
    log_in_as(@user)
    get edit_division_path(@division.id)
    follow_redirect!
    assert_template 'static_pages/home'
  end

  test "should get edit" do
    log_in_as(@user)  
    get edit_division_path(@division.id)
    assert_response :success
  end

end
