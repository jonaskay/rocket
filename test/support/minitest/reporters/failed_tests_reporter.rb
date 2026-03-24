require "fileutils"
require "minitest/reporters"

class FailedTestsReporter < Minitest::Reporters::BaseReporter
  FAILED_TESTS_FILE = Rails.root.join(".minitest_failed_tests")

  def start
    super
    FileUtils.rm_f(FAILED_TESTS_FILE)
    @failed_test_locations = []
  end

  def record(result)
    super
    return if result.skipped?
    return unless result.failure

    path, line = if result.respond_to?(:source_location)
      result.source_location
    else
      Object.const_get(result.klass).instance_method(result.name.to_sym).source_location
    end
    @failed_test_locations << "#{path}:#{line}"
  end

  def report
    super
    return if @failed_test_locations.empty?

    File.open(FAILED_TESTS_FILE, "a") do |f|
      f.write(@failed_test_locations.uniq.join("\n") + "\n")
    end
  end
end
