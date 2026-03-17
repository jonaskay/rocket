class Account::TrainersController < Account::ApplicationController
  def index
    @trainers = current_client.users.trainers
  end
end
