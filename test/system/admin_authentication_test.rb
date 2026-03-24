require "application_system_test_case"

class AdminAuthenticationTest < ApplicationSystemTestCase
  setup do
    @admin = users(:one)
    @non_admin = users(:two)
  end

  test "sign in and sign out successfully" do
    sign_in_via_ui @admin
    assert_current_path admin_root_path

    sign_out_via_ui

    assert_current_path new_session_path

    visit_and_confirm admin_root_path, title: I18n.t("sessions.new.title")
    assert_current_path new_session_path
  end
end
