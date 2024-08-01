class CreateAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :alerts do |t|
      t.references :user
      t.integer :expiring_in
      t.boolean :enabled

      t.timestamps
    end
  end
end
