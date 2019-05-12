require 'test_helper'

class ExperimentsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get experiments_new_url
    assert_response :success
  end

end
