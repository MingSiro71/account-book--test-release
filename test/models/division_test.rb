require 'test_helper'

class DivisionTest < ActiveSupport::TestCase

  def setup
    @user = users(:testman)
    @division = @user.divisions.build(name: "Coding")
  end
  test "should be valid" do
    assert @division.valid?
  end

  test "shoule have user_id" do
    @division.user_id = nil
    assert_not @division.valid?
  end

end
