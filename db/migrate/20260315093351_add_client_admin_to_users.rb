class AddClientAdminToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :client_admin, :boolean, null: false, default: false
  end
end
