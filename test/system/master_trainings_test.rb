require "application_system_test_case"

class MasterTrainingsTest < ApplicationSystemTestCase
  test "trainer sees all master trainings for their account" do
    trainer = users(:acme_trainer_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    assert_text master_trainings(:acme_training_one).title
    assert_text master_trainings(:acme_training_two).title
  end
end
