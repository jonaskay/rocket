require "test_helper"

class MasterTrainingsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @trainer = users(:acme_trainer_one)
    @other_trainer = users(:acme_trainer_two)
  end

  test "trainer views the dashboard with existing trainings" do
    sign_in_as(@trainer)

    get master_trainings_path

    assert_response :success
    assert_select "td", text: master_trainings(:acme_training_one).title
    assert_select "td", text: master_trainings(:acme_training_two).title
  end

  test "trainer sees empty state when no trainings exist" do
    sign_in_as(@trainer)
    MasterTraining.delete_all

    get master_trainings_path

    assert_response :success
    assert_select "p", text: I18n.t("master_trainings.empty")
  end

  test "trainer sees trainings created by other trainers in the same account" do
    acme_training_two = master_trainings(:acme_training_two)
    acme_training_two.update!(trainer: @other_trainer)

    sign_in_as(@trainer)

    get master_trainings_path

    assert_response :success
    assert_select "td", text: acme_training_two.title
  end

  test "super admin cannot access the master trainings dashboard" do
    sign_in_as(users(:one))

    get master_trainings_path

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "client admin cannot access the master trainings dashboard" do
    sign_in_as(users(:acme_admin))

    get master_trainings_path

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get master_trainings_path

    assert_redirected_to new_session_path
  end

  test "trainer from another account cannot see other client's trainings" do
    sign_in_as(users(:beta_trainer_one))

    get master_trainings_path

    assert_response :success
    assert_select "td", text: master_trainings(:acme_training_one).title, count: 0
    assert_select "td", text: master_trainings(:acme_training_two).title, count: 0
  end
end
