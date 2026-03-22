require "test_helper"
require_relative "support/capybara_helpers"
require_relative "support/minitest/reporters/failed_tests_reporter"

Minitest::Reporters.use! [
  Minitest::Reporters::ProgressReporter.new,
  FailedTestsReporter.new
]

Capybara.default_max_wait_time = 5

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include CapybaraHelpers

  if ENV["CAPYBARA_SERVER_PORT"]
    served_by host: "rails-app", port: ENV["CAPYBARA_SERVER_PORT"]

    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end
end
