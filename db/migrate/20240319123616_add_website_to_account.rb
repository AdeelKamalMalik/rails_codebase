class AddWebsiteToAccount < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :website, :string
  end
end
