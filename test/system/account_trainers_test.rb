require "application_system_test_case"

class AccountTrainersTest < ApplicationSystemTestCase
  test "account admin sees trainers listed with their status" do
    visit_trainer_roster_as users(:acme_admin)

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

    visit_trainer_roster_as users(:acme_admin)

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

    visit_trainer_roster_as users(:acme_admin)

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
end
