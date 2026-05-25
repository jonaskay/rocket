class MasterTrainingsController < ApplicationController
  before_action :require_trainer
  before_action :set_master_training, only: %i[ edit update ]

  def index
    @master_trainings = current_client.master_trainings.order(updated_at: :desc)
  end

  def edit
  end

  def update
    if @master_training.update(master_training_params)
      redirect_to master_trainings_path, notice: t("master_trainings.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_master_training
    @master_training = current_client.master_trainings.find(params[:id])
  end

  def require_trainer
    unless Current.user&.trainer?
      redirect_to root_path, alert: t("master_trainings.unauthorized")
    end
  end

  def current_client
    Current.user.client
  end

  def master_training_params
    params.expect(master_training: [ :title, :description ])
  end
end
