class CreateContractFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :contract_files do |t|
      t.integer :status, default: 0, null: false
      t.references :contract
      t.string :signed_file_id

      t.timestamps
    end
  end
end
