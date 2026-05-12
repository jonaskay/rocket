require "application_system_test_case"

class MasterTrainingsTest < ApplicationSystemTestCase
  test "trainer sees all master trainings for their account" do
    trainer = users(:acme_trainer_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    assert_text master_trainings(:acme_training_one).title
    assert_text master_trainings(:acme_training_two).title
  end

  test "trainer edits a master training title and description" do
    trainer = users(:acme_trainer_one)
    training = master_trainings(:acme_training_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    visit_and_confirm edit_master_training_path(training), title: "Edit Master Training"

    assert_field "Title", with: training.title
    assert_field "Description", with: training.description

    fill_in "Title", with: "Updated Safety Training"
    fill_in "Description", with: "Updated description text"

    click_button_and_confirm "Save changes", title: "Master Trainings"

    assert_text I18n.t("master_trainings.update.success")
    assert_text "Updated Safety Training"
  end
end
