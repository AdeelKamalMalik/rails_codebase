class AddSummaryColumnsToContracts < ActiveRecord::Migration[7.1]
  def change
    add_column :contracts, :annual_cost, :decimal, precision: 12, scale: 2
    add_column :contracts, :total_cost, :decimal, precision: 12, scale: 2
    add_column :contracts, :monthly_cost, :decimal, precision: 12, scale: 2
    add_column :contracts, :purchase_order_required, :boolean
    add_column :contracts, :currency_code, :string
    add_column :contracts, :payment_terms, :string
    add_column :contracts, :billing_interval, :string

    add_column :contract_files, :acv, :decimal, precision: 12, scale: 2
    add_column :contract_files, :tcv, :decimal, precision: 12, scale: 2
  end
end
