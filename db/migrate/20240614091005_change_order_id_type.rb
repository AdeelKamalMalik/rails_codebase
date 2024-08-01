class ChangeOrderIdType < ActiveRecord::Migration[7.1]
  def change
    rename_column :contracts, :order_id, :order_number
    change_column :contracts, :order_number, :string
    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
