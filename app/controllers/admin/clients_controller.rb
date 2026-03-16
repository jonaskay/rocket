class Admin::ClientsController < Admin::ApplicationController
  def index
    @clients = Client
      .joins("LEFT JOIN users ON users.client_id = clients.id AND users.super_admin = FALSE AND users.client_admin = FALSE")
      .group("clients.id")
      .select("clients.*, COUNT(users.id) AS trainers_count")
      .order(:name)
  end

  def new
    @client = Client.new
    @client.users.build
  end

  def create
    @client = Client.new(client_params)
    @client.users.first&.client_admin = true

    if @client.save
      redirect_to admin_clients_path, notice: "Client account created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @client = Client.find(params[:id])
    @users = @client.users.order(:email_address)
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to admin_clients_path, notice: "Client account deleted successfully."
  end

  private

    def client_params
      params.expect(client: [ :name, users_attributes: [ [ :email_address, :password, :password_confirmation ] ] ])
    end
end
