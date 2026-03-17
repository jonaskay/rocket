require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "client_admin user without a client is invalid" do
    user = User.new(email_address: "admin@example.com", password: "password", client_admin: true, client: nil)
    assert_not user.valid?
    assert_includes user.errors[:client], "can't be blank"
  end

  test "non-admin user without a client is valid" do
    user = User.new(email_address: "user@example.com", password: "password", client_admin: false, client: nil)
    user.valid?
    assert_empty user.errors[:client]
  end
end
