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

  test "super admin cannot access the edit action" do
    training = master_trainings(:acme_training_one)
    sign_in_as(users(:one))

    get edit_master_training_path(training)

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "super admin cannot access the update action" do
    training = master_trainings(:acme_training_one)
    sign_in_as(users(:one))

    patch master_training_path(training), params: {
      master_training: { title: "Hijacked", description: "" }
    }

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "client admin cannot access the master trainings dashboard" do
    sign_in_as(users(:acme_admin))

    get master_trainings_path

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "client admin cannot access the edit action" do
    training = master_trainings(:acme_training_one)
    sign_in_as(users(:acme_admin))

    get edit_master_training_path(training)

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "client admin cannot access the update action" do
    training = master_trainings(:acme_training_one)
    sign_in_as(users(:acme_admin))

    patch master_training_path(training), params: {
      master_training: { title: "Hijacked", description: "" }
    }

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "client admin cannot access the new action" do
    sign_in_as(users(:acme_admin))

    get new_master_training_path

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "client admin cannot access the create action" do
    sign_in_as(users(:acme_admin))

    post master_trainings_path, params: {
      master_training: { title: "Hijacked", description: "" }
    }

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "unauthenticated user is redirected to sign in" do
    get master_trainings_path

    assert_redirected_to new_session_path
  end

  test "unauthenticated user attempting to access edit is redirected to sign in" do
    training = master_trainings(:acme_training_one)

    get edit_master_training_path(training)

    assert_redirected_to new_session_path
  end

  test "unauthenticated user attempting to update via PATCH is redirected to sign in" do
    training = master_trainings(:acme_training_one)

    patch master_training_path(training), params: {
      master_training: { title: "Hijacked", description: "" }
    }

    assert_redirected_to new_session_path
  end

  test "trainer from another account cannot see other client's trainings" do
    sign_in_as(users(:beta_trainer_one))

    get master_trainings_path

    assert_response :success
    assert_select "td", text: master_trainings(:acme_training_one).title, count: 0
    assert_select "td", text: master_trainings(:acme_training_two).title, count: 0
  end

  test "trainer from another account cannot create a master training" do
    beta_trainer = users(:beta_trainer_one)
    sign_in_as(beta_trainer)

    assert_no_difference -> { @trainer.client.master_trainings.count } do
      assert_difference -> { beta_trainer.client.master_trainings.count }, 1 do
        post master_trainings_path, params: {
          master_training: { title: "Cross-Client Training", description: "" }
        }
      end
    end

    assert_redirected_to master_trainings_path
  end

  test "trainer successfully accesses new form" do
    sign_in_as(@trainer)

    get new_master_training_path

    assert_response :success
  end

  test "trainer creates a master training with valid data" do
    sign_in_as(@trainer)

    assert_difference "MasterTraining.count", 1 do
      post master_trainings_path, params: {
        master_training: { title: "Safety Training", description: "Comprehensive safety program" }
      }
    end

    assert_redirected_to master_trainings_path
    assert_equal I18n.t("master_trainings.create.success"), flash[:notice]
  end

  test "created master training belongs to the trainer's client" do
    sign_in_as(@trainer)

    post master_trainings_path, params: {
      master_training: { title: "Safety Training", description: "" }
    }

    training = MasterTraining.order(created_at: :desc).first
    assert_equal @trainer.client, training.client
    assert_equal @trainer, training.trainer
  end

  test "trainer cannot create a master training without a title" do
    sign_in_as(@trainer)

    assert_no_difference "MasterTraining.count" do
      post master_trainings_path, params: {
        master_training: { title: "", description: "Some description" }
      }
    end

    assert_response :unprocessable_entity
    assert_select "li", text: /Title/
  end

  test "super admin cannot access the new action" do
    sign_in_as(users(:one))

    get new_master_training_path

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "super admin cannot access the create action" do
    sign_in_as(users(:one))

    post master_trainings_path, params: {
      master_training: { title: "Hijacked", description: "" }
    }

    assert_redirected_to root_path
    assert_equal I18n.t("master_trainings.unauthorized"), flash[:alert]
  end

  test "unauthenticated user attempting to access new is redirected to sign in" do
    get new_master_training_path

    assert_redirected_to new_session_path
  end

  test "unauthenticated user attempting to create via POST is redirected to sign in" do
    post master_trainings_path, params: {
      master_training: { title: "Test", description: "" }
    }

    assert_redirected_to new_session_path
  end

  test "trainer successfully accesses edit" do
    training = master_trainings(:acme_training_one)
    sign_in_as(@trainer)

    get edit_master_training_path(training)

    assert_response :success
  end

  test "trainer successfully updates title and description" do
    training = master_trainings(:acme_training_one)
    sign_in_as(@trainer)

    patch master_training_path(training), params: {
      master_training: { title: "Updated Title", description: "Updated description" }
    }

    assert_redirected_to master_trainings_path
    assert_equal I18n.t("master_trainings.update.success"), flash[:notice]
    assert_equal "Updated Title", training.reload.title
    assert_equal "Updated description", training.reload.description
  end

  test "trainer submits with a blank title" do
    training = master_trainings(:acme_training_one)
    sign_in_as(@trainer)

    patch master_training_path(training), params: {
      master_training: { title: "", description: "Some description" }
    }

    assert_response :unprocessable_entity
    assert_select "li", text: /Title/
    assert_equal training.title, training.reload.title
  end

  test "trainer clears the description" do
    training = master_trainings(:acme_training_one)
    sign_in_as(@trainer)

    patch master_training_path(training), params: {
      master_training: { title: "Valid Title", description: "" }
    }

    assert_redirected_to master_trainings_path
    assert_equal "Valid Title", training.reload.title
    assert_equal "", training.reload.description
  end

  test "trainer cannot edit another client's master training" do
    other_training = master_trainings(:beta_training_one)
    sign_in_as(@trainer)

    get edit_master_training_path(other_training)

    assert_response :not_found
  end

  test "trainer cannot update another client's master training" do
    other_training = master_trainings(:beta_training_one)
    sign_in_as(@trainer)

    patch master_training_path(other_training), params: {
      master_training: { title: "Hijacked", description: "" }
    }

    assert_response :not_found
  end
end
