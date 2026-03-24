require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:two) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to master_trainings_path
    assert cookies[:session_id]
  end

  test "create with valid admin credentials redirects to admin root" do
    admin = users(:one)
    post session_path, params: { email_address: admin.email_address, password: "password" }

    assert_redirected_to admin_root_url
    assert cookies[:session_id]
  end

  test "create with valid client admin credentials redirects to account settings" do
    client_admin = users(:acme_admin)
    post session_path, params: { email_address: client_admin.email_address, password: "password" }

    assert_redirected_to edit_account_settings_url
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(users(:two))

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
