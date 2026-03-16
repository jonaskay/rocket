class RenameAdminToSuperAdminOnUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :admin, :super_admin
  end
end
