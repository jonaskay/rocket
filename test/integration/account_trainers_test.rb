require "test_helper"

class AccountTrainersIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @account_admin = users(:acme_admin)
  end

  test "trainer roster lists all trainers for the current client only" do
    sign_in_as(@account_admin)

    get account_trainers_path

    assert_response :success
    assert_select "td", text: users(:acme_trainer_one).email_address
    assert_select "td", text: users(:acme_trainer_two).email_address
    assert_select "td", text: users(:gamma_admin).email_address, count: 0
  end

  test "trainer roster displays correct status for each trainer" do
    sign_in_as(@account_admin)

    get account_trainers_path

    assert_response :success
    assert_select "span", text: "Active"
    assert_select "span", text: "Inactive"
    assert_select "span", text: "Pending Password Change"
  end

  test "account admin users are not shown in the trainer roster" do
    sign_in_as(@account_admin)

    get account_trainers_path

    assert_response :success
    assert_select "td", text: @account_admin.email_address, count: 0
    assert_select "td", text: users(:acme_trainer_one).email_address
  end

  test "non-account-admin is blocked from trainer roster" do
    sign_in_as(users(:acme_trainer_one))

    get account_trainers_path

    assert_redirected_to root_path
  end
end
