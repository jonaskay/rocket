class MasterTrainingsController < ApplicationController
  before_action :require_trainer

  def index
    @master_trainings = current_client.master_trainings.order(updated_at: :desc)
  end

  private

  def require_trainer
    unless Current.user&.trainer?
      redirect_to root_path, alert: t("master_trainings.unauthorized")
    end
  end

  def current_client
    Current.user.client
  end
end
