class Account::TrainersController < Account::ApplicationController
  def index
    @trainers = current_client.users.trainers
  end

  def new
    @user = current_client.users.build
  end

  def create
    @user = current_client.users.build(trainer_params)
    @user.status = :pending_password_change
    @user.client_admin = false
    @user.super_admin = false
    @user.password = @user.password_confirmation = SecureRandom.base36(24)

    if @user.save
      TrainerInvitationMailer.invite(@user).deliver_later
      redirect_to account_trainers_path, notice: t("account.trainers.create.invitation_sent", email: @user.email_address)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def trainer_params
    params.expect(user: [ :first_name, :last_name, :email_address ])
  end
end
