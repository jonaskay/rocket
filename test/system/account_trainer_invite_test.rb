require "application_system_test_case"

class AccountTrainerInviteTest < ApplicationSystemTestCase
  test "account admin invites a new trainer successfully" do
    account_admin = users(:acme_admin)

    sign_in_via_ui account_admin

    click_on "Trainer Roster"
    click_on "Invite Trainer"

    fill_in "First Name", with: "Sam"
    fill_in "Last Name", with: "Taylor"
    fill_in "Email", with: "sam@acme.com"
    click_button "Send Invitation"

    assert_current_path account_trainers_path
    assert_text "Invitation sent to sam@acme.com."
    assert_text "sam@acme.com"
  end

  test "trainer accepts invitation, sets password, and logs in" do
    trainer = users(:acme_trainer_three)
    assert trainer.pending_password_change?

    token = trainer.password_reset_token

    visit_and_confirm edit_password_path(token), title: I18n.t("passwords.edit.title")

    fill_in "password", with: "newpassword123!"
    fill_in "password_confirmation", with: "newpassword123!"
    click_button "Save"

    assert_current_path new_session_path
    assert_text I18n.t("passwords.update.success")

    fill_in "email_address", with: trainer.email_address
    fill_in "password", with: "newpassword123!"
    click_button "Sign in"

    assert_current_path root_path

    trainer.reload
    assert trainer.active?
  end

  test "invite form shows validation errors for blank fields" do
    account_admin = users(:acme_admin)

    sign_in_via_ui account_admin

    click_on "Trainer Roster"
    click_on "Invite Trainer"

    click_button "Send Invitation"

    assert_text "can't be blank"
  end
end
