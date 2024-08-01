class AddEnumsInToContractsTable < ActiveRecord::Migration[7.1]
  def change
    add_column :contracts, :review_input, :integer, default: 0, null: false
    add_column :contract_files, :contract_type, :integer, default: 0, null: false
  end
end
