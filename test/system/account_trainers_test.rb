require "application_system_test_case"

class AccountTrainersTest < ApplicationSystemTestCase
  test "account admin sees trainers listed with their status" do
    account_admin = users(:acme_admin)

    sign_in_via_ui account_admin
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
