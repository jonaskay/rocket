require "application_system_test_case"

class AdminAuthenticationTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @non_admin = users(:two)
  end

  test "sign in and sign out successfully" do
    visit_and_confirm new_session_path, title: "Rocket"

    fill_in "email_address", with: @admin.email_address
    fill_in "password", with: "password"
    click_button "Sign in"

    assert_current_path admin_root_path

    click_button "Sign out"

    assert_current_path new_session_path

    visit_and_confirm admin_root_path, title: "Rocket"
    assert_current_path new_session_path
  end
end
