class AddCacheColumnsToVendor < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :review_status, :integer, default: 0
    add_column :vendors, :annual_cost, :integer
    add_column :vendors, :monthly_cost, :integer
    add_column :vendors, :end_date, :datetime

    reversible do |dir|
      dir.up do
        Vendor.draft.update_all(status: :active)
        Vendor.find_each do |vendor|
          vendor.update_cache_columns
        end
      end
    end
  end
end
