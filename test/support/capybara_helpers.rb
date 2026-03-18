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
end
