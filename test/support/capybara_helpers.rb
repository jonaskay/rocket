module CapybaraHelpers
  def visit_and_confirm(path, title:)
    visit path
    assert_title title
  end

  def click_link_and_confirm(locator, path:)
    click_link locator
    assert_current_path path
  end

  def click_button_and_confirm(locator, path:)
    click_button locator
    assert_current_path path
  end

  def sign_in_via_ui(user, password: "password")
    visit_and_confirm new_session_path, title: "Rocket"
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button "Sign in"
  end

  def sign_out_via_ui
    click_button "Sign out"
  end
end
