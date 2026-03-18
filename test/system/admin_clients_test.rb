require "application_system_test_case"

class AdminClientsTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
  end

  test "super admin creates a new client account with initial account admin user" do
    visit_and_confirm new_session_path, title: "Rocket"

    fill_in "email_address", with: @admin.email_address
    fill_in "password", with: "password"
    click_button_and_confirm "Sign in", path: admin_root_path

    click_link_and_confirm "Client Accounts", path: admin_clients_path
    click_link_and_confirm "New Client Account", path: new_admin_client_path

    assert_text "Account Details"
    fill_in "Client Account Name", with: "Delta Corp"
    fill_in "First Name", with: "Alice"
    fill_in "Last Name", with: "Smith"
    fill_in "Email", with: "admin@delta.com"
    fill_in "Password", with: "securepassword"
    fill_in "Password Confirmation", with: "securepassword"
    click_button_and_confirm "Create Client Account", path: admin_clients_path

    assert_current_path admin_clients_path
    assert_text "Client account created successfully"
    assert_text "Delta Corp"
  end

  test "super admin sees client accounts with trainer counts" do
    visit_and_confirm new_session_path, title: "Rocket"

    fill_in "email_address", with: @admin.email_address
    fill_in "password", with: "password"
    click_button_and_confirm "Sign in", path: admin_root_path

    assert_text @admin.email_address
    click_link_and_confirm "Client Accounts", path: admin_clients_path

    assert_text "Acme Corp"
    assert_text "Beta Inc"

    within "tr", text: "Acme Corp" do
      assert_text "3"
    end

    within "tr", text: "Beta Inc" do
      assert_text "0"
    end
  end
end
