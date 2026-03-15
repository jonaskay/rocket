require "test_helper"

class AdminClientsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
  end

  test "client accounts are listed with their details" do
    sign_in_as(@admin)

    get admin_clients_path

    assert_response :success
    assert_select "td", text: "Acme Corp"
    assert_select "td", text: "Beta Inc"
    assert_select "tr", text: /Acme Corp/ do
      assert_select "td", text: I18n.l(clients(:acme).created_at, format: :long)
    end
  end

  test "trainer count reflects only non-admin users for a client" do
    sign_in_as(@admin)

    get admin_clients_path

    assert_response :success
    assert_select "tr", text: /Acme Corp/ do
      assert_select "td", text: "2"
    end
  end

  test "empty state is shown when no client accounts exist" do
    Client.destroy_all
    sign_in_as(@admin)

    get admin_clients_path

    assert_response :success
    assert_select "p", text: /No client accounts yet/
  end

  test "client with only admin users appears with zero trainers" do
    sign_in_as(@admin)

    get admin_clients_path

    assert_response :success
    assert_select "tr", text: /Gamma Ltd/ do
      assert_select "td", text: "0"
    end
  end

  test "non-admin user is blocked from admin clients" do
    sign_in_as(users(:two))

    get admin_clients_path

    assert_redirected_to root_path
  end
end
