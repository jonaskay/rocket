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

  def update
    @trainer = current_client.users.trainers.find(params[:id])

    if @trainer.pending_password_change?
      redirect_to account_trainers_path, alert: t("account.trainers.update.cannot_deactivate_pending")
      return
    end

    if @trainer.active?
      @trainer.inactive!
      @trainer.sessions.destroy_all
      redirect_to account_trainers_path, notice: t("account.trainers.update.deactivated", email: @trainer.email_address)
    else
      @trainer.active!
      redirect_to account_trainers_path, notice: t("account.trainers.update.reactivated", email: @trainer.email_address)
    end
  end

  def destroy
    @trainer = current_client.users.trainers.find(params[:id])
    if @trainer.destroy
      redirect_to account_trainers_path, notice: t("account.trainers.destroy.removed", email: @trainer.email_address)
    else
      redirect_to account_trainers_path, alert: t("account.trainers.destroy.remove_failed", email: @trainer.email_address)
    end
  end

  private

  def trainer_params
    params.expect(user: [ :first_name, :last_name, :email_address ])
  end
end
