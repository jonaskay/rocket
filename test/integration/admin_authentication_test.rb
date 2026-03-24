require "test_helper"

class AdminAuthenticationIntegrationTest < ActionDispatch::IntegrationTest
  test "invalid credentials are rejected" do
    post session_path, params: { email_address: users(:one).email_address, password: "wrong" }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_response :success
    assert_select "#alert", text: /email address or password/
  end

  test "unauthenticated request to admin home is blocked" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "non-super-admin user is blocked from admin home" do
    sign_in_as(users(:two))

    get admin_root_path

    assert_redirected_to root_path
    assert_equal "Not authorized.", flash[:alert]
  end

  test "non-admin user visiting admin then logging in is redirected to master trainings" do
    get admin_root_path
    assert_redirected_to new_session_path

    post session_path, params: { email_address: users(:two).email_address, password: "password" }

    assert_redirected_to master_trainings_path
  end

  test "admin user is redirected to admin home after login" do
    post session_path, params: { email_address: users(:one).email_address, password: "password" }

    assert_redirected_to admin_root_path
  end
end
