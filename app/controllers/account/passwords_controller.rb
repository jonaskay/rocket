class Account::PasswordsController < ApplicationController
  allow_pending_password_change_access
  before_action :require_password_change

  def edit
  end

  def update
    ApplicationRecord.transaction do
      Current.user.update!(password_params)
      Current.user.active!
    end
    redirect_to master_trainings_path, notice: t("account.passwords.update.success")
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  private

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def require_password_change
      redirect_to root_path unless Current.user.pending_password_change?
    end
end
