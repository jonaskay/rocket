class Admin::ApplicationController < ApplicationController
  before_action :require_admin

  private

    def require_admin
      redirect_to root_path, alert: t("admin.application.not_authorized") unless Current.user&.super_admin?
    end
end
