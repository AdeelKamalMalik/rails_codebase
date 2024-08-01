class AddAlternativeNameToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :alternative_name, :string
  end
end
