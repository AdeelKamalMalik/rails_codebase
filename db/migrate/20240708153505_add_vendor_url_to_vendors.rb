class AddVendorUrlToVendors < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :vendor_url, :string
  end
end
