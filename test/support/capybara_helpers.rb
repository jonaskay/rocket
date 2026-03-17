module CapybaraHelpers
  def visit_and_confirm(path, title:)
    visit path
    assert_title title
  end
end
