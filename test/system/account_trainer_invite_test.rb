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

  test "invite form shows validation errors for blank fields" do
    account_admin = users(:acme_admin)

    sign_in_via_ui account_admin

    click_on "Trainer Roster"
    click_on "Invite Trainer"

    click_button "Send Invitation"

    assert_text "can't be blank"
  end
end
