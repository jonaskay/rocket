class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: t("sessions.create.rate_limit_exceeded") }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.inactive?
        redirect_to new_session_path, alert: t("sessions.create.account_deactivated")
      elsif user.pending_password_change?
        redirect_to new_session_path, alert: t("sessions.create.account_not_activated")
      else
        start_new_session_for user
        redirect_to after_authentication_url
      end
    else
      redirect_to new_session_path, alert: t("sessions.create.invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private

    def after_authentication_url
      return_url = session.delete(:return_to_after_authenticating)

      if Current.user&.super_admin?
        return_url || admin_root_url
      elsif Current.user&.client_admin?
        return_url = nil if return_url && URI.parse(return_url).path.start_with?("/admin")
        return_url || edit_account_settings_url
      else
        return_url = nil if return_url && URI.parse(return_url).path.start_with?("/admin")
        return_url || root_url
      end
    rescue URI::InvalidURIError
      if Current.user&.super_admin?
        admin_root_url
      elsif Current.user&.client_admin?
        edit_account_settings_url
      else
        root_url
      end
    end
end
