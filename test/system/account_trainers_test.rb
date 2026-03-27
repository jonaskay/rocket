require "application_system_test_case"

class AccountTrainersTest < ApplicationSystemTestCase
  test "account admin sees trainers listed with their status" do
    sign_in_and_open_trainer_roster

    assert_text users(:acme_trainer_one).email_address
    assert_text users(:acme_trainer_two).email_address
    assert_text users(:acme_trainer_three).email_address
    assert_text "Active"
    assert_text "Inactive"
    assert_text "Pending Password Change"
    assert_no_text users(:beta_trainer_one).email_address
  end

  test "admin removes a trainer from the roster" do
    trainer = users(:acme_trainer_one)

    sign_in_and_open_trainer_roster

    assert_text trainer.email_address
    within("tr", text: trainer.email_address) do
      accept_confirm do
        click_button "Remove"
      end
    end

    assert_text "has been removed"
    within("table") { assert_no_text trainer.email_address }
  end

  test "admin deactivates an active trainer and reactivates them" do
    trainer = users(:acme_trainer_one)

    sign_in_and_open_trainer_roster

    assert_text trainer.email_address
    within("tr", text: trainer.email_address) do
      assert_text "Active"
      accept_confirm do
        click_button "Deactivate"
      end
    end

    assert_text "has been deactivated"
    within("tr", text: trainer.email_address) do
      assert_text "Inactive"
      accept_confirm do
        click_button "Reactivate"
      end
    end

    assert_text "has been reactivated"
    within("tr", text: trainer.email_address) do
      assert_text "Active"
    end
  end

  private

  def sign_in_and_open_trainer_roster
    sign_in_via_ui users(:acme_admin)
    assert_current_path edit_account_settings_path
    click_link_and_confirm "Trainer Roster", title: I18n.t("account.trainers.index.title")
  end
end
