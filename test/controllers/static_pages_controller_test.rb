require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_select "title", "Home | Account Book : 個人事業主のための簡易帳簿システム"
  end

  test "should get division" do
    get division_path
    assert_response :success
    assert_select "h1", text: "あなたの事業一覧"
    assert_select "title", "事業一覧 | Account Book : 個人事業主のための簡易帳簿システム"    
  end

end
