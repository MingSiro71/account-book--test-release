require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", division_path
#    assert_select "a[href=?]", statistic_path
#    assert_select "a[href=?]", download_path
  end

end
