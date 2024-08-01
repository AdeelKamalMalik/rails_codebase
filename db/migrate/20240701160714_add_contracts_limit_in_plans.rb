class AddContractsLimitInPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :contracts_limit, :integer, default: 0, null: false
  end
end
