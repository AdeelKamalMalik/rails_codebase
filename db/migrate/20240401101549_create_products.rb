class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :quantity
      t.text :notes
      t.integer :unit
      t.date :start_date
      t.date :end_date
      t.references :contract

      t.timestamps
    end
  end
end
