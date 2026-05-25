require "application_system_test_case"

class MasterTrainingsTest < ApplicationSystemTestCase
  test "trainer sees all master trainings for their account" do
    trainer = users(:acme_trainer_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    assert_text master_trainings(:acme_training_one).title
    assert_text master_trainings(:acme_training_two).title
  end

  test "trainer creates a master training with title and description" do
    trainer = users(:acme_trainer_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    click_link_and_confirm "New Master Training", title: "New Master Training"

    fill_in "master_training[title]", with: "Safety Training"
    fill_in "master_training[description]", with: "Comprehensive safety program"

    click_button_and_confirm "Create Master Training", title: "Master Trainings"

    assert_text I18n.t("master_trainings.create.success")
    assert_text "Safety Training"
  end

  test "trainer submits new form with blank title and sees validation error" do
    trainer = users(:acme_trainer_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    click_link_and_confirm "New Master Training", title: "New Master Training"

    fill_in "master_training[title]", with: ""

    click_button "Create Master Training"

    assert_selector "li", text: /Title/
  end

  test "trainer edits a master training title and description" do
    trainer = users(:acme_trainer_one)
    training = master_trainings(:acme_training_one)

    sign_in_via_ui trainer
    assert_current_path master_trainings_path

    visit_and_confirm edit_master_training_path(training), title: "Edit Master Training"

    assert_field "master_training[title]", with: training.title
    assert_field "master_training[description]", with: training.description

    fill_in "master_training[title]", with: "Updated Safety Training"
    fill_in "master_training[description]", with: "Updated description text"

    click_button_and_confirm "Save changes", title: "Master Trainings"

    assert_text I18n.t("master_trainings.update.success")
    assert_text "Updated Safety Training"
  end
end
