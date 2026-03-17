require "application_system_test_case"

class AccountSettingsTest < ApplicationSystemTestCase
  test "account admin edits the organization name" do
    account_admin = users(:acme_admin)

    visit new_session_path
    fill_in "email_address", with: account_admin.email_address
    fill_in "password", with: "password"
    click_button "Sign in"
    assert_current_path root_path

    visit edit_account_settings_path

    fill_in "Organization Name", with: "New Org Name"
    click_button "Save Changes"

    assert_text "Organization name updated successfully."
    assert_selector "input[value='New Org Name']"
  end
end
