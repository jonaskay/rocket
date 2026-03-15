require "application_system_test_case"

class AdminClientsTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
  end

  test "super admin creates a new client account with initial account admin user" do
    visit new_session_path

    fill_in "email_address", with: @admin.email_address
    fill_in "password", with: "password"
    click_button "Sign in"

    click_link "Client Accounts"
    click_link "New Client Account"

    fill_in "Client Account Name", with: "Delta Corp"
    fill_in "Email", with: "admin@delta.com"
    fill_in "Password", with: "securepassword"
    fill_in "Password Confirmation", with: "securepassword"
    click_button "Create Client Account"

    assert_current_path admin_clients_path
    assert_text "Client account created successfully"
    assert_text "Delta Corp"
  end

  test "super admin sees client accounts with trainer counts" do
    visit new_session_path

    fill_in "email_address", with: @admin.email_address
    fill_in "password", with: "password"
    click_button "Sign in"

    click_link "Client Accounts"

    assert_text "Acme Corp"
    assert_text "Beta Inc"

    within "tr", text: "Acme Corp" do
      assert_text "2"
    end

    within "tr", text: "Beta Inc" do
      assert_text "0"
    end
  end
end
