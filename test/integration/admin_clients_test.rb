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
      assert_select "td", text: "3"
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

  test "new client account form renders successfully" do
    sign_in_as(@admin)

    get new_admin_client_path

    assert_response :success
    assert_select "input[name='client[name]']"
    assert_select "input[name='client[users_attributes][0][email_address]']"
    assert_select "input[name='client[users_attributes][0][password]']"
  end

  test "valid client account and account admin user are created" do
    sign_in_as(@admin)

    assert_difference([ "Client.count", "User.count" ]) do
      post admin_clients_path, params: valid_client_params
    end

    assert_redirected_to admin_clients_path
    assert_equal "Client account created successfully.", flash[:notice]
    new_client = Client.find_by!(name: "Delta Corp")
    new_user = new_client.users.first
    assert new_user.client_admin?
    assert_equal new_client, new_user.client
  end

  test "creation fails when client name is blank" do
    sign_in_as(@admin)

    assert_no_difference "Client.count" do
      post admin_clients_path, params: valid_client_params(name: "")
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-700", text: /can't be blank/
  end

  test "creation fails when admin email is blank" do
    sign_in_as(@admin)

    assert_no_difference [ "Client.count", "User.count" ] do
      post admin_clients_path, params: valid_client_params(user: { email_address: "" })
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-700", text: /can't be blank/
  end

  test "creation fails when admin email is already taken" do
    sign_in_as(@admin)

    assert_no_difference "Client.count" do
      post admin_clients_path, params: valid_client_params(user: { email_address: users(:acme_admin).email_address })
    end

    assert_response :unprocessable_entity
  end

  test "creation fails when password confirmation does not match" do
    sign_in_as(@admin)

    assert_no_difference [ "Client.count", "User.count" ] do
      post admin_clients_path, params: valid_client_params(user: { password_confirmation: "wrongpassword" })
    end

    assert_response :unprocessable_entity
  end

  test "show page renders client name and user list" do
    sign_in_as(@admin)

    get admin_client_path(clients(:acme))

    assert_response :success
    assert_select "h1", text: "Acme Corp"
    assert_select "td", text: "admin@acme.com"
    assert_select "td", text: "trainer1@acme.com"
  end

  test "show page labels client admin and trainer roles correctly" do
    sign_in_as(@admin)

    get admin_client_path(clients(:acme))

    assert_response :success
    assert_select "span", text: "Account Admin"
    assert_select "span", text: "Trainer"
  end

  test "destroy removes client and associated users and redirects" do
    sign_in_as(@admin)

    assert_difference([ "Client.count", "User.count" ], -1) do
      delete admin_client_path(clients(:gamma))
    end

    assert_redirected_to admin_clients_path
    assert_equal "Client account deleted successfully.", flash[:notice]
    assert_nil Client.find_by(name: "Gamma Ltd")
  end

  test "destroy removes client with multiple users" do
    sign_in_as(@admin)

    acme_user_count = clients(:acme).users.count
    assert_difference("Client.count", -1) do
      assert_difference("User.count", -acme_user_count) do
        delete admin_client_path(clients(:acme))
      end
    end

    assert_redirected_to admin_clients_path
  end

  private

  def valid_client_params(name: "Delta Corp", user: {})
    user_attrs = {
      first_name: "Admin",
      last_name: "User",
      email_address: "admin@delta.com",
      password: "securepassword",
      password_confirmation: "securepassword"
    }.merge(user)

    { client: { name: name, users_attributes: { "0" => user_attrs } } }
  end
end
