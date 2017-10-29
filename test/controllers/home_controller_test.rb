require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get home_home_url
    assert_response :success
  end

  test "should get signup" do
    get home_signup_url
    assert_response :success
  end

end
