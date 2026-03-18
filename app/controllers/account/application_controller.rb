class Account::ApplicationController < ApplicationController
  before_action :require_client_admin

  private

    def require_client_admin
      unless Current.user&.client_admin?
        redirect_to root_path, alert: t("account.application.not_authorized")
      end
    end

    def current_client
      Current.user.client
    end
    helper_method :current_client
end
