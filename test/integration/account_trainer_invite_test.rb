require "test_helper"

class AccountTrainerInviteIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @account_admin = users(:acme_admin)
  end

  test "new trainer form renders successfully" do
    sign_in_as(@account_admin)

    get new_account_trainer_path

    assert_response :success
    assert_select "input[name='user[first_name]']"
    assert_select "input[name='user[last_name]']"
    assert_select "input[name='user[email_address]']"
  end

  test "successful invitation creates user and sends email" do
    sign_in_as(@account_admin)

    assert_difference "User.count" do
      assert_emails 1 do
        post account_trainers_path, params: {
          user: {
            first_name: "Sam",
            last_name: "Taylor",
            email_address: "sam@acme.com"
          }
        }
      end
    end

    assert_redirected_to account_trainers_path
    assert_equal "Invitation sent to sam@acme.com.", flash[:notice]

    new_user = User.find_by!(email_address: "sam@acme.com")
    assert new_user.pending_password_change?
    assert_equal clients(:acme), new_user.client
    assert new_user.password_digest.present?
    refute new_user.client_admin?
    refute new_user.super_admin?
  end

  test "invitation email contains password reset link" do
    sign_in_as(@account_admin)

    email = nil
    perform_enqueued_jobs do
      post account_trainers_path, params: {
        user: {
          first_name: "Sam",
          last_name: "Taylor",
          email_address: "sam@acme.com"
        }
      }
      email = ActionMailer::Base.deliveries.last
    end

    assert_not_nil email
    assert_equal [ "sam@acme.com" ], email.to
    assert_match "3 days", email.body.encoded
    assert_match "/passwords/", email.body.encoded
  end

  test "blank email fails with validation error" do
    sign_in_as(@account_admin)
    assert_invitation_fails(first_name: "Sam", last_name: "Taylor", email_address: "")
    assert_select ".text-red-700", text: /can't be blank/
  end

  test "duplicate email fails with validation error" do
    sign_in_as(@account_admin)
    assert_invitation_fails(first_name: "Sam", last_name: "Taylor", email_address: users(:acme_trainer_one).email_address)
    assert_select ".text-red-700", text: /already been taken/
  end

  test "blank first name fails with validation error" do
    sign_in_as(@account_admin)
    assert_invitation_fails(first_name: "", last_name: "Taylor", email_address: "sam@acme.com")
    assert_select ".text-red-700", text: /can't be blank/
  end

  test "blank last name fails with validation error" do
    sign_in_as(@account_admin)
    assert_invitation_fails(first_name: "Sam", last_name: "", email_address: "sam@acme.com")
    assert_select ".text-red-700", text: /can't be blank/
  end

  private

  def assert_invitation_fails(user_params)
    assert_no_difference "User.count" do
      assert_no_emails do
        post account_trainers_path, params: { user: user_params }
      end
    end

    assert_response :unprocessable_entity
  end
end
