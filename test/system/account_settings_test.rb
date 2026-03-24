require "application_system_test_case"

class AccountSettingsTest < ApplicationSystemTestCase
  test "account admin edits the organization name" do
    account_admin = users(:acme_admin)

    sign_in_via_ui account_admin
    assert_current_path edit_account_settings_path

    fill_in "Organization Name", with: "New Org Name"
    click_button_and_confirm "Save Changes", title: I18n.t("account.settings.edit.title")

    assert_text "Organization name updated successfully."
    assert_selector "input[value='New Org Name']"
  end
end
