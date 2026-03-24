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
    assert_select "td", text: users(:beta_trainer_one).email_address, count: 0
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

  test "admin removes an active trainer" do
    sign_in_as(@account_admin)
    trainer = users(:acme_trainer_one)

    assert_difference "User.count", -1 do
      delete account_trainer_path(trainer)
    end

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match trainer.email_address, flash[:notice]
    assert_raises(ActiveRecord::RecordNotFound) { trainer.reload }
  end

  test "admin removes an inactive trainer" do
    sign_in_as(@account_admin)
    trainer = users(:acme_trainer_two)

    assert_difference "User.count", -1 do
      delete account_trainer_path(trainer)
    end

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match trainer.email_address, flash[:notice]
    assert_raises(ActiveRecord::RecordNotFound) { trainer.reload }
  end

  test "admin removes a pending trainer" do
    sign_in_as(@account_admin)
    trainer = users(:acme_trainer_three)

    assert_difference "User.count", -1 do
      delete account_trainer_path(trainer)
    end

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match trainer.email_address, flash[:notice]
    assert_raises(ActiveRecord::RecordNotFound) { trainer.reload }
  end

  test "admin fails to remove a trainer when destroy fails" do
    sign_in_as(@account_admin)
    trainer = users(:acme_trainer_one)

    User.before_destroy { throw :abort }

    assert_no_difference "User.count" do
      delete account_trainer_path(trainer)
    end

    assert_redirected_to account_trainers_path
    follow_redirect!
    assert_match trainer.email_address, flash[:alert]
  ensure
    User.reset_callbacks(:destroy)
    User.has_many :sessions, dependent: :destroy
  end

  test "admin cannot remove a trainer from another account" do
    sign_in_as(@account_admin)
    other_trainer = users(:beta_trainer_one)

    assert_no_difference "User.count" do
      delete account_trainer_path(other_trainer)
    end

    assert_response :not_found
  end

  test "admin cannot update a trainer from another account" do
    sign_in_as(@account_admin)
    other_trainer = users(:beta_trainer_one)
    original_attributes = other_trainer.attributes

    patch account_trainer_path(other_trainer), params: { user: { first_name: "Hacked" } }

    assert_response :not_found
    assert_equal original_attributes, other_trainer.reload.attributes
  end
end
