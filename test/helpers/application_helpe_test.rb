require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title, "Account Book : 個人事業主のための簡易帳簿システム"
    assert_equal full_title("Help"), "Help | Account Book : 個人事業主のための簡易帳簿システム"
  end

end