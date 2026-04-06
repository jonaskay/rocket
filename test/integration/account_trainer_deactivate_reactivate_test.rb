require "test_helper"

class AccountTrainerDeactivateReactivateTest < ActionDispatch::IntegrationTest
  setup do
    @account_admin = users(:acme_admin)
    @active_trainer = users(:acme_trainer_one)
    @inactive_trainer = users(:acme_trainer_two)
    @pending_trainer = users(:acme_trainer_three)
    @other_account_trainer = users(:beta_trainer_one)
    sign_in_as(@account_admin)
  end

  test "admin deactivates an active trainer" do
    patch account_trainer_path(@active_trainer)

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match /has been deactivated/, response.body

    @active_trainer.reload
    assert @active_trainer.inactive?
  end

  test "deactivating a trainer destroys all their sessions" do
    @active_trainer.sessions.create!

    assert_difference "@active_trainer.sessions.count", -1 do
      patch account_trainer_path(@active_trainer)
    end

    assert_equal 0, @active_trainer.reload.sessions.count
  end

  test "admin reactivates an inactive trainer" do
    patch account_trainer_path(@inactive_trainer)

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match /has been reactivated/, response.body

    @inactive_trainer.reload
    assert @inactive_trainer.active?
  end

  test "admin cannot deactivate a pending_password_change trainer" do
    patch account_trainer_path(@pending_trainer)

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match /pending invitation/, response.body

    @pending_trainer.reload
    assert @pending_trainer.pending_password_change?
  end

  test "admin cannot toggle a trainer from another account" do
    patch account_trainer_path(@other_account_trainer)

    assert_response :not_found
  end

  test "deactivated trainer existing session is invalidated on next request" do
    trainer_session = @active_trainer.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = trainer_session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end

    @active_trainer.inactive!

    get account_trainers_path

    assert_redirected_to new_session_path
    assert_equal 0, @active_trainer.reload.sessions.count
  end
end
