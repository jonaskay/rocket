require "test_helper"

class ForcedPasswordChangeTest < ActionDispatch::IntegrationTest
  setup do
    @pending_user = users(:acme_trainer_three)
  end

  test "pending user is redirected to change-password page after login" do
    post session_path, params: { email_address: @pending_user.email_address, password: "password" }

    assert_redirected_to edit_account_password_path
  end

  test "pending user login creates a session" do
    assert_difference "Session.count" do
      post session_path, params: { email_address: @pending_user.email_address, password: "password" }
    end
  end

  test "pending user cannot navigate to other pages" do
    sign_in_as(@pending_user)

    get root_path

    assert_redirected_to edit_account_password_path
  end

  test "pending user cannot navigate to account settings" do
    sign_in_as(@pending_user)

    get edit_account_settings_path

    assert_redirected_to edit_account_password_path
  end

  test "pending user can access the change-password page" do
    sign_in_as(@pending_user)

    get edit_account_password_path

    assert_response :success
  end

  test "submitting a valid password changes status to active and redirects to home" do
    sign_in_as(@pending_user)

    patch account_password_path, params: { user: { password: "newpassword123!", password_confirmation: "newpassword123!" } }

    assert_redirected_to master_trainings_path
    assert_equal I18n.t("account.passwords.update.success"), flash[:notice]

    @pending_user.reload
    assert @pending_user.active?
  end

  test "submitting mismatched passwords re-renders the form with errors" do
    sign_in_as(@pending_user)

    patch account_password_path, params: { user: { password: "newpassword123!", password_confirmation: "different!" } }

    assert_response :unprocessable_entity

    @pending_user.reload
    assert @pending_user.pending_password_change?
  end

  test "active user is not redirected to change-password page" do
    user = users(:acme_trainer_one)
    sign_in_as(user)

    get root_path

    assert_response :success
  end

  test "active user cannot access change-password page" do
    user = users(:acme_trainer_one)
    sign_in_as(user)

    get edit_account_password_path

    assert_redirected_to root_path
  end
end
