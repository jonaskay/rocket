class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t("passwords.create.rate_limit_exceeded") }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t("passwords.create.success")
  end

  def edit
  end

  def update
    ApplicationRecord.transaction do
      @user.update!(params.permit(:password, :password_confirmation))
      @user.active! if @user.pending_password_change?
      @user.sessions.destroy_all
    end
    redirect_to new_session_path, notice: t("passwords.update.success")
  rescue ActiveRecord::RecordInvalid
    redirect_to edit_password_path(params[:token]), alert: t("passwords.update.passwords_mismatch")
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t("passwords.set_user_by_token.invalid_token")
    end
end
