require "test_helper"

class TrainerInviteActivationIntegrationTest < ActionDispatch::IntegrationTest
  test "password update changes status from pending_password_change to active" do
    user = users(:acme_trainer_three)
    assert user.pending_password_change?

    token = user.password_reset_token
    patch password_path(token), params: { password: "newpassword123!", password_confirmation: "newpassword123!" }

    assert_redirected_to new_session_path
    assert_equal I18n.t("passwords.update.success"), flash[:notice]

    user.reload
    assert user.active?
  end

  test "password update for already active user does not change status" do
    user = users(:acme_trainer_one)
    assert user.active?

    token = user.password_reset_token
    patch password_path(token), params: { password: "newpassword123!", password_confirmation: "newpassword123!" }

    assert_redirected_to new_session_path

    user.reload
    assert user.active?
  end

  test "inactive user cannot log in" do
    user = users(:acme_trainer_two)
    assert user.inactive?

    post session_path, params: { email_address: user.email_address, password: "password" }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "#alert", text: /deactivated/
  end

  test "inactive user login creates no session" do
    user = users(:acme_trainer_two)

    assert_no_difference "Session.count" do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
  end

  test "active user can log in" do
    user = users(:acme_trainer_one)

    assert_difference "Session.count" do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    assert_redirected_to root_url
  end
end
