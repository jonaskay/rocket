class Admin::ClientsController < Admin::ApplicationController
  def index
    @clients = Client
      .joins("LEFT JOIN users ON users.client_id = clients.id AND users.admin = FALSE")
      .group("clients.id")
      .select("clients.*, COUNT(users.id) AS trainers_count")
      .order(:name)
  end
end
