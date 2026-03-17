class Account::SettingsController < Account::ApplicationController
  def edit
    @client = current_client
  end

  def update
    @client = current_client
    if @client.update(client_params)
      redirect_to edit_account_settings_path, notice: "Organization name updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def client_params
      params.expect(client: [ :name ])
    end
end
