class AddSalesPriceAndSalesTaxToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :sales_price, :decimal, precision: 12, scale: 2
    add_column :products, :sales_tax, :decimal, precision: 12, scale: 2
    add_column :products, :discount, :decimal, precision: 12, scale: 2

    change_column :vendors, :annual_cost, :decimal, precision: 12, scale: 2
    change_column :vendors, :monthly_cost, :decimal, precision: 12, scale: 2
  end
end
