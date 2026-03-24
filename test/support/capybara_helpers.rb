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

  def sign_in_via_ui(user, password: "password", title: nil)
    visit_and_confirm new_session_path, title: I18n.t("sessions.new.title")
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    if title
      click_button_and_confirm "Sign in", title: title
    else
      click_button "Sign in"
    end
  end

  def sign_out_via_ui
    click_button_and_confirm "Sign out", title: I18n.t("sessions.new.title")
  end
end
