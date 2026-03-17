require "application_system_test_case"

class AccountTrainersTest < ApplicationSystemTestCase
  test "account admin sees trainers listed with their status" do
    account_admin = users(:acme_admin)

    visit_and_confirm new_session_path, title: "Rocket"
    fill_in "email_address", with: account_admin.email_address
    fill_in "password", with: "password"
    click_button "Sign in"
    assert_current_path edit_account_settings_path

    click_on "Trainer Roster"

    assert_text users(:acme_trainer_one).email_address
    assert_text users(:acme_trainer_two).email_address
    assert_text users(:acme_trainer_three).email_address
    assert_text "Active"
    assert_text "Inactive"
    assert_text "Pending Password Change"
  end
end
