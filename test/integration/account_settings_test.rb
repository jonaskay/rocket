require "test_helper"

class AccountSettingsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @account_admin = users(:acme_admin)
    @client = clients(:acme)
  end

  test "account admin successfully updates organization name" do
    sign_in_as(@account_admin)

    patch account_settings_path, params: { client: { name: "Updated Corp" } }

    assert_redirected_to edit_account_settings_path
    assert_equal "Organization name updated successfully.", flash[:notice]
    assert_equal "Updated Corp", @client.reload.name
  end

  test "update fails when organization name is blank" do
    sign_in_as(@account_admin)
    original_name = @client.name

    patch account_settings_path, params: { client: { name: "" } }

    assert_response :unprocessable_entity
    assert_equal original_name, @client.reload.name
    assert_select ".text-red-700", text: /can't be blank/
  end

  test "edit settings page renders successfully" do
    sign_in_as(@account_admin)

    get edit_account_settings_path

    assert_response :success
    assert_select "input[name='client[name]'][value='#{@client.name}']"
  end

  test "non-client-admin user cannot access account settings" do
    sign_in_as(users(:acme_trainer_one))

    get edit_account_settings_path

    assert_redirected_to root_path
    assert_equal "Not authorized.", flash[:alert]
  end

  test "super admin without a client cannot access account settings" do
    sign_in_as(users(:one))

    get edit_account_settings_path

    assert_redirected_to root_path
    assert_equal "Not authorized.", flash[:alert]
  end

  test "settings page shows own account name and not other accounts" do
    sign_in_as(@account_admin)

    get edit_account_settings_path

    assert_response :success
    assert_match clients(:acme).name, response.body
    assert_no_match clients(:beta).name, response.body
    assert_no_match clients(:gamma).name, response.body
  end
end
