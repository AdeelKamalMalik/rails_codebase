class AddFieldstoContracts < ActiveRecord::Migration[7.1]
  def change
    change_table :contracts do |t|
      t.string :public_id, limit: 18, null: false
      t.string :name
      t.integer :status, default: 0, null: false
      t.date :start_date
      t.date :end_date
      t.integer :order_id
      t.date :renewal_date
      t.boolean :marketing_clause
      t.boolean :auto_renewal
    end

    add_index :contracts, :public_id, unique: true
  end
end
