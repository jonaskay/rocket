require "test_helper"
require_relative "../../minitest/reporters/failed_tests_reporter"

class FailedTestsReporterTest < ActiveSupport::TestCase
  setup do
    @reporter = FailedTestsReporter.new
    @failed_tests_file = FailedTestsReporter::FAILED_TESTS_FILE
    FileUtils.rm_f(@failed_tests_file)
    @reporter.start
  end

  teardown do
    FileUtils.rm_f(@failed_tests_file)
  end

  test "does not write file when there are no failures" do
    @reporter.report

    assert_not File.exist?(@failed_tests_file)
  end

  test "writes failed test source locations to file using result.source_location" do
    result = mock_result(
      source_location: [ "/path/to/test.rb", 10 ],
      failure: Minitest::Assertion.new("failed")
    )

    @reporter.record(result)
    @reporter.report

    assert File.exist?(@failed_tests_file)
    assert_equal "/path/to/test.rb:10\n", File.read(@failed_tests_file)
  end

  test "does not record skipped tests" do
    result = mock_result(
      source_location: [ "/path/to/test.rb", 5 ],
      failure: Minitest::Skip.new("skipped")
    )

    @reporter.record(result)
    @reporter.report

    assert_not File.exist?(@failed_tests_file)
  end

  test "does not record passing tests" do
    result = mock_result(
      source_location: [ "/path/to/test.rb", 5 ]
    )

    @reporter.record(result)
    @reporter.report

    assert_not File.exist?(@failed_tests_file)
  end

  test "deduplicates failures from the same location" do
    result = mock_result(
      source_location: [ "/path/to/test.rb", 10 ],
      failure: Minitest::Assertion.new("failed")
    )

    @reporter.record(result)
    @reporter.record(result)
    @reporter.report

    assert_equal "/path/to/test.rb:10\n", File.read(@failed_tests_file)
  end

  private

  def mock_result(source_location:, failure: nil)
    result = Minitest::Result.new("test_something")
    result.source_location = source_location
    result.failures = failure ? [ failure ] : []
    result
  end
end
