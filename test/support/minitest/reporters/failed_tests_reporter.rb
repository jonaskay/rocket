require "fileutils"
require "minitest/reporters"

class FailedTestsReporter < Minitest::Reporters::BaseReporter
  FAILED_TESTS_FILE = Rails.root.join(".minitest_failed_tests")

  def start
    super
    FileUtils.rm_f(FAILED_TESTS_FILE)
    @failures = []
  end

  def record(result)
    super
    return if result.skipped?
    return unless result.failure

    path, line = result.klass.instance_method(result.name.to_sym).source_location
    @failures << "#{path}:#{line}"
  end

  def report
    super
    return if @failures.empty?

    File.open(FAILED_TESTS_FILE, "a") do |f|
      f.write(@failures.uniq.join("\n") + "\n")
    end
  end
end
