module CapybaraHelpers
  def visit_and_confirm(path, title:)
    visit path
    assert_title title
  end

  def click_link_and_confirm(locator, title:)
    click_link locator
    assert_title title
  end

  def click_button_and_confirm(locator, title:)
    click_button locator
    assert_title title
  end

  def sign_in_via_ui(user, password: "password")
    visit_and_confirm new_session_path, title: I18n.t("sessions.new.title")
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button "Sign in"
  end

  def sign_out_via_ui
    click_button "Sign out"
  end
end
