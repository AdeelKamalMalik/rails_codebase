class AddPublicKeyInVendors < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :public_id, :string, limit: 18, null: false
    add_column :vendors, :user_id, :integer
    add_column :vendors, :status, :integer, default: 0, null: false

    add_index :vendors, :public_id, unique: true
  end
end
