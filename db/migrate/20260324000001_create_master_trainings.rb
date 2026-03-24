class CreateMasterTrainings < ActiveRecord::Migration[8.1]
  def change
    create_table :master_trainings, id: :uuid do |t|
      t.references :client, null: false, foreign_key: true, type: :bigint
      t.references :trainer, null: false, foreign_key: { to_table: :users }, type: :bigint
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
  end
end
